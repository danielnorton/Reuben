//
//  FileStoreServiceTests.swift
//  Reuben
//
//  Created by Daniel Norton on 12/19/15.
//  Copyright © 2015 Daniel Norton. All rights reserved.
//


import XCTest
@testable import Reuben


class FileStoreServiceTests: XCTestCase {

    
    let storeName = NSStringFromClass(FileStoreServiceTests)
    let setupText = "🐸🏵🌅🏪🤖🌺🎃🍟🌮🔮"
    let fileExtension = "txt"
    

    override func setUp() {
        super.setUp()
        
        let tempDir = NSURL(fileURLWithPath: NSTemporaryDirectory())
        let tempFile = tempDir.URLByAppendingPathComponent(__FUNCTION__)
        
        let service = FileStoreService(storeName: storeName)
        service.fileExtension = fileExtension
        
        do {

            try setupText.writeToFile(tempFile.path!, atomically: true, encoding: NSUnicodeStringEncoding)
            try service.cleanAndSave(tempFile)
            
        } catch {
            
            XCTFail()
        }
    }
    
    override func tearDown() {
        
        let service = FileStoreService(storeName: storeName)
        _ = try? service.clean()
        
        super.tearDown()
    }
    
    func testFlushCache() {
        
        let service = FileStoreService(storeName: storeName)
        
        service.flushCache()
        XCTAssertNil(service.cache)
        XCTAssertNotNil(service.read())
        
        service.useCache = true
        service.flushCache()
        XCTAssertNotNil(service.read())
        XCTAssertNotNil(service.cache)
        
        service.useCache = false
        service.flushCache()
        XCTAssertNotNil(service.read())
        XCTAssertNil(service.cache)
    }
    
    func testCleanAndSave() {
        
        let tempDir = NSURL(fileURLWithPath: NSTemporaryDirectory())
        let tempFile = tempDir.URLByAppendingPathComponent(__FUNCTION__)
        let tempText = "🦁🐯🦁🐯🦁🐯🦁🐯"
        
        let service = FileStoreService(storeName: storeName)
        service.fileExtension = fileExtension
        
        do {
            
            try tempText.writeToFile(tempFile.path!, atomically: true, encoding: NSUnicodeStringEncoding)
            let answer = try service.cleanAndSave(tempFile)
            XCTAssert(answer, "failed to save")

            let around = NSString(data: service.read()!, encoding: NSUnicodeStringEncoding)
            XCTAssertEqual(tempText, around)
            
        } catch {
            
            XCTFail()
        }
    }
    
    func testClean() {
        
        let service = FileStoreService(storeName: storeName)
        service.useCache = true
        do {

            XCTAssertNotNil(service.read())
            XCTAssertNotNil(service.cache)

            try service.clean()
            
            XCTAssertNil(service.read())
            XCTAssertNil(service.cache)
            
        } catch {
            
            XCTFail()
        }
    }
    
    func testSave() {
        
        let tempDir = NSURL(fileURLWithPath: NSTemporaryDirectory())
        let tempFile = tempDir.URLByAppendingPathComponent(__FUNCTION__)
        let tempText = "🐙🐍🐙🐍🐙🐍🐙🐍🐙🐍🐙🐍🐙🐍"
        
        let service = FileStoreService(storeName: storeName)
        service.fileExtension = fileExtension
        _ = try? service.clean()
        
        do {
            
            try tempText.writeToFile(tempFile.path!, atomically: true, encoding: NSUnicodeStringEncoding)
            let file = try service.save(tempFile)
            
            print("\(tempText) went here: \(file)")
            
            let around = NSString(data: service.read()!, encoding: NSUnicodeStringEncoding)
            XCTAssertEqual(tempText, around)
            
            let data = NSData(contentsOfURL: file)
            let bround = NSString(data: data!, encoding: NSUnicodeStringEncoding)
            XCTAssertEqual(tempText, bround)
            
        } catch {
            
            XCTFail()
        }
    }
    
    func testValidate() {
        
        let tempDir = NSURL(fileURLWithPath: NSTemporaryDirectory())
        let tempFile = tempDir.URLByAppendingPathComponent(__FUNCTION__)
        let tempText = "🐠🐩🐿🍯🐠🐩🐿🍯🐠🐩🐿🍯🐠🐩🐿🍯"
        
        let service = FileStoreService(storeName: storeName) {data in
            
            return data.length > 0
        }
        service.fileExtension = fileExtension
        _ = try? service.clean()

        do {
            
            try tempText.writeToFile(tempFile.path!, atomically: true, encoding: NSUnicodeStringEncoding)
            let file = try service.save(tempFile)
            XCTAssertNotEqual(file, tempFile)
            
            let around = NSString(data: service.read()!, encoding: NSUnicodeStringEncoding)
            XCTAssertEqual(tempText, around)
            
        } catch {
            
            XCTFail()
        }
    }
    
    func testFailValidate() {
        
        let tempDir = NSURL(fileURLWithPath: NSTemporaryDirectory())
        let tempFile = tempDir.URLByAppendingPathComponent(__FUNCTION__)
        let tempText = "🌽🍳🍱🍞🧀🍆🌽🍳🍱🍞🧀🍆🌽🍳🍱🍞🧀🍆"
        
        let service = FileStoreService(storeName: storeName) {data in
            
            if let test = NSString(data: data, encoding: NSUnicodeStringEncoding) {
            
                return test.containsString("🐸🐸🐸")
            }
            
            return false
        }
        service.fileExtension = fileExtension
        
        do {
            
            try tempText.writeToFile(tempFile.path!, atomically: true, encoding: NSUnicodeStringEncoding)
            let file = try service.save(tempFile)
            XCTAssertEqual(file, tempFile)
            XCTAssertNil(service.read())
            
        } catch {
            
            XCTFail()
        }
    }
}
