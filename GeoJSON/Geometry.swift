//
//  Geometry.swift
//  Thunder Alert
//
//  Created by Simon Mitchell on 07/12/2015.
//  Copyright © 2015 3 SIDED CUBE. All rights reserved.
//

import Foundation

@objc public enum CoordinateOrder: Int {
    case LatLng
    case LngLat
}

public enum GeometryType: String {
    case Unknown
    case Point
    case MultiPoint
    case LineString
    case MultiLineString
    case Polygon
    case MultiPolygon
    case GeometryCollection
    case Circle
}

func DegreesToRadians (value:Double) -> Double {
    return value * M_PI / 180.0
}

func RadiansToDegrees (value:Double) -> Double {
    return value * 180.0 / M_PI
}

public class Position: NSObject {
    
    public var latitude: CLLocationDegrees
    public var longitude: CLLocationDegrees
    
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
    
    init(coordinates:[Double]) {
        
        latitude = coordinates.count > 1 ? coordinates[1] : 0.0
        longitude = coordinates.count > 0 ? coordinates[0] : 0.0
    }
    
    public func coordinate(coordinateOrder: CoordinateOrder) -> CLLocationCoordinate2D {
        
        switch coordinateOrder {
        case .LngLat:
            return CLLocationCoordinate2D(latitude: longitude, longitude: latitude)
        case .LatLng:
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    public var dictionaryRepresentation: [Double] {
        get {
            return [longitude, latitude]
        }
    }
    
    public static func center(positions:[Position]) -> Position {
        
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

public class Geometry: NSObject {
    
    public var type: GeometryType
    public var typeString: String {

        didSet {
            
            if let aType = GeometryType(rawValue: typeString) {
                type = aType
            } else {
                type = .Unknown
            }
        }
    }
    public var centerCoordinate: Position?
    
    // Which one of these is set depends on the type of the geometry
    
    public var coordinates: [Position]?
    
    public var multiCoordinates: [[Position]]?
    
    public var multiMultiCoordinates: [[[Position]]]?
    
    public var geometries: [Geometry]?
    
    public var radius: Double
    
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

    public var shapes:[MKShape]?
    
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
        
        switch type {
            
        case .Point, .MultiPoint:
            
            guard let coords = coordinates else { break }
            
            shapes = coords.map({ return PointShape.point($0, order: .LatLng) })
            
        case .LineString:
            
            guard let coords = coordinates else { break }
            shapes = [Polyline.polyline(coordinates: coords, order: .LatLng)]
            
        case .MultiLineString:
            
            shapes = multiCoordinates?.map({
                return Polyline.polyline(coordinates: $0, order: .LatLng)
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
                    aShapes.appendContentsOf(gShapes)
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
            
            shapes = [Circle.circle(firstCoord, radius: radius, order: .LatLng)]
            
        default: break
            
        }
        
        processCenter()
 
    }
    
    private func processPolygon(coords:[[Position]]) -> Polygon? {
        
        guard let outerCoords = coords.first else { return nil }
        
        var aCoords = coords
        aCoords.removeFirst()
        
        let innerPolygons = aCoords.map({
            return Polygon.polygon($0, order: .LatLng)
        })
        
        return Polygon.polygon(coordinates: outerCoords, order: .LatLng, interiorPolygons:innerPolygons)
    }
    
    private func processCoordinates(coords:[AnyObject]?) {
        
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
    
    public class func append(position: Position, original: Geometry) -> Geometry {
        return original + position
    }
}

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
            
            lastArray.insert(right, atIndex: lastArray.count - 1)
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
