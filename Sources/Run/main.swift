import App
import Vapor
import Instrumentation
import OpenTelemetry
import OpenTelemetryXRay
import OtlpGRPCSpanExporting
import Tracing

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)

let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
let otel = OTel(
    serviceName: Environment.get("SERVICE_NAME") ?? "test-service",
    eventLoopGroup: eventLoopGroup,
    idGenerator: XRayIDGenerator(),
    sampler: RouteBasedSampler(),
    processor: OTel.BatchSpanProcessor(
        exportingTo: OtlpGRPCSpanExporter(config: .init(eventLoopGroup: eventLoopGroup)),
        eventLoopGroup: eventLoopGroup
    ),
    propagator: XRayPropagator()
)

let app = Application(env, .shared(eventLoopGroup))
app.lifecycle.use(OTelLifecycleHandler(otel: otel))

defer { app.shutdown() }
try configure(app)
try app.run()

struct OTelLifecycleHandler: LifecycleHandler {
    let otel: OTel

    func willBoot(_ application: Application) throws {
        application.logger.notice("Starting OTel tracer")
        try otel.start().wait()
        InstrumentationSystem.bootstrap(otel.tracer())
    }

    func shutdown(_ application: Application) {
        do {
            application.logger.notice("Shutting down OTel tracer")
            try otel.shutdown().wait()
        } catch {
            application.logger.warning("Failed shutting down OTel tracer", metadata: ["error": "\(error)"])
        }
    }
}

struct RouteBasedSampler: OTelSampler {
    func makeSamplingDecision(
        operationName: String,
        kind: SpanKind,
        traceID: OTel.TraceID,
        attributes: SpanAttributes,
        links: [SpanLink],
        parentBaggage: Baggage
    ) -> OTel.SamplingResult {
        operationName == "/hc" ? .init(decision: .drop) : .init(decision: .recordAndSample)
    }
}
