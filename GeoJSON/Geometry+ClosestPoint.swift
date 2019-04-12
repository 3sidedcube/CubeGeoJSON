//
//  PolygonIntersection.swift
//  ARC Hazards
//
//  Created by Simon Mitchell on 05/03/2019.
//  Copyright © 2019 3 SIDED CUBE Design Ltd. All rights reserved.
//

import Foundation
import CoreLocation
import simd

fileprivate let Re: CLLocationDistance = 6371008.8

extension Position {
    /// Calculates the distance between the position and a given location
    ///
    /// - Parameter location: The location to return the distance to
    /// - Returns: The distance in metres
    public func distance(from location: CLLocation) -> CLLocationDistance {
        let selfLocation = CLLocation(latitude: latitude, longitude: longitude)
        return location.distance(from: selfLocation)
    }
    
    /// Calculates the distance between the position and another position
    ///
    /// - Parameter position: The position to return the distance to
    /// - Returns: The distance in metres
    public func distance(from position: Position) -> CLLocationDistance {
        let otherLocation = CLLocation(latitude: position.latitude, longitude: position.longitude)
        return self.distance(from: otherLocation)
    }
}

extension Position {
    /// Calculates the shortest distance from the position to a line between two other positions
    ///
    /// - Parameters:
    ///   - from: The start point of the line
    ///   - to: The end point of the line
    /// - Returns: The shortest distance between the position and a line between the two positions
    public func distanceToLine(from: Position, to: Position) -> CLLocationDistance {
        
        guard from != to else {
            return from.distance(from: to)
        }
        
        let s0lat = DegreesToRadians(latitude)
        let s0lng = DegreesToRadians(longitude)
        let s1lat = DegreesToRadians(from.latitude)
        let s1lng = DegreesToRadians(from.longitude)
        let s2lat = DegreesToRadians(to.latitude)
        let s2lng = DegreesToRadians(to.longitude)
        
        let s2s1lat = s2lat - s1lat
        let s2s1lng = s2lng - s1lng
        
        let u = ((s0lat - s1lat) * s2s1lat + (s0lng - s1lng) * s2s1lng)
            / (s2s1lat * s2s1lat + s2s1lng * s2s1lng)
        if (u <= 0) {
            return distance(from: from)
        }
        if (u >= 1) {
            return distance(from: to)
        }
        
        let sa = Position(coordinates: [longitude - from.longitude, latitude - from.latitude])
        let sb = Position(coordinates: [u * (to.longitude - from.longitude), u * (to.latitude - from.latitude)])
        
        return sa.distance(from: sb)
    }
}

extension Array where Element == Position {
    
    /// Calculates the closest position to a given coordinate, including it's distance and previous/next elements in the array
    ///
    /// - Parameter location: The location to find the closest position to
    /// - Returns: The closest position if one is found
    public func closestPosition(toLocation location: CLLocation) -> (position: Position, distance: CLLocationDistance, previous: Position, next: Position)? {
        
        var fixedSelf = self
        // If the first and last position are identical, then remove them otherwise we can get identical positions returned as the closest and previous/next which can cause issues with further calculations!
        if first?.longitude == last?.longitude && first?.latitude == last?.latitude {
            fixedSelf.removeFirst()
        }
        
        let elements = fixedSelf.enumerated().map({ (index, position) -> (position: Position, distance: CLLocationDistance, previous: Position, next: Position) in
            
            var nextIndex = index + 1
            var previousIndex = index - 1
            if !fixedSelf.indices.contains(nextIndex) {
                nextIndex = 0
            }
            if !fixedSelf.indices.contains(previousIndex) {
                previousIndex = fixedSelf.count - 1
            }
            
            return (position, position.distance(from: location), fixedSelf[previousIndex], fixedSelf[nextIndex])
        })
        
        return elements.sorted(by: { (element1, element2) -> Bool in
            element1.distance < element2.distance
        }).first
    }
}

extension Geometry {
    
    /// Calculates the closest vertex to the provided position as well as the previous and next vertex where appropriate
    ///
    /// - Note: This will return nil apart from for geometry which contains a Polygon or MultiPolygon
    ///
    /// - Parameter coordinate: The coordinate to return for
    /// - Returns: The closest vertex to the provided coordinate, the distance it is away and the previous/next positions in the polygon
    public func closestVertex(toCoordinate coordinate: CLLocationCoordinate2D) -> (position: Position, distance: CLLocationDistance, previous: Position, next: Position)? {
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        switch type {
        case .circle, .multiPoint, .point, .lineString, .multiLineString, .unknown:
            return nil
        case .geometryCollection:
            
            // For each geometry return
            return geometries?.compactMap({ (geometry) -> (position: Position, distance: CLLocationDistance, previous: Position, next: Position)? in
                return geometry.closestVertex(toCoordinate: coordinate)
            }).sorted(by: { (item1, item2) -> Bool in
                return item1.distance < item2.distance
            }).first
            
        case .polygon:
            
            // For each part of the polygon, find the closest point... this includes internal vertices from cutouts
            var closest = multiCoordinates?.compactMap({ (positions) -> (position: Position, distance: CLLocationDistance, previous: Position, next: Position)? in
                positions.closestPosition(toLocation: location)
            })
            
            // Sort the closest positions by distance
            closest?.sort(by: { (element1, element2) -> Bool in
                return element1.distance < element2.distance
            })
            
            // Return the closest
            return closest?.first
            
        case .multiPolygon:
            
            // For each polygon
            var closestPerPolygon = multiMultiCoordinates?.compactMap({ (positionArrays) -> (position: Position, distance: CLLocationDistance, previous: Position, next: Position)? in
                
                // For each part of the polygon, find the closest point... this includes internal vertices from cutouts
                var closest = positionArrays.compactMap({ (positions) -> (position: Position, distance: CLLocationDistance, previous: Position, next: Position)? in
                    positions.closestPosition(toLocation: location)
                })
                
                // Sort the closest positions by distance
                closest.sort(by: { (element1, element2) -> Bool in
                    return element1.distance < element2.distance
                })
                
                // Return the closest
                return closest.first
            })
            
            // Sort by the closest polygon
            closestPerPolygon?.sort(by: { (element1, element2) -> Bool in
                return element1.distance < element2.distance
            })
            
            // Return the closest
            return closestPerPolygon?.first
        }
    }
    
    /// Calculates the shortest distance from the coordinate to the geometry
    ///
    /// - Note: This will return nil apart from for geometry which contains a Polygon or MultiPolygon
    ///
    /// - Parameter coordinate: The coordinate to return for
    /// - Returns: The closest point on the geometry
    public func distanceToClosestEdge(from coordinate: CLLocationCoordinate2D) -> CLLocationDistance? {
        
        guard let closestVertex = closestVertex(toCoordinate: coordinate) else {
            return nil
        }
        
        let testPosition = Position(coordinates: [coordinate.longitude, coordinate.latitude])
        let nextDistance = testPosition.distanceToLine(from: closestVertex.position, to: closestVertex.next)
        let previousDistance = testPosition.distanceToLine(from: closestVertex.previous, to: closestVertex.position)
        
        return min(nextDistance, previousDistance)
    }
}
