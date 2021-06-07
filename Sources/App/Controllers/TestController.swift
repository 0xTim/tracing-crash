import Vapor

struct TestController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let testRoutes = routes.grouped("test")
        testRoutes.post("test", use: testHandler)
    }

    func testHandler(_ req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return req.eventLoop.future(.ok)
    }
}
