//
//  GHStatusServiceTest.swift
//  Reuben
//
//  Created by Daniel Norton on 10/14/15.
//  Copyright © 2015 Daniel Norton. All rights reserved.
//


import XCTest
@testable import Reuben


class GHStatusServiceTest: XCTestCase {
    
    override func tearDown() {
        
        let service = GHStatusService()
        _ = try? service.clean()
        super.tearDown()
    }

    func testValidate_Good() {

        let text = "{\"status\":\"good\",\"last_updated\":\"2015-10-14T05:00:25Z\"}"
        let data = text.dataUsingEncoding(NSUnicodeStringEncoding)!
        let answer = GHStatusService.validate(data)
        XCTAssert(answer, "failed to validate")
    }
    
    func testValidate_Fail_status() {
        
        let text = "{\"fred\":\"good\",\"last_updated\":\"2015-10-14T05:00:25Z\"}"
        let data = text.dataUsingEncoding(NSUnicodeStringEncoding)!
        let answer = GHStatusService.validate(data)
        XCTAssertFalse(answer, "failed to validate")
    }
    
    func testValidate_Fail_last_updated() {
        
        let text = "{\"status\":\"good\",\"fred\":\"2015-10-14T05:00:25Z\"}"
        let data = text.dataUsingEncoding(NSUnicodeStringEncoding)!
        let answer = GHStatusService.validate(data)
        XCTAssertFalse(answer, "failed to validate")
    }
    
    func testValidate_Fail_last_updated_value() {
        
        let text = "{\"status\":\"good\",\"last_updated\":\"fred\"}"
        let data = text.dataUsingEncoding(NSUnicodeStringEncoding)!
        let answer = GHStatusService.validate(data)
        XCTAssertFalse(answer, "failed to validate")
    }
    
    func testDownload() {
        
        let identifier = __FUNCTION__
        let waitHandler = self.expectationWithDescription(identifier)
        
        let completionHandler = {(result: UIBackgroundFetchResult) -> Void in
            
            if (result == .NewData) {
                
                waitHandler.fulfill()
            }
        }
        
        let service = GHStatusService()
        service.refresh(completionHandler)
        self.waitForExpectationsWithTimeout(30.0, handler: nil)
    }
}