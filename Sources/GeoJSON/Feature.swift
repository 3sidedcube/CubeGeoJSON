//
//  Feature.swift
//  GeoJSON
//
//  Created by Simon Mitchell on 02/10/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

import Foundation

/// A feature represents a `Geometry` object and a JSON structure of associated data [spec](http://geojson.org/geojson-spec.html#feature-objects)
open class Feature: NSObject {
    
    /// The geometry object that this feature represents
    open var geometry: Geometry
    
    /// A JSON payload of properties on the feature object
    open var properties: [AnyHashable : Any]
    
    public init?(dictionary: [AnyHashable : Any]) {
        
        guard let geometryDict = dictionary["geometry"] as? [AnyHashable : Any], let properties = dictionary["properties"] as? [AnyHashable : Any] else { return nil }
        geometry = Geometry(dictionary: geometryDict)
        self.properties = properties
    }
}


/// A feature collection represents a set of `Feature` objects [spec](http://geojson.org/geojson-spec.html#feature-collection-objects)
open class FeatureCollection: NSObject {
    
    /// An array of features that the collection represents
    open var features: [Feature]
    
    public init?(dictionary: [AnyHashable : Any]) {
        
        guard let featuresArray = dictionary["features"] as? [[AnyHashable : Any]] else { return nil }
        features = featuresArray.compactMap({ Feature(dictionary: $0) })
    }
}
