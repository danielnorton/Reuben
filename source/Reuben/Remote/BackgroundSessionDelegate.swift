//
//  BackgroundSession.swift
//  Reuben
//
//  Created by Daniel Norton on 8/5/15.
//  Copyright © 2015 Daniel Norton. All rights reserved.
//

import UIKit

class BackgroundSessionDelegate: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate {
    
    static private(set) var sessions: Dictionary<String, NSURLSession> = Dictionary<String, NSURLSession>()
    static private(set) var systemCompletionHandlers: Dictionary<String, (() -> Void)> = Dictionary<String, (() -> Void)>()
    
    var completion: ((NSURLSessionDownloadTask, NSURL) -> Void)?
    var challenge: (() -> (String, String)?)?
    var systemCompletionHandler: (() -> Void)?
    
    
    // MARK: - NSURLSessionDelegate
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        
        popSystemCompletionHandler(session.configuration.identifier)
    }
    
    
    // MARK: - NSURLSessionDownloadDelegate
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {

        NSLog("🐕🐕 %@ From: %@   to: %@", __FUNCTION__, downloadTask.currentRequest!.URL!.absoluteString, location.absoluteString)
        if let comp = self.completion {
            
            self.completion = nil
            comp(downloadTask, location)
        }
    }
    
    
    // MARK: - NSURLSessionTaskDelegate
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void) {
        
        NSLog("🐕🐕 %@", __FUNCTION__)
        if let challenge = self.challenge, let (userName, password) = challenge() {

            let cred = NSURLCredential(user: userName, password: password, persistence: .None)
            completionHandler(NSURLSessionAuthChallengeDisposition.UseCredential, cred)
            
        } else {
            
            completionHandler(NSURLSessionAuthChallengeDisposition.CancelAuthenticationChallenge, nil)
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
    
    static func structuresForUrl(url: NSURL) -> (NSURLSession, BackgroundSessionDelegate) {
        
        if let identifier = url.host {
            
            return structuresForIdentifier(identifier)
            
        } else {
            
            return structuresForIdentifier(url.absoluteString)
        }
    }
    
    static func setSystemCompletionHandler(completionHandler: () -> Void, forIdentifier identifier: String) {
        
        systemCompletionHandlers[identifier] = completionHandler
    }
    
    
    // MARK: private functions
    private func popSystemCompletionHandler(identifier: String?) {
        
        if let identifier = identifier, handler = BackgroundSessionDelegate.systemCompletionHandlers.removeValueForKey(identifier) {
            
            handler()
        }
    }
}
