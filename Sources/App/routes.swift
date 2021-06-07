import Vapor

func routes(_ app: Application) throws {
    app.routes.get("hc") { _ in
        "OK"
    }

    let someRoutes = app.grouped("test", ":testID")
    try someRoutes.register(collection: TestController())
}
