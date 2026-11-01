// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ExternalMacAwake",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "AwakeCore", targets: ["AwakeCore"]),
        .executable(name: "ExternalMacAwake", targets: ["ExternalMacAwake"]),
    ],
    targets: [
        .target(name: "AwakeCore"),
        .executableTarget(
            name: "ExternalMacAwake",
            dependencies: ["AwakeCore"]
        ),
        .testTarget(
            name: "AwakeCoreTests",
            dependencies: ["AwakeCore"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
