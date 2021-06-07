// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "some-service",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/brokenhandsio/vapor.git", .branch("tracing")),
        .package(url: "https://github.com/brokenhandsio/soto.git", .branch("tracing")),
        .package(url: "https://github.com/apple/swift-distributed-tracing.git", from: "0.1.2"),
        .package(url: "https://github.com/slashmo/opentelemetry-swift.git", .branch("main")),
        .package(url: "https://github.com/slashmo/opentelemetry-swift-xray.git", .branch("main")),
        .package(url: "https://github.com/apple/swift-statsd-client.git", from: "1.0.0-alpha.4"),
        .package(url: "https://github.com/brokenhandsio/jwt.git", .branch("tracing")),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "SotoDynamoDB", package: "soto"),
                .product(name: "Tracing", package: "swift-distributed-tracing"),
                .product(name: "TracingOpenTelemetrySupport", package: "swift-distributed-tracing"),
                .product(name: "StatsdClient", package: "swift-statsd-client"),
                .product(name: "JWT", package: "jwt"),                
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .executableTarget(
            name: "Run",
            dependencies: [
                .target(name: "App"),
                .product(name: "OpenTelemetry", package: "opentelemetry-swift"),
                .product(name: "OpenTelemetryXRay", package: "opentelemetry-swift-xray"),
                .product(name: "OtlpGRPCSpanExporting", package: "opentelemetry-swift"),
                .product(name: "StatsdClient", package: "swift-statsd-client"),
            ]
        ),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
