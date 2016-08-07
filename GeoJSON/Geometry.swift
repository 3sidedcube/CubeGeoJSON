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
    case Unknown
    /**
     A simple point.
     */
    case Point
    /**
     A collection of separate points.
     */
    case MultiPoint
    /**
     A collection of points representing a line between them.
     */
    case LineString
    /**
     A collection of LineStrings representing multiple paths on a map.
     */
    case MultiLineString
    /**
     A simple polygon, the first array of coordinates will be used as the outer polygon, and any further arrays will be cut out from the interior of that outer polygon
     */
    case Polygon
    /**
     A collection of Polygons representing multiple polygons on a map.
     */
    case MultiPolygon
    /**
     A collection of any of the other types of GeoJSON geometry
     */
    case GeometryCollection
    /**
     A custom GeoJSON object with a single position and a radius
     */
    case Circle
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
public class Position: NSObject {
    
    /**
     The latitudal value of the position
     */
    public var latitude: CLLocationDegrees
    
    /**
     The longitudinal value of the position
     */
    public var longitude: CLLocationDegrees
    
    /**
     Helper method for returning a CLLocationCoordinate2D from the object
     */
    public var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    public override var debugDescription: String {
        get {
            return "(\(latitude),\(longitude))"
        }
    }
    
    public override var description: String {
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
    public func coordinate(_ coordinateOrder: CoordinateOrder) -> CLLocationCoordinate2D {
        
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
    public var dictionaryRepresentation: [Double] {
        get {
            return [longitude, latitude]
        }
    }
    
    /**
     A helper method to get the center of an array of Position objects
     
     - Parameter positions: The array of Position objects to return the center point for
     - Returns: A Position object at the center of the given positions
     */
    public static func center(_ positions:[Position]) -> Position {
        
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
public class Geometry: NSObject {
    
    /**
     The geometry type of the GeoJSON Geometry
     */
    public var type: GeometryType
    
    /**
     For our Objective-C Compatriates, a string representation of the geometry type
     
     - Warning: This also changes `type` when set!
     */
    public var typeString: String {
        
        didSet {
            
            if let aType = GeometryType(rawValue: typeString) {
                type = aType
            } else {
                type = .Unknown
            }
        }
    }
    
    /**
     The central coordinate of the geometry object
     */
    public var centerCoordinate: Position?
    
    // Which one of these is set depends on the type of the geometry
    
    /**
     An optional array of Position objects
     
     This should be non-nil for the following geometry types:
     
     - Point
     - MultiPoint
     - LineString
     - Circle
     */
    public var coordinates: [Position]?
    
    /**
     An optional array of array of Position objects
     
     This should be non-nil for the following geometry types:
     
     - MultiLineString
     - Polygon
     */
    public var multiCoordinates: [[Position]]?
    
    /**
     An optional array of array of array of Position objects
     
     This should be non-nil for the following geometry types:
     
     - MultiPolygon
     */
    public var multiMultiCoordinates: [[[Position]]]?
    
    /**
     An optional array of geometry objects
     
     This should be non-nil for GeometryCollection geometry types
     */
    public var geometries: [Geometry]?
    
    /**
     The radius of the geometry object
     
     - Note: This should only be non-zero for cirlce geometry types
     */
    public var radius: Double
    
    /**
     A JSON representation of the original GeoJSON for this geometry object
     
     - Warning: This is a get method, so should not be called too frequently, for large Geometry objects it could become intensive
     */
    public var dictionaryRepresentation: [String:AnyObject] {
        
        get {
            
            var dict:[String:AnyObject] = [:]
            dict["type"] = type.rawValue
            
            if let geos = geometries {
                
                dict["geometries"] = geos.map({ return $0.dictionaryRepresentation })
                
            } else if let coords = coordinates {
                
                if type == .Circle {
                    
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
            
            if type == .Circle {
                dict["radius"] = radius
            }
            
            return dict
        }
    }
    
    /**
     An optional array of MKShape objects which represent the geometry
     */
    public var shapes:[MKShape]?
    
    /**
     Initialises and populates a new Geometry object from a GeoJSON dictionary
     */
    public init(dictionary:[String:AnyObject]) {
        
        guard let typeStr = dictionary["type"] as? String, geoType = GeometryType(rawValue: typeStr) else {
            
            typeString = "Unknown"
            type = .Unknown
            radius = 0
            super.init()
            return
        }
        
        typeString = typeStr
        type = geoType
        radius = 0
        super.init()
        
        if let coords = dictionary["coordinates"] as? [AnyObject] {
            processCoordinates(coords)
        }
        
        processShapes(dictionary)
        processCenter()
    }
    
    /**
     Processes and allocates the geometries coordinates to create the Shapes array
     
     - Parameter dictionary: The dictionary to process shapes for
     */
    private func processShapes(_ dictionary: [String:AnyObject]) {
        
        switch type {
            
        case .Point, .MultiPoint:
            
            shapes = coordinates?.map({ return PointShape.point($0, order: .lngLat) })
            
        case .LineString:
            
            guard let coords = coordinates else { break }
            shapes = [Polyline.polyline(coordinates: coords, order: .lngLat)]
            
        case .MultiLineString:
            
            shapes = multiCoordinates?.map({
                return Polyline.polyline(coordinates: $0, order: .lngLat)
            })
            
        case .Polygon:
            
            guard let multiCoords = multiCoordinates, polygon = processPolygon(multiCoords) else { break }
            shapes = [polygon]
            
        case .MultiPolygon:
            
            guard let multiMultiCoords = multiMultiCoordinates else { break }
            
            var polygons: [MKShape] = []
            for multiCoord in multiMultiCoords {
                
                if let polygon = processPolygon(multiCoord) {
                    polygons.append(polygon)
                }
            }
            shapes = polygons
            
        case .GeometryCollection:
            
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
            
        case .Circle:
            
            guard let coords = coordinates, firstCoord = coords.first else { break }
            
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
    private func processPolygon(_ coords:[[Position]]) -> Polygon? {
        
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
    private func processCoordinates(_ coords:[AnyObject]?) {
        
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
    private func processCenter() {
        
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
    public class func append(_ position: Position, original: Geometry) -> Geometry {
        return original + position
    }
}

/**
 Allows the plus operator to add a Position object to a Geometry object
 */
public func +(left: Geometry, right: Position) -> Geometry {
    
    var typeString = left.type.rawValue
    let oldGeometry = Geometry(dictionary: left.dictionaryRepresentation)
    
    switch oldGeometry.type {
    case .Circle, .Unknown, .GeometryCollection, .MultiPolygon:
        // Do nothing
        break
    case .Point, .MultiPoint:
        typeString = "MultiPoint"
        if var coords = oldGeometry.coordinates {
            coords.append(right)
        } else {
            left.coordinates = [right]
        }
        // Turn into a multi-point
        break
    case .LineString:
        if var coords = oldGeometry.coordinates {
            coords.append(right)
        } else {
            left.coordinates = [right]
        }
    case .MultiLineString:
        if var multiCoords = oldGeometry.multiCoordinates, lastArray = multiCoords.last {
            
            lastArray.append(right)
            multiCoords.removeLast()
            multiCoords.append(lastArray)
            oldGeometry.multiCoordinates = multiCoords
        }
        break
    case .Polygon:
        if var multiCoords = oldGeometry.multiCoordinates, lastArray = multiCoords.last {
            
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
