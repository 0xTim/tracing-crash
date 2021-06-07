import Vapor
import SotoCore

// configures your application
public func configure(_ app: Application) throws {
    // register routes
    try routes(app)

    let port: Int
    if let portProvided = Environment.get("PORT"), let portNumber = Int(portProvided) {
        port = portNumber
    } else {
        port = 8080
    }
    app.http.server.configuration.port = port
}
