//
//  BackgroundSession.swift
//  Reuben
//
//  Created by Daniel Norton on 8/5/15.
//  Copyright © 2015 Daniel Norton. All rights reserved.
//

import UIKit

class BackgroundSessionDelegate: NSObject, NSURLSessionDelegate {

    static private(set) var sessions: Dictionary = Dictionary<String, NSURLSession>()
    
    var completion: ((NSURL) -> Void)?
    
    
    // MARK: - NSURLSessionDataDelegate
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        if let comp = self.completion {
            
            comp(location)
        }
    }

    
    // MARK: - BackgroundSession
    // MARK: static functions
    static func structuresForIdentifier(identifier: String) -> (NSURLSession, BackgroundSessionDelegate) {
        
        if let session = sessions[identifier] {

            return (session, session.delegate as! BackgroundSessionDelegate)
            
        } else {
         
            let delegate = BackgroundSessionDelegate()
            let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(identifier)
            let session = NSURLSession(configuration: config, delegate: delegate, delegateQueue: NSOperationQueue())
            sessions[identifier] = session
            return (session, delegate)
        }
    }
}
