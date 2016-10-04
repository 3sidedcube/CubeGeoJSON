//
//  Geometry.swift
//  Thunder Alert
//
//  Created by Simon Mitchell on 07/12/2015.
//  Copyright © 2015 3 SIDED CUBE. All rights reserved.
//

import Foundation
import MapKit

/**
 An enum representing the order of the coordinates
 */
@objc public enum CoordinateOrder: Int {
    /**
     Ordered latitude then longitude
     */
    case latLng
    /**
     Ordered longitude then latitude
     */
    case lngLat
}

/**
 The geometry type of the GeoJSON object
 
 - SeeAlso: [GeoJSON - Geometry Spec](http://geojson.org/geojson-spec.html#geometry-objects)
 - Note: We have added Circle here, which isn't in the specification, but which is required by us as an Agency
 */
public enum GeometryType: String {
    
    /**
     We're not quite sure how you got here, but you seem to have managed to. Congrats
     */
    case unknown
    /**
     A simple point.
     */
    case point
    /**
     A collection of separate points.
     */
    case multiPoint
    /**
     A collection of points representing a line between them.
     */
    case lineString
    /**
     A collection of LineStrings representing multiple paths on a map.
     */
    case multiLineString
    /**
     A simple polygon, the first array of coordinates will be used as the outer polygon, and any further arrays will be cut out from the interior of that outer polygon
     */
    case polygon
    /**
     A collection of Polygons representing multiple polygons on a map.
     */
    case multiPolygon
    /**
     A collection of any of the other types of GeoJSON geometry
     */
    case geometryCollection
    /**
     A custom GeoJSON object with a single position and a radius
     */
    case circle
}

func DegreesToRadians (_ value:Double) -> Double {
    return value * M_PI / 180.0
}

func RadiansToDegrees (_ value:Double) -> Double {
    return value * 180.0 / M_PI
}

/**
 A class representation of a GeoJSON Position object
 
 - SeeAlso: [GeoJSON - Position](http://geojson.org/geojson-spec.html#positions)
 */
open class Position: NSObject {
    
    /**
     The latitudal value of the position
     */
    open var latitude: CLLocationDegrees
    
    /**
     The longitudinal value of the position
     */
    open var longitude: CLLocationDegrees
    
    /**
     Helper method for returning a CLLocationCoordinate2D from the object
     */
    open var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    open override var debugDescription: String {
        get {
            return "(\(latitude),\(longitude))"
        }
    }
    
    open override var description: String {
        get {
            return "(\(latitude),\(longitude))"
        }
    }
    
    public override init() {
        
        latitude = 0
        longitude = 0
        super.init()
    }
    
    /**
     Initialises and returns a Position object from an array of Double types
     */
    public init(coordinates:[Double]) {
        
        latitude = coordinates.count > 1 ? coordinates[1] : 0.0
        longitude = coordinates.count > 0 ? coordinates[0] : 0.0
    }
    
    /**
     Returns a CLLocationCoordinate2D representation of the object with a given Coordinate Order
     
     - Parameter coordinateOrder: The coordinate order to create the CLLocationCoordinate2D with
     - Returns: Returns a CLLocationCoordinate2D
     */
    open func coordinate(_ coordinateOrder: CoordinateOrder) -> CLLocationCoordinate2D {
        
        // Because long lat matches what we assumed the order was on init we return that correctly
        switch coordinateOrder {
        case .lngLat:
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        case .latLng:
            return CLLocationCoordinate2D(latitude: longitude, longitude: latitude)
        }
    }
    
    /**
     Returns the GeoJSON spec dictionary representation of the Position Object
     
     - Returns: Returns an array of Doubles
     */
    open var dictionaryRepresentation: [Double] {
        get {
            return [longitude, latitude]
        }
    }
    
    /**
     A helper method to get the center of an array of Position objects
     
     - Parameter positions: The array of Position objects to return the center point for
     - Returns: A Position object at the center of the given positions
     */
    open static func center(_ positions:[Position]) -> Position {
        
        if (positions.count == 1) {
            return positions.first!
        }
        
        var maxLat = -200.0
        var maxLng = -200.0
        var minLat: CLLocationDegrees = CLLocationDegrees(MAXFLOAT)
        var minLng: CLLocationDegrees = CLLocationDegrees(MAXFLOAT)
        
        for position in positions {
            
            if position.latitude < minLat {
                minLat = position.latitude
            }
            
            if position.latitude > maxLat {
                maxLat = position.latitude
            }
            
            if position.longitude < minLng {
                minLng = position.longitude
            }
            
            if position.longitude > maxLng {
                maxLng = position.longitude
            }
            
        }
        
        return Position(coordinates: [ (maxLng + minLng) * 0.5,(maxLat + minLat) * 0.5])
        
    }
}

/**
 A class representing any Geometry from the GeoJSON specification
 
 This geometry object will recursively allocate any child geometries, and will also create MKShape objects where it can to represent the GeoJSON parsed
 */
open class Geometry: NSObject {
    
    /**
     The geometry type of the GeoJSON Geometry
     */
    open var type: GeometryType
    
    /**
     For our Objective-C Compatriates, a string representation of the geometry type
     
     - Warning: This also changes `type` when set!
     */
    open var typeString: String {
        
        didSet {
            
            if let aType = GeometryType(rawValue: typeString) {
                type = aType
            } else {
                type = .unknown
            }
        }
    }
    
    /**
     The central coordinate of the geometry object
     */
    open var centerCoordinate: Position?
    
    // Which one of these is set depends on the type of the geometry
    
    /**
     An optional array of Position objects
     
     This should be non-nil for the following geometry types:
     
     - Point
     - MultiPoint
     - LineString
     - Circle
     */
    open var coordinates: [Position]?
    
    /**
     An optional array of array of Position objects
     
     This should be non-nil for the following geometry types:
     
     - MultiLineString
     - Polygon
     */
    open var multiCoordinates: [[Position]]?
    
    /**
     An optional array of array of array of Position objects
     
     This should be non-nil for the following geometry types:
     
     - MultiPolygon
     */
    open var multiMultiCoordinates: [[[Position]]]?
    
    /**
     An optional array of geometry objects
     
     This should be non-nil for GeometryCollection geometry types
     */
    open var geometries: [Geometry]?
    
    /**
     The radius of the geometry object
     
     - Note: This should only be non-zero for cirlce geometry types
     */
    open var radius: Double
    
    /**
     A JSON representation of the original GeoJSON for this geometry object
     
     - Warning: This is a get method, so should not be called too frequently, for large Geometry objects it could become intensive
     */
    open var dictionaryRepresentation: [AnyHashable : Any] {
        
        get {
            
            var dict:[AnyHashable : Any] = [:]
            dict["type"] = type.rawValue
            
            if let geos = geometries {
                
                dict["geometries"] = geos.map({ return $0.dictionaryRepresentation })
                
            } else if let coords = coordinates {
                
                if type == .circle || type == .point {
                    
                    if let firstCoord = coords.first {
                        dict["coordinates"] = firstCoord.dictionaryRepresentation
                    }
                } else {
                    dict["coordinates"] = coords.map({ return $0.dictionaryRepresentation })
                }
                
            } else if let multiCoords = multiCoordinates {
                
                var outerCoords: [[[Double]]] = []
                for coords in multiCoords {
                    outerCoords.append(
                        coords.map({ return $0.dictionaryRepresentation })
                    )
                }
                dict["coordinates"] = outerCoords
                
            } else if let multiMultiCoords = multiMultiCoordinates {
                
                var outerArray: [[[[Double]]]] = []
                for multiCoords in multiMultiCoords {
                    
                    var outerCoords: [[[Double]]] = []
                    for coords in multiCoords {
                        outerCoords.append(
                            coords.map({ return $0.dictionaryRepresentation })
                        )
                    }
                    outerArray.append(outerCoords)
                }
                dict["coordinates"] = outerArray
                
            }
            
            if type == .circle {
                dict["radius"] = radius
            }
            
            return dict
        }
    }
    
    /**
     An optional array of MKShape objects which represent the geometry
     */
    open var shapes:[MKShape]?
    
    /**
     Initialises and populates a new Geometry object from a GeoJSON dictionary
     */
    public init(dictionary: [AnyHashable : Any]) {
        
        guard let typeStr = dictionary["type"] as? String, let geoType = GeometryType(rawValue: typeStr) else {
            
            typeString = "Unknown"
            type = .unknown
            radius = 0
            super.init()
            return
        }
        
        typeString = typeStr
        type = geoType
        radius = 0
        super.init()
        
        if let coords = dictionary["coordinates"] as? [Any] {
            processCoordinates(coords)
        }
        
        processShapes(dictionary)
        processCenter()
    }
    
    /**
     Processes and allocates the geometries coordinates to create the Shapes array
     
     - Parameter dictionary: The dictionary to process shapes for
     */
    fileprivate func processShapes(_ dictionary: [AnyHashable : Any]) {
        
        switch type {
            
        case .point, .multiPoint:
            
            shapes = coordinates?.map({ return PointShape.point($0, order: .lngLat) })
            
        case .lineString:
            
            guard let coords = coordinates else { break }
            shapes = [Polyline.polyline(coordinates: coords, order: .lngLat)]
            
        case .multiLineString:
            
            shapes = multiCoordinates?.map({
                return Polyline.polyline(coordinates: $0, order: .lngLat)
            })
            
        case .polygon:
            
            guard let multiCoords = multiCoordinates, let polygon = processPolygon(multiCoords) else { break }
            shapes = [polygon]
            
        case .multiPolygon:
            
            guard let multiMultiCoords = multiMultiCoordinates else { break }
            
            var polygons: [MKShape] = []
            for multiCoord in multiMultiCoords {
                
                if let polygon = processPolygon(multiCoord) {
                    polygons.append(polygon)
                }
            }
            shapes = polygons
            
        case .geometryCollection:
            
            guard let geoms = dictionary["geometries"] as? [[String:AnyObject]] else { break }
            geometries = geoms.map({
                return Geometry(dictionary: $0)
            })
            
            var aShapes: [MKShape] = []
            for geometry in geometries! {
                
                if let gShapes = geometry.shapes {
                    aShapes.append(contentsOf: gShapes)
                }
            }
            shapes = aShapes
            
        case .circle:
            
            guard let coords = coordinates, let firstCoord = coords.first else { break }
            
            if let rad = dictionary["radius"] as? Double {
                radius = rad
            } else {
                radius = 1609.344
            }
            
            shapes = [Circle.circle(firstCoord, radius: radius, order: .lngLat)]
            
        default: break
            
        }
    }
    
    /**
     Processes and allocates a Polygon shape from an array of array of positions
     
     - Parameter coords: The array of array of coordinates to process
     */
    fileprivate func processPolygon(_ coords:[[Position]]) -> Polygon? {
        
        guard let outerCoords = coords.first else { return nil }
        
        var aCoords = coords
        aCoords.removeFirst()
        
        let innerPolygons = aCoords.map({
            return Polygon.polygon($0, order: .lngLat)
        })
        
        return Polygon.polygon(coordinates: outerCoords, order: .lngLat, interiorPolygons:innerPolygons)
    }
    
    /**
     Processes the coordinates property of a Geometry object
     
     - Parameter coords: The coordinates property to process
     */
    fileprivate func processCoordinates(_ coords: [Any]?) {
        
        if let singleCoord = coords as? [Double] {
            
            coordinates = [Position(coordinates: singleCoord)]
            
        } else if let multipleCoords = coords as? [[Double]] {
            
            coordinates = multipleCoords.map({
                return Position(coordinates: $0)
            })
            
        } else if let multipleCoordArrays = coords as? [[[Double]]] {
            
            multiCoordinates = multipleCoordArrays.map({
                
                let innerArray = $0
                return innerArray.map({
                    return Position(coordinates: $0)
                })
            })
            
        } else if let multipleMultiCoordArrays = coords as? [[[[Double]]]] {
            
            multiMultiCoordinates = multipleMultiCoordArrays.map({
                
                let innerArray = $0
                return innerArray.map({
                    
                    let innerInnerArray = $0
                    return innerInnerArray.map({
                        return Position(coordinates: $0)
                    })
                })
            })
            
        }
        
    }
    
    /**
     Calculates and sets the center of the geometry object
     */
    fileprivate func processCenter() {
        
        if let coords = coordinates {
            
            centerCoordinate = Position.center(coords)
            
        } else if let multiCoords = multiCoordinates {
            
            let centerCoords = multiCoords.map({
                return Position.center($0)
            })
            centerCoordinate = Position.center(centerCoords)
            
        } else if let multiMultiCoords = multiMultiCoordinates {
            
            var centerMultiCoords: [Position] = []
            
            for multiCoords: [[Position]] in multiMultiCoords {
                
                var multiCoordCenters: [Position] = []
                
                for coords: [Position] in multiCoords {
                    multiCoordCenters.append(Position.center(coords))
                }
                
                centerMultiCoords.append(Position.center(multiCoordCenters))
            }
            
            centerCoordinate = Position.center(centerMultiCoords)
            
        }
        
    }
    
    /**
     For our objective-c friends this method allows you to use the + property to append a new position object to a Geometry
     */
    open class func append(_ position: Position, original: Geometry) -> Geometry {
        return original + position
    }
    
    open func roughlyEqual(other: Geometry) -> Bool {
        return self ~= other
    }
}

infix operator <> { associativity left precedence 160 }

private func <>(left: [Any], right: [Any]) -> Bool {
    
    if left.count == right.count {
        
        if let leftArray = left as? [[Any]], let rightArray = right as? [[Any]] {
            
            for (index, leftSubArray) in leftArray.enumerated() { // Check each sub array [Position]'s length
                
                let rightSubArray = rightArray[index]
                if !(rightSubArray <> leftSubArray) {
                    return false
                }
            }
        }
        
        return true
    }
    
    return false
}

infix operator ~= { associativity left precedence 160 }
public func ~=(left: Geometry, right: Geometry) -> Bool {
    
    if left.type != right.type {
        return false
    }
    
    let type = left.type
    
    // If the left and right geometries don't have same amount of coordinates, can't be the same
    if let leftCoords = left.coordinates, let rightCoords = right.coordinates, !(leftCoords <> rightCoords) {
        return false
    }
    
    // Compare multi coordinate arrays
    if let leftMultiCoords = left.multiCoordinates, let rightMultiCoords = right.multiCoordinates, !(leftMultiCoords <> rightMultiCoords) {
        return false
    }
    
    // Compare multi coordinate arrays
    if let leftMultiMultiCoords = left.multiMultiCoordinates, let rightMultiMultiCoords = right.multiMultiCoordinates, !(leftMultiMultiCoords <> rightMultiMultiCoords) {
        return false
    }
    
    // As we are doing a quick comparison, we'll match on the centercoordinate if they both exist! This way we avoid any overhead on calculations!
    if let leftCoord = left.centerCoordinate, let rightCoord = right.centerCoordinate, type != .circle && leftCoord == rightCoord {
        return true
    }
    
    // Always default back to they're not equal!
    return false
}
/**
 Allows the plus operator to add a Position object to a Geometry object
 */
public func +(left: Geometry, right: Position) -> Geometry {
    
    var typeString = left.type.rawValue
    let oldGeometry = Geometry(dictionary: left.dictionaryRepresentation)
    
    switch oldGeometry.type {
    case .circle, .unknown, .geometryCollection, .multiPolygon:
        // Do nothing
        break
    case .point, .multiPoint:
        typeString = "MultiPoint"
        if var coords = oldGeometry.coordinates {
            coords.append(right)
        } else {
            left.coordinates = [right]
        }
        // Turn into a multi-point
        break
    case .lineString:
        if var coords = oldGeometry.coordinates {
            coords.append(right)
        } else {
            left.coordinates = [right]
        }
    case .multiLineString:
        if var multiCoords = oldGeometry.multiCoordinates, var lastArray = multiCoords.last {
            
            lastArray.append(right)
            multiCoords.removeLast()
            multiCoords.append(lastArray)
            oldGeometry.multiCoordinates = multiCoords
        }
        break
    case .polygon:
        if var multiCoords = oldGeometry.multiCoordinates, var lastArray = multiCoords.last {
            
            lastArray.insert(right, at: lastArray.count - 1)
            multiCoords.removeLast()
            multiCoords.append(lastArray)
            oldGeometry.multiCoordinates = multiCoords
        }
        break
    }
    
    var dictionaryRepresentation = oldGeometry.dictionaryRepresentation
    dictionaryRepresentation["type"] = typeString
    
    return Geometry(dictionary: dictionaryRepresentation)
}
