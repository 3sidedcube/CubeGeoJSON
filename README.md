# CubeGeoJSON

 [![Swift 5.5](http://img.shields.io/badge/swift-5.5-brightgreen.svg)](https://swift.org/blog/swift-5-5-released/)

A GeoJSON library for iOS, macOS, and watchOS written in Swift.

Features:

- Parse all kinds of [Geometry](http://geojson.org/geojson-spec.html#geometry-objects) objects
- Auto-Creates MKShape subclasses to represent your GeoJSON structure
- Allows serialising back to swift dictionary objects
- Adds useful helper methods for doing calculations with and editing GeoJSON structures

## Installation

Add the package with Swift Package Manager, either in Xcode (File › Add Package Dependencies…) or in a `Package.swift`:

```swift
.package(url: "https://github.com/3sidedcube/CubeGeoJSON.git", from: "27.1.0")
```

`GeoJSON` is a dynamic library product. Add it to your app target with **Embed & Sign**; other targets that use it (frameworks, app extensions, test bundles) link it without embedding, so the app loads a single copy.

## Usage

Initialise a new Geometry object using the default `init(dictionary: [String:AnyObject)` method

```swift
import GeoJSON

let geoJSON = [
    "type": "MultiPoint",
    "coordinates": [
        [
            -105.01621,
            39.57422
        ],
        [
            -80.6665134,
            35.0539943
        ]
    ]
]

let geometry = Geometry(dictionary: geoJSON)

if let annotations : [MKPointAnnotation]? = geometry.shapes?.flatMap({ $0 as? MKPointAnnotation }) {
  mapView.addAnnotations(annotations)
}
```

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D
