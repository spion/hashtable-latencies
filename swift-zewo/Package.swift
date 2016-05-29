import PackageDescription

let package = Package(
    name: "swift-zewo",
    dependencies: [
            .Package(url: "https://github.com/Zewo/Router.git", majorVersion: 0, minor: 5),
            .Package(url: "https://github.com/VeniceX/HTTPServer.git", majorVersion: 0, minor: 5)
    ]
)
