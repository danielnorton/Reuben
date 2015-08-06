//
//  apiSimpleTests.swift
//  ReubenTests
//
//  Created by Daniel Norton on 4/10/15.
//  Copyright (c) 2015 Daniel Norton. All rights reserved.
//

import UIKit
import XCTest

class APISimpleTests: XCTestCase {

    let timeout = 5.0

    func testRoot() {
        
        let waitHandler = self.expectationWithDescription(__FUNCTION__)
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let url = NSURL(string: "https://api.github.com/")!
        let request = NSMutableURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: timeout)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        let task = session.dataTaskWithRequest(request) { (data, _, error) -> Void in
            
            if (error == nil) {
                
                XCTAssertNotNil(data)
                
                do {
                    
                    if let _ = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? Dictionary<String, AnyObject> {
                        
                        waitHandler.fulfill()
                    }
                    
                } catch { }
            }
        }
        
        task.resume()
        self.waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    func testGetUserGeneric() {
        
        let waitHandler = self.expectationWithDescription(__FUNCTION__)
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let url = NSURL(string: "https://api.github.com/users/octocat")!
        let request = NSMutableURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: timeout)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        let task = session.dataTaskWithRequest(request) { (data, _, error) -> Void in
            
            if (error == nil) {
                
                XCTAssertNotNil(data)

                do {

                    if let _ = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? Dictionary<String, AnyObject> {
                        
                        waitHandler.fulfill()
                    }
                    
                } catch { }
            }
        }
        
        task.resume()
        self.waitForExpectationsWithTimeout(timeout, handler: nil)
    }

    func testGetOrganizationsGeneric() {
        
        let waitHandler = self.expectationWithDescription(__FUNCTION__)
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let url = NSURL(string: "https://api.github.com/users/octocat/orgs")!
        let request = NSMutableURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: timeout)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        let task = session.dataTaskWithRequest(request) { (data, _, error) -> Void in
            
            if (error == nil) {
                
                XCTAssertNotNil(data)
                
                do {
                    
                    if let _ = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? Array<String> {
                        
                        waitHandler.fulfill()
                    }
                    
                } catch { }
            }
        }
        
        task.resume()
        self.waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    func testGetReposGeneric() {
        
        let waitHandler = self.expectationWithDescription(__FUNCTION__)
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let url = NSURL(string: "https://api.github.com/users/octocat/repos")!
        let request = NSMutableURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: timeout)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        let task = session.dataTaskWithRequest(request) { (data, _, error) -> Void in
            
            if (error == nil) {
                
                XCTAssertNotNil(data)
                
                do {
                    
                    if let _ = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? Array<Dictionary<String, AnyObject>> {
                        
                        waitHandler.fulfill()
                    }
                    
                } catch { }
            }
        }
        
        task.resume()
        self.waitForExpectationsWithTimeout(timeout, handler: nil)
    }
}
