//
//  ModelTests.swift
//  CubeAlerts
//
//  Created by Matthew Cheetham on 30/04/2016.
//  Copyright © 2016 3 SIDED CUBE. All rights reserved.
//

import XCTest

class TestCore: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /**
     Loads a dictionary object out of a given JSON file name for testing model allocation
     */
    func loadDictionaryForFile(_ name: String!) -> [AnyHashable : Any]? {
        let jsonFilePath = Bundle(for: type(of: self)).url(forResource: name, withExtension: "geojson")
        
        if let jsonPath = jsonFilePath, let jsonFileData = try? Data(contentsOf: jsonPath) {
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: jsonFileData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [AnyHashable : Any] {
                    
                    return jsonObject
                }
                
            } catch let error as NSError {
                
                print(error)
            }
        }
        
        return nil
    }
    
    /**
     Loads a dictionary object out of a given JSON file name for testing model allocation
     */
    func loadArrayForFile(name: String!) -> [[AnyHashable : Any]]? {
        
        let jsonFilePath = Bundle(for: type(of: self)).url(forResource: name, withExtension: "json")
        
        if let jsonPath = jsonFilePath, let jsonFileData = try? Data(contentsOf: jsonPath) {
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: jsonFileData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [[AnyHashable : Any]] {
                    
                    return jsonObject
                }
                
            } catch let error as NSError {
                
                print(error)
            }
        }
        
        return nil
    }
    
}
