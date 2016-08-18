//
//  Polygon.swift
//  Thunder Alert
//
//  Created by Simon Mitchell on 07/12/2015.
//  Copyright © 2015 3 SIDED CUBE. All rights reserved.
//

import Foundation
import MapKit

/**
 A subclass of MKPolygon for easy allocation from GeoJSON
 */
open class Polygon: MKPolygon {
    
    /**
     Returns a new instance from an array of Position objects
     
     - Parameter coordinates: An array of coordinates representing the Polygon
     */
    open static func polygon(_ coordinates:[Position]) -> Polygon {
        return self.polygon(coordinates: coordinates, order: .lngLat, interiorPolygons:[])
    }
    
    /**
     Returns a new instance from an array of Position objects with a given coordinate order
     
     - Parameter coordinates: An array of coordinates representing the Polygon
     - Parameter order: The order that the coordinates appear in
     */
    open static func polygon(_ coordinates:[Position], order:CoordinateOrder) -> Polygon {
        return self.polygon(coordinates: coordinates, order:order, interiorPolygons:[])
    }
    
    /**
     Returns a new instance from an array of Position objects with an optional set of interior polygons
     
     - Parameter coordinates: An array of coordinates representing the Polygon
     - Parameter order: The order that the coordinates appear in
     - Parameter interiorPolygons: Any interior polygon objects that the polygon has
     */
    open static func polygon(coordinates coords:[Position], order:CoordinateOrder, interiorPolygons:[Polygon]?) -> Polygon {
        
        var coordinates: [CLLocationCoordinate2D] = coords.map({
            return $0.coordinate(order)
        })
        
        return Polygon(coordinates: &coordinates, count: coords.count, interiorPolygons: interiorPolygons)
    }
}

/**
 A subclass of MKPolyline for easy allocation from GeoJSON
 */
open class Polyline: MKPolyline {
    
    /**
     Returns a new instance from an array of Position objects
     
     - Parameter coordinates: An array of coordinates representing the Polyline
     */
    open static func polyline(_ coordinates:[Position]) -> Polyline {
        return self.polyline(coordinates: coordinates, order: .lngLat)
    }
    
    /**
     Returns a new instance from an array of Position objects
     
     - Parameter coordinates: An array of coordinates representing the Polyline
     - Parameter order: The order that the coordinates appear in
     */
    open static func polyline(coordinates coords:[Position], order: CoordinateOrder) -> Polyline {
        
        var coordinates: [CLLocationCoordinate2D] = coords.map({
            return $0.coordinate(order)
        })
        
        return Polyline(coordinates: &coordinates, count: coords.count)
    }
}

/**
 A subclass of MKCircle for easy allocation from GeoJSON
 */
open class Circle: MKCircle {
    
    /**
     Returns a new instance from an array of Position objects
     
     - Parameter coordinate: The center coordinate of the circle
     - Parameter radius: The radius of the circle
     */
    open static func circle(_ coordinate:Position, radius:CLLocationDistance) -> Circle {
        return self.circle(coordinate, radius:radius, order: .lngLat)
    }
    
    /**
     Returns a new instance from an array of Position objects
     
     - Parameter coordinate: The center coordinate of the circle
     - Parameter radius: The radius of the circle
     - Parameter order: The order that the coordinates appear in
     */
    open static func circle(_ coordinate:Position, radius:CLLocationDistance, order:CoordinateOrder) -> Circle {
        return Circle(center: coordinate.coordinate(order), radius: radius)
    }
}

/**
 A subclass of MKPointAnnotation for easy allocation from GeoJSON
 */
open class PointShape: MKPointAnnotation {
    
    /**
     Returns a new instance from a position object
     
     - Parameter coordinate: The coordinate of the annotation
     */
    open static func point(_ coordinate:Position) -> PointShape {
        return self.point(coordinate, order: .lngLat)
    }
    /**
     Returns a new instance from a position object
     
     - Parameter coordinate: The coordinate of the annotation
     - Parameter order: The coordinate order of the position object
     */
    open static func point(_ coordinate:Position, order: CoordinateOrder) -> PointShape {
        let point = PointShape()
        point.coordinate = coordinate.coordinate(order)
        return point
    }
}
