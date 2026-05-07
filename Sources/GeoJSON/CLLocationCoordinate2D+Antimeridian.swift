//
//  CLLocationCoordinate2D+Antimeridian.swift
//  GeoJSON
//
//  Created by Ben Shutt on 27/07/2020.
//  Copyright © 2020 threesidedcube. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    
    var mappingLongitude: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude.mappedLongitude
        )
    }
}

// MARK: - FloatingPoint + Antimeridian

extension FloatingPoint {
    
    var mappedLongitude: Self {
        return mappedLongitude(self)
    }
    
    func mappedLongitude(_ longitude: Self) -> Self {
        if longitude > 180 {
            return mappedLongitude(longitude - 360)
        } else if longitude <= -180 {
            return mappedLongitude(longitude + 360)
        }
        
        return longitude
    }
}
