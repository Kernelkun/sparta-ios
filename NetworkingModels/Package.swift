// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkingModels",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "NetworkingModels",
            targets: ["NetworkingModels"]),
    ],
    dependencies: [
        .package(name: "SwiftyJSON", url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
        .package(name: "SpartaHelpers", path: "../SpartaHelpers")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "NetworkingModels",
            dependencies: ["SwiftyJSON", "SpartaHelpers"]),
        .testTarget(
            name: "NetworkingModelsTests",
            dependencies: ["NetworkingModels"]),
    ]
)
