//
//  apiSimpleTests.swift
//  ReubenTests
//
//  Created by Daniel Norton on 4/10/15.
//  Copyright (c) 2015 Daniel Norton. All rights reserved.
//

import UIKit
import XCTest

class apiSimpleTests: XCTestCase {

    func testGetUserGeneric() {
        
        let waitHandler = self.expectationWithDescription(__FUNCTION__)
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let url = NSURL(string: "https://api.github.com/users/octocat")!
        let task = session.dataTaskWithURL(url) { (data, _, error) -> Void in
            
            if (error == nil) {
                
                XCTAssertNotNil(data)
                if let rawJson = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? Dictionary<String, AnyObject> {
                    
                    waitHandler.fulfill()
                }
            }
        }
        
        task.resume()
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testGetOrganizationsGeneric() {
        
        let waitHandler = self.expectationWithDescription(__FUNCTION__)
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let url = NSURL(string: "https://api.github.com/users/octocat/orgs")!
        let task = session.dataTaskWithURL(url) { (data, _, error) -> Void in
            
            if (error == nil) {
                
                XCTAssertNotNil(data)
                if let rawJson = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? Array<String> {
                    
                    waitHandler.fulfill()
                }
            }
        }
        
        task.resume()
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testGetReposGeneric() {
        
        let waitHandler = self.expectationWithDescription(__FUNCTION__)
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let url = NSURL(string: "https://api.github.com/users/octocat/repos")!
        let task = session.dataTaskWithURL(url) { (data, _, error) -> Void in
            
            if (error == nil) {
                
                XCTAssertNotNil(data)
                if let rawJson = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? Array<Dictionary<String, AnyObject>> {
                    
                    waitHandler.fulfill()
                }
            }
        }
        
        task.resume()
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}
