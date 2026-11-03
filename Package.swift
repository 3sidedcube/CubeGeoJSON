// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "GeoJSON",
    platforms: [
        .iOS("18.0")
    ],
    products: [
        .library(
            name: "GeoJSON",
            type: .dynamic,
            targets: ["GeoJSON"]
        )
    ],
    targets: [
        .target(
            name: "GeoJSON",
            path: "Sources/GeoJSON"
        ),
        .testTarget(
            name: "GeoJSONTests",
            dependencies: ["GeoJSON"],
            path: "Tests/GeoJSONTests",
            resources: [
                .copy("TestGeoJSON")
            ]
        )
    ]
)
