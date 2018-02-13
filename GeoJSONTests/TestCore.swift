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
    func loadDictionaryForFile(name: String!) -> [AnyHashable : Any]? {
        
        let jsonFilePath = NSBundle(forClass: self.dynamicType).pathForResource(name, ofType: "geojson")
        
        if let jsonPath = jsonFilePath, let jsonFileData = NSData(contentsOfFile: jsonPath) {
            
            do {
                if let jsonObject = try NSJSONSerialization.JSONObjectWithData(jsonFileData, options: NSJSONReadingOptions.MutableContainers) as? [AnyHashable : Any] {
                    
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
        
        let jsonFilePath = NSBundle(forClass: self.dynamicType).pathForResource(name, ofType: "json")
        
        if let jsonPath = jsonFilePath, let jsonFileData = NSData(contentsOfFile: jsonPath) {
            
            do {
                if let jsonObject = try NSJSONSerialization.JSONObjectWithData(jsonFileData, options: NSJSONReadingOptions.MutableContainers) as? [[AnyHashable : Any]] {
                    
                    return jsonObject
                }
                
            } catch let error as NSError {
                
                print(error)
            }
        }
        
        return nil
    }
    
}
