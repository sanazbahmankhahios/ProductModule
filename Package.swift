// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProductModule",
    platforms: [
        .iOS(.v16),
        .macOS(.v14),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "ProductModule",
            targets: ["ProductModule"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/sanazbahmankhahios/ProductKit.git", from: "1.0.0"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.6.1")
    ],
    .target(
        name: "ProductModule",
        dependencies: [
            "ProductKit",
            .product(name: "Kingfisher", package: "Kingfisher")
        ]
    ),
        .testTarget(
            name: "ProductModuleTests",
            dependencies: ["ProductModule"]
        )
    ]
)
