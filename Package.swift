// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SubtitleOverlay",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "OverlayCore", targets: ["OverlayCore"]),
        .executable(name: "SubtitleOverlay", targets: ["SubtitleOverlay"])
    ],
    targets: [
        .target(name: "OverlayCore"),
        .executableTarget(
            name: "SubtitleOverlay",
            dependencies: ["OverlayCore"]
        ),
        .testTarget(
            name: "SubtitleOverlayTests",
            dependencies: ["OverlayCore"]
        )
    ]
)
