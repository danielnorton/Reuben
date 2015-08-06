//
//  APIBackgroundTests.swift
//  Reuben
//
//  Created by Daniel Norton on 8/5/15.
//  Copyright © 2015 Daniel Norton. All rights reserved.
//

@testable import Reuben
import UIKit
import XCTest

class APIBackgroundTests: XCTestCase {

    
    
    func testCreateSession() {
        
        XCTAssertEqual(0, BackgroundSessionDelegate.sessions.count, "not zero sessions")
        let identifier = __FUNCTION__
        
        _ = BackgroundSessionDelegate.structuresForIdentifier(identifier)
        XCTAssertEqual(1, BackgroundSessionDelegate.sessions.count, "not one session")
        
        _ = BackgroundSessionDelegate.structuresForIdentifier(identifier)
        XCTAssertEqual(1, BackgroundSessionDelegate.sessions.count, "not one session")
    }
    
    func testSmallDownload() {
        
        let identifier = __FUNCTION__
        let waitHandler = self.expectationWithDescription(identifier)
        let (session, delegate) = BackgroundSessionDelegate.structuresForIdentifier(identifier)
        delegate.completion = {(url: NSURL) in
            
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
    
    func testLargeDownload() {
        
        let identifier = __FUNCTION__
        let waitHandler = self.expectationWithDescription(identifier)
        let (session, delegate) = BackgroundSessionDelegate.structuresForIdentifier(identifier)
        delegate.completion = {(url: NSURL) in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                print("\(NSDate()) - finish \(identifier)")
                waitHandler.fulfill()
            })
        }
        
        let url = NSURL(string: "https://developer.apple.com/library/ios/samplecode/MetalVideoCapture/MetalVideoCapture.zip")!
        let request = NSMutableURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 30)

        let task = session.downloadTaskWithRequest(request)
        
        print("\(NSDate()) - start \(identifier)")
        task.resume()
        self.waitForExpectationsWithTimeout(120.0, handler: nil)
    }
}
