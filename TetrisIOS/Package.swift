// swift-tools-version: 5.9
// This file is provided as an alternative build option using Swift Package Manager.
// For the full Xcode project experience, see README.md.

import PackageDescription

let package = Package(
    name: "TetrisIOS",
    platforms: [.iOS(.v17)],
    products: [],
    targets: [
        .executableTarget(
            name: "TetrisIOS",
            path: "TetrisIOS"
        ),
        .testTarget(
            name: "TetrisIOSTests",
            dependencies: ["TetrisIOS"],
            path: "TetrisIOSTests"
        ),
    ]
)
