//
//  Position.swift
//  GeoJSON
//
//  Created by Simon Mitchell on 05/03/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import CoreLocation
import Foundation

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

public func ==(left: Position, right: Position) -> Bool {
    return (left.longitude == right.longitude) && (left.latitude == right.latitude)
}
