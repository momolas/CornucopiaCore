// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CornucopiaCore",
    platforms: [
        .iOS("13.4"),
        .macOS(.v11),
        .tvOS(.v13),
        .watchOS(.v6),
        //.linux
    ],
    products: [
        .library(
            name: "CornucopiaCore",
            targets: ["CornucopiaCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto", .upToNextMajor(from: "1.1.6")),
        .package(url: "https://github.com/tsolomko/SWCompression", .upToNextMajor(from: "4.6.0"))
    ],
    targets: [
        .target(
            name: "CornucopiaCore",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "SWCompression", package: "SWCompression"),
                ]
            ),
        .testTarget(
            name: "CornucopiaCoreTests",
            dependencies: ["CornucopiaCore"]
            ),
    ]
)
