// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "GeoJSON",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "GeoJSON",
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
