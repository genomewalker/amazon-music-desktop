// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AmazonMusicDesktop",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "AmazonMusicDesktop", targets: ["AmazonMusicDesktop"])
    ],
    targets: [
        .executableTarget(
            name: "AmazonMusicDesktop"
        ),
        .testTarget(
            name: "AmazonMusicDesktopTests",
            dependencies: ["AmazonMusicDesktop"]
        )
    ]
)
