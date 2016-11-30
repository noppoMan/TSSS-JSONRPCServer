import PackageDescription

let package = Package(
    name: "TSSSJSONRPCServer",
    dependencies: [
        .Package(url: "https://github.com/noppoMan/Prorsum.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/noppoMan/SwiftyJSONRPC.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/noppoMan/CHiredis.git", majorVersion: 0, minor: 2),
    ]
)
