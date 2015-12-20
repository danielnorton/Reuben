//
//  APIBackgroundTests.swift
//  Reuben
//
//  Created by Daniel Norton on 8/5/15.
//  Copyright © 2015 Daniel Norton. All rights reserved.
//


import UIKit
import XCTest
@testable import Reuben


class BackgroundSessionDelegateTests: XCTestCase {

    
    func testCreateSessionForUrl() {
        
        var count = BackgroundSessionDelegate.sessions.count
        let firstUrl = NSURL(string: "https://www.\(__FUNCTION__).com/file.pdf")!
        let secondUrl = NSURL(string: "https://www.\(__FUNCTION__).com/file.zip")!
        let differentDomain = NSURL(string: "https://www.\(__FUNCTION__).tv/index.html")!
        let hasNoHostUrl = NSURL(fileURLWithPath: "file://Users/fred/Downloads/stuff.pdf")
        
        
        _ = BackgroundSessionDelegate.structuresForUrl(firstUrl)
        XCTAssertEqual(++count, BackgroundSessionDelegate.sessions.count, "expected to increment sessions count for first encounter of \(firstUrl.host)")

        _ = BackgroundSessionDelegate.structuresForUrl(firstUrl)
        XCTAssertEqual(count, BackgroundSessionDelegate.sessions.count, "expected to not increment sessions count for subsequent encounter of \(firstUrl.host)")
        
        _ = BackgroundSessionDelegate.structuresForUrl(secondUrl)
        XCTAssertEqual(count, BackgroundSessionDelegate.sessions.count, "expected to not increment sessions count for subsequent encounter of \(secondUrl.host)")
        
        _ = BackgroundSessionDelegate.structuresForUrl(secondUrl)
        XCTAssertEqual(count, BackgroundSessionDelegate.sessions.count, "expected to not increment sessions count for subsequent encounter of \(secondUrl.host)")
        
        _ = BackgroundSessionDelegate.structuresForUrl(differentDomain)
        XCTAssertEqual(++count, BackgroundSessionDelegate.sessions.count, "expected to increment sessions count for first encounter of \(differentDomain.host)")
        
        _ = BackgroundSessionDelegate.structuresForUrl(differentDomain)
        XCTAssertEqual(count, BackgroundSessionDelegate.sessions.count, "expected to not increment sessions count for subsequent encounter of \(differentDomain.host)")
        
        _ = BackgroundSessionDelegate.structuresForUrl(hasNoHostUrl)
        XCTAssertEqual(++count, BackgroundSessionDelegate.sessions.count, "expected to increment sessions count for first encounter of \(hasNoHostUrl.absoluteString)")
        
        _ = BackgroundSessionDelegate.structuresForUrl(hasNoHostUrl)
        XCTAssertEqual(count, BackgroundSessionDelegate.sessions.count, "expected to not increment sessions count for subsequent encounter of \(hasNoHostUrl.absoluteString)")
    }
    
    func testCreateSessionForIdentifier() {
        
        var count = BackgroundSessionDelegate.sessions.count
        let identifier = __FUNCTION__
        
        _ = BackgroundSessionDelegate.structuresForIdentifier(identifier)
        XCTAssertEqual(++count, BackgroundSessionDelegate.sessions.count, "expected to increment sessions count")
        
        _ = BackgroundSessionDelegate.structuresForIdentifier(identifier)
        XCTAssertEqual(count, BackgroundSessionDelegate.sessions.count, "expected to not increment sessions count")
    }
    
    func testSmallDownload() {
        
        let identifier = __FUNCTION__
        let waitHandler = self.expectationWithDescription(identifier)
        let (session, delegate) = BackgroundSessionDelegate.structuresForIdentifier(identifier)
        delegate.completion = {(task: NSURLSessionDownloadTask, url: NSURL) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                print("\(NSDate()) - finish \(identifier)")
                waitHandler.fulfill()
            })
        }
        
        let url = NSURL(string: "https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.pdf")!
        let request = NSMutableURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 30)
        
        let task = session.downloadTaskWithRequest(request)
        
        print("\(NSDate()) - start \(identifier)")
        task.resume()
        self.waitForExpectationsWithTimeout(120.0, handler: nil)
    }
}
