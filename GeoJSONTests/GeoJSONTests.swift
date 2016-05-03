//
//  GeoJSONTests.swift
//  GeoJSONTests
//
//  Created by Simon Mitchell on 03/05/2016.
//  Copyright © 2016 yellowbrickbear. All rights reserved.
//

import XCTest
@testable import GeoJSON

class GeoJSONTests: TestCore {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPointAllocation() {

        guard let dictionary = loadDictionaryForFile("Test GeoJSON/PointGeoJSON") else { return }
            
        let geoJSON = Geometry(dictionary: dictionary)
        
        XCTAssertNotNil(geoJSON, "the GeoJSON object was unexpectedly nil")
        XCTAssertEqual(geoJSON.type, GeometryType.Point, "GeoJSON has incorrect type")
        XCTAssertEqual(geoJSON.typeString, "Point", "GeoJSON has incorrect type string")
        XCTAssertNotNil(geoJSON.coordinates, "coordinates was unexpectedly nil")
        XCTAssertNil(geoJSON.multiCoordinates, "multiCoordinates was unexpectedly non-nil")
        XCTAssertNil(geoJSON.multiMultiCoordinates, "multiMultiCoordinates was unexpectedly non-nil")
        
        if let firstCoordinate = geoJSON.coordinates?.first {
            
            XCTAssertEqual(firstCoordinate.longitude, -105.01621, "latitude was incorrect")
            XCTAssertEqual(firstCoordinate.latitude, 39.57422, "latitude was incorrect")
        } else {
            XCTFail("first coordinate was unexpectedly nil")
        }
        
        if let firstShape = geoJSON.shapes?.first as? PointShape {
            
            XCTAssertEqual(firstShape.coordinate.latitude, geoJSON.coordinates?.first?.latitude, "Shape has incorrect latitude")
            XCTAssertEqual(firstShape.coordinate.longitude, geoJSON.coordinates?.first?.longitude, "Shape has incorrect longitude")

        } else {
            
            XCTFail("First shape has incorrect type")
        }
    }
    
    func testMultiPointAllocation() {
        
        guard let dictionary = loadDictionaryForFile("Test GeoJSON/MultiPointGeoJSON") else { return }
        
        let geoJSON = Geometry(dictionary: dictionary)
        
        XCTAssertNotNil(geoJSON.coordinates, "Coordinates was unexpectedly nil")
        XCTAssertEqual(geoJSON.coordinates?.count, 2, "Incorrect number of coordinates allocated")
        XCTAssertEqual(geoJSON.type, GeometryType.MultiPoint, "GeoJSON has incorrect type")
        XCTAssertEqual(geoJSON.typeString, "MultiPoint", "GeoJSON has incorrect type string")
        
        if let firstCoordinate = geoJSON.coordinates?.first {
            
            XCTAssertEqual(firstCoordinate.longitude, -105.01621, "latitude was incorrect")
            XCTAssertEqual(firstCoordinate.latitude, 39.57422, "latitude was incorrect")
        }
        
        if let lastCoordinate = geoJSON.coordinates?.last {
            
            XCTAssertEqual(lastCoordinate.longitude, -80.6665134, "latitude was incorrect")
            XCTAssertEqual(lastCoordinate.latitude, 35.0539943, "latitude was incorrect")
        }
        
        if let firstShape = geoJSON.shapes?.first as? PointShape {
            
            XCTAssertEqual(firstShape.coordinate.latitude, geoJSON.coordinates?.first?.latitude, "Shape has incorrect latitude")
            XCTAssertEqual(firstShape.coordinate.longitude, geoJSON.coordinates?.first?.longitude, "Shape has incorrect longitude")
            
        } else {
            
            XCTFail("First shape has incorrect type")
        }
        
        if let secondShape = geoJSON.shapes?.last as? PointShape {
            
            XCTAssertEqual(secondShape.coordinate.latitude, geoJSON.coordinates?.last?.latitude, "Shape has incorrect latitude")
            XCTAssertEqual(secondShape.coordinate.longitude, geoJSON.coordinates?.last?.longitude, "Shape has incorrect longitude")
            
        } else {
            
            XCTFail("Second shape has incorrect type")
        }
    }
    
    func testLineStringAllocation() {
        
        guard let dictionary = loadDictionaryForFile("Test GeoJSON/LineStringGeoJSON") else { return }
        
        let geoJSON = Geometry(dictionary: dictionary)
        
        XCTAssertNotNil(geoJSON.coordinates, "Coordinates was unexpectedly nil")
        XCTAssertEqual(geoJSON.coordinates?.count, 26, "Incorrect number of coordinates allocated")
        XCTAssertEqual(geoJSON.type, GeometryType.LineString, "GeoJSON has incorrect type")
        XCTAssertEqual(geoJSON.typeString, "LineString", "GeoJSON has incorrect type string")
        
        if let firstCoordinate = geoJSON.coordinates?.first {
            
            XCTAssertEqual(firstCoordinate.longitude, -101.744384765625, "longitude was incorrect")
            XCTAssertEqual(firstCoordinate.latitude, 39.32155002466662, "latitude was incorrect")
        }
        
        if let lastCoordinate = geoJSON.coordinates?.last {
            
            XCTAssertEqual(lastCoordinate.longitude, -97.635498046875, "longitude was incorrect")
            XCTAssertEqual(lastCoordinate.latitude, 38.87392853923629, "latitude was incorrect")
        }
        
        if let firstShape = geoJSON.shapes?.first as? Polyline {
            
            XCTAssertEqual(firstShape.pointCount, 26, "Shape has incorrect point count")
            
        } else {
            
            XCTFail("First shape has incorrect type")
        }
    }
    
    func testMultiLineStringAllocation() {
        
        guard let dictionary = loadDictionaryForFile("Test GeoJSON/MultiLineStringGeoJSON") else { return }
        let geoJSON = Geometry(dictionary: dictionary)
        
        XCTAssertNotNil(geoJSON.multiCoordinates, "MultiCoordinates was unexpectedly nil")
        XCTAssertEqual(geoJSON.multiCoordinates?.count, 4, "MultiCoordinates has incorrect length")
        XCTAssertEqual(geoJSON.type, GeometryType.MultiLineString, "GeoJSON has incorrect type")
        XCTAssertEqual(geoJSON.typeString, "MultiLineString", "GeoJSON has incorrect type string")
        
        if let firstCoordinateArray = geoJSON.multiCoordinates?.first {
            
            XCTAssertEqual(firstCoordinateArray.count, 6, "First coordinate array has incorrect length")
            
            if let firstCoordinate = firstCoordinateArray.first {
                XCTAssertEqual(firstCoordinate.longitude, -105.0214433670044, "longitude was incorrect")
                XCTAssertEqual(firstCoordinate.latitude, 39.57805759162015, "latitude was incorrect")
            } else {
                XCTFail("First coordinate was unexpectedly nil")
            }

        } else {
            XCTFail("First coordinate array was unexpectedly nil")
        }
        
        XCTAssertEqual(geoJSON.shapes?.count, 4, "Geometry has incorrect number of shapes")
        
        if let firstShape = geoJSON.shapes?.first as? Polyline {
            
            XCTAssertEqual(firstShape.pointCount, 6, "Shape has incorrect point count")
            
        } else {
            
            XCTFail("First shape has incorrect type")
        }
    }
    
    func testPolygonAllocation() {
        
        let bundle = NSBundle(forClass: GeoJSONTests.self)
        
        guard let dictionary = loadDictionaryForFile("Test GeoJSON/PolygonGeoJSON") else { return }
        let geoJSON = Geometry(dictionary: dictionary)
        
        XCTAssertNotNil(geoJSON.multiCoordinates, "MultiCoordinates was unexpectedly nil")
        XCTAssertEqual(geoJSON.multiCoordinates?.count, 2, "MultiCoordinates has incorrect length")
        XCTAssertEqual(geoJSON.type, GeometryType.Polygon, "GeoJSON has incorrect type")
        XCTAssertEqual(geoJSON.typeString, "Polygon", "GeoJSON has incorrect type string")
        
        XCTAssertEqual(geoJSON.multiCoordinates?.first?.count, 176, "First coordinate array has incorrect length")
        
        if let firstCoordinate = geoJSON.multiCoordinates?.first?.first {
            
            XCTAssertEqual(firstCoordinate.longitude, -84.32281494140625, "longitude was incorrect")
            XCTAssertEqual(firstCoordinate.latitude, 34.9895035675793, "latitude was incorrect")
        }
        
        XCTAssertEqual(geoJSON.shapes?.count, 1, "Geometry has incorrect number of shapes")
        
        if let firstShape = geoJSON.shapes?.first as? Polygon {
            
            XCTAssertEqual(firstShape.interiorPolygons?.count, 1, "Shape has incorrect count of interior polygons")
            //TODO: Inspect shape better here!
            
        } else {
            
            XCTFail("First shape has incorrect type")
        }
    }
    
    func testMultiPolygonAllocation() {
        
        guard let dictionary = loadDictionaryForFile("Test GeoJSON/MultiPolygonGeoJSON") else { return }        
        let geoJSON = Geometry(dictionary: dictionary)
        
        XCTAssertNotNil(geoJSON.multiMultiCoordinates, "MultiMultiCoordinates was unexpectedly nil")
        XCTAssertEqual(geoJSON.multiMultiCoordinates?.count, 2, "MultiCoordinates has incorrect length")
        XCTAssertEqual(geoJSON.type, GeometryType.MultiPolygon, "GeoJSON has incorrect type")
        XCTAssertEqual(geoJSON.typeString, "MultiPolygon", "GeoJSON has incorrect type string")
        
        XCTAssertEqual(geoJSON.multiMultiCoordinates?.first?.count, 2, "First coordinate array has incorrect length")
        
        if let firstMultiCoordinate = geoJSON.multiMultiCoordinates?.first {
            
            XCTAssertEqual(firstMultiCoordinate.first?.count, 176, "First polygon has incorrect coordinate count")
            
            if let firstCoordinate = firstMultiCoordinate.first?.first {
                
                XCTAssertEqual(firstCoordinate.longitude, -84.32281494140625, "longitude was incorrect")
                XCTAssertEqual(firstCoordinate.latitude, 34.9895035675793, "latitude was incorrect")
            }
            
        } else {
            XCTFail("First multi coordinate array unexpectedly nil")
        }
        
        XCTAssertEqual(geoJSON.shapes?.count, 2, "Geometry has incorrect number of shapes")
        
        if let firstShape = geoJSON.shapes?.first as? Polygon {
            
            XCTAssertEqual(firstShape.interiorPolygons?.count, 1, "Shape has incorrect count of interior polygons")
            //TODO: Inspect shape better here!
            
        } else {
            
            XCTFail("First shape has incorrect type")
        }
    }
}
