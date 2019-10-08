# CubeGeoJSON

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Swift 5.1](http://img.shields.io/badge/swift-5.1-brightgreen.svg)](https://swift.org/blog/swift-5-1-released/)

A GeoJSON library for iOS, macOS, and watchOS written in Swift.

Features:

- Parse all kinds of [Geometry](http://geojson.org/geojson-spec.html#geometry-objects) objects
- Auto-Creates MKShape subclasses to represent your GeoJSON structure
- Allows serialising back to swift dictionary objects
- Adds useful helper methods for doing calculations with and editing GeoJSON structures

## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate CubeGeoJSON into your Xcode project using Carthage, specify it in your `Cartfile`:

```
github "3sidedcube/CubeGeoJSON" == 1.2.0
```

Run `carthage update` to build the framework and drag the built `GeoJSON.framework` into your Xcode project.

### Manually

- Add CubeGeoJSON as a git [submodule](http://git-scm.com/docs/git-submodule) by running the following command:

```bash
$ git submodule add https://github.com/3sidedcube/CubeGeoJSON.git
```

- Open the new `CubeGeoJSON` folder, and drag the `GeoJSON.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Make sure the `GeoJSON.xcodeproj` is set up with the same deployment target as your root project.
- Add `GeoJSON.framework` as a target dependency to your project.

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
