//
//  GHStatusServiceTest.swift
//  Reuben
//
//  Created by Daniel Norton on 10/14/15.
//  Copyright © 2015 Daniel Norton. All rights reserved.
//

@testable import Reuben
import XCTest


class GHStatusServiceTest: XCTestCase {
    
    override func tearDown() {
        
        let service = GHStatusService()
        _ = try? service.clean()
        super.tearDown()
    }
    
    func testCleanAndSave() {
        
        let tempDir = NSURL(fileURLWithPath: NSTemporaryDirectory())
        let tempFile = tempDir.URLByAppendingPathComponent(__FUNCTION__)
        let tempText = "{\"status\":\"good\",\"last_updated\":\"2015-10-14T05:00:25Z\"}"
        
        do {
            
            let service = GHStatusService()
            _ = try tempText.writeToFile(tempFile.path!, atomically: true, encoding: NSUnicodeStringEncoding)
            let answer = try service.cleanAndSave(tempFile)
            XCTAssert(answer, "failed to save")
            
        } catch {
            
            XCTFail()
        }
    }
    
    func testFailCleanAndSave() {
        
        let tempDir = NSURL(fileURLWithPath: NSTemporaryDirectory())
        let tempFile = tempDir.URLByAppendingPathComponent(__FUNCTION__)

        do {

            let service = GHStatusService()
            let answer = try service.cleanAndSave(tempFile)
            XCTAssertFalse(answer, "expected false from cleanAndSave")
            
        } catch {
            
            XCTFail()
        }
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
    
    func testReadEmpty() {
        
        let service = GHStatusService()
        _ = try? service.clean()
        let answer = service.read()
        XCTAssert(answer == nil)
    }
    
    func testReadLatest() {
        
        let identifier = __FUNCTION__
        let waitHandler = self.expectationWithDescription(identifier)
        let service = GHStatusService()
        
        let completionHandler = {(result: UIBackgroundFetchResult) -> Void in
            
            if (result == .NewData) {
                
                let answer = service.read()
                XCTAssertNotNil(answer)
                XCTAssertNotNil(answer!.status)
                XCTAssertNotNil(answer!.lastUpdated)
                
                print("status: \"\(answer!.status)\" last_updated: \"\(answer!.lastUpdated)\"")
                
                waitHandler.fulfill()
            }
        }
        
        service.refresh(completionHandler)
        self.waitForExpectationsWithTimeout(30.0, handler: nil)
    }
    
    func testReadLatestClearCache() {
        
        let identifier = __FUNCTION__
        let waitHandler = self.expectationWithDescription(identifier)
        let service = GHStatusService()
        
        let completionHandler = {(result: UIBackgroundFetchResult) -> Void in
            
            if (result == .NewData) {
                
                service.clearCache()
                let answer = service.read()
                XCTAssertNotNil(answer)
                XCTAssertNotNil(answer!.status)
                XCTAssertNotNil(answer!.lastUpdated)
                
                print("status: \"\(answer!.status)\" last_updated: \"\(answer!.lastUpdated)\"")
                
                waitHandler.fulfill()
            }
        }
        
        service.refresh(completionHandler)
        self.waitForExpectationsWithTimeout(30.0, handler: nil)
    }
}