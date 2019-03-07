//
//  PolygonIntersectionTests.swift
//  ARC HazardsTests
//
//  Created by Simon Mitchell on 05/03/2019.
//  Copyright © 2019 3 SIDED CUBE Design Ltd. All rights reserved.
//

import XCTest
@testable import GeoJSON
import CoreLocation

class PolygonIntersectionTests: TestCore {
    
    var featureCollection: FeatureCollection?

    override func setUp() {
        
        guard let featuresDict = loadDictionary(forFileName: "Test GeoJSON/FeatureCollection") else {
            return
        }
        
        featureCollection = FeatureCollection(dictionary: featuresDict)
    }
    
    func testClosestPointToAvalonCorrectCloserToAvalonThanMainland() {
        
        let closestCoord = CLLocationCoordinate2D(latitude: 33.48758079074844, longitude: -118.26644897460938)
        
        guard let featureCollection = featureCollection else {
            XCTFail("Failed to create feature collection for test")
            return
        }
        
        let closestPoints = featureCollection.features.compactMap { (feature) -> (position: Position, distance: CLLocationDistance, previous: Position, next: Position)? in
            return feature.geometry.closestVertex(toCoordinate: closestCoord)
        }
        
        XCTAssertEqual(closestPoints.count, 2)
        XCTAssertEqual(closestPoints[0].distance, 64709.8978, accuracy: 0.01)
        XCTAssertEqual(closestPoints[0].position.latitude, 33.4852)
        XCTAssertEqual(closestPoints[0].position.longitude, -118.96276)
        XCTAssertEqual(closestPoints[0].next.latitude, 33.4733)
        XCTAssertEqual(closestPoints[0].next.longitude, -118.96273)
        XCTAssertEqual(closestPoints[0].previous.latitude, 33.4953)
        XCTAssertEqual(closestPoints[0].previous.longitude, -118.9649)
        
        XCTAssertEqual(closestPoints[1].distance, 7405.058528966204, accuracy: 0.01)
        XCTAssertEqual(closestPoints[1].position.latitude, 33.44198)
        XCTAssertEqual(closestPoints[1].position.longitude, -118.32465)
        XCTAssertEqual(closestPoints[1].next.latitude, 33.43414)
        XCTAssertEqual(closestPoints[1].next.longitude, -118.31635)
        XCTAssertEqual(closestPoints[1].previous.latitude, 33.44804)
        XCTAssertEqual(closestPoints[1].previous.longitude, -118.33277)
    }
    
    func testClosestPointToAvalonCorrectCloserToMainlandThanAvalon() {
        
        let closestCoord = CLLocationCoordinate2D(latitude: 33.56758079074844, longitude: -118.26644897460938)
        
        guard let featureCollection = featureCollection else {
            XCTFail("Failed to create feature collection for test")
            return
        }
        
        let closestPoints = featureCollection.features.compactMap { (feature) -> (position: Position, distance: CLLocationDistance, previous: Position, next: Position)? in
            return feature.geometry.closestVertex(toCoordinate: closestCoord)
        }
        
        XCTAssertEqual(closestPoints.count, 2)
        XCTAssertEqual(closestPoints[0].distance, 65325.5220389, accuracy: 0.01)
        XCTAssertEqual(closestPoints[0].position.latitude, 33.4852)
        XCTAssertEqual(closestPoints[0].position.longitude, -118.96276)
        XCTAssertEqual(closestPoints[0].next.latitude, 33.4733)
        XCTAssertEqual(closestPoints[0].next.longitude, -118.96273)
        XCTAssertEqual(closestPoints[0].previous.latitude, 33.4953)
        XCTAssertEqual(closestPoints[0].previous.longitude, -118.9649)
        
        XCTAssertEqual(closestPoints[1].distance, 10654.924769206084, accuracy: 0.01)
        XCTAssertEqual(closestPoints[1].position.latitude, 33.66342)
        XCTAssertEqual(closestPoints[1].position.longitude, -118.27429)
        XCTAssertEqual(closestPoints[1].next.latitude, 33.65955)
        XCTAssertEqual(closestPoints[1].next.longitude, -118.31913)
        XCTAssertEqual(closestPoints[1].previous.latitude, 33.67507)
        XCTAssertEqual(closestPoints[1].previous.longitude, -118.25453)
    }
}
