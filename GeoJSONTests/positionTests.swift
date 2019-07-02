//
//  positionTests.swift
//  GeoJSON
//
//  Created by Simon Mitchell on 03/05/2016.
//  Copyright © 2016 threesidedcube. All rights reserved.
//

import XCTest
@testable import GeoJSON

class positionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit() {
        
        let position = Position(coordinates: [10, 20])
        XCTAssertNotNil(position, "Position was unexpectedly nil")
        XCTAssertEqual(position.longitude, 10, "Position has incorrect longitude")
        XCTAssertEqual(position.latitude, 20, "Position has incorrect latitude")
        
        var zeroPosition = Position()
        XCTAssertEqual(zeroPosition.longitude, 0, "Longitude unexpectedly non-zero")
        XCTAssertEqual(zeroPosition.latitude, 0, "Latitude unexpectedly non-zero")
        
        zeroPosition = Position(coordinates: [])
        XCTAssertEqual(zeroPosition.longitude, 0, "Longitude unexpectedly non-zero")
        XCTAssertEqual(zeroPosition.latitude, 0, "Latitude unexpectedly non-zero")
    }
    
    func testCoordinate() {
        
        let position = Position(coordinates: [10,20])
        let coordinate2D = position.coordinate
        
        XCTAssertEqual(coordinate2D.latitude, 20, "Coordinate has incorrect latitude")
        XCTAssertEqual(coordinate2D.longitude, 10, "Coordinate has incorrect longitude")
    }
    
    func testLongLat() {
        
        let position = Position(coordinates: [10,20])
        let coordinate2D = position.coordinate(.lngLat)
        
        XCTAssertEqual(coordinate2D.latitude, 20, "Coordinate has incorrect latitude")
        XCTAssertEqual(coordinate2D.longitude, 10, "Coordinate has incorrect longitude")
    }
    
    func testLatLong() {
        
        let position = Position(coordinates: [10,20])
        let coordinate2D = position.coordinate(.latLng)
        
        XCTAssertEqual(coordinate2D.latitude, 10, "Coordinate has incorrect latitude")
        XCTAssertEqual(coordinate2D.longitude, 20, "Coordinate has incorrect longitude")
    }
    
    func testDictionaryRepresentation() {
        
        let position = Position(coordinates: [10,20])
        
        let dictionaryRepresentation = position.dictionaryRepresentation
        XCTAssertEqual(dictionaryRepresentation.first, 10, "Dictionary representation has incorrect first value")
        XCTAssertEqual(dictionaryRepresentation.last, 20, "Dictionary representation has incorrect last value")
    }
    
    func testCenterOfPoints() {
        
        let positions = [
            Position(coordinates: [120, 30]),
            Position(coordinates: [100, -30]),
            Position(coordinates: [-100, 50]),
            Position(coordinates: [-100, -30]),
            Position(coordinates: [-170, 50])
        ]
        
        let centralPosition = Position.center(positions)
        
        XCTAssertEqual(centralPosition.latitude, 10)
        XCTAssertEqual(centralPosition.longitude, -25)
    }
}
