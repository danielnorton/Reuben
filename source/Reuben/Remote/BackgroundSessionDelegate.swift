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
    static private(set) var systemCompletionHandlers: Dictionary = Dictionary<String, (() -> Void)>()
    
    var completion: ((NSURLSessionDownloadTask, NSURL) -> Void)?
    var systemCompletionHandler: (() -> Void)?
    
    
    // MARK: - NSURLSessionDelegate
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {

        print(__FUNCTION__)
        popSystemCompletionHandler(session.configuration.identifier)
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {

        print(__FUNCTION__)
//        session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) -> Void in
//            
//            let counts = dataTasks.count + uploadTasks.count + downloadTasks.count
//            print("\(__FUNCTION__) : \(counts)")
//            if counts == 0 {
//                
//                self.popSystemCompletionHandler(session.configuration.identifier)
//            }
//        }
    }
    
    
    // MARK: - NSURLSessionDownloadDelegate
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        print(__FUNCTION__)
        if let comp = self.completion {
            
            comp(downloadTask, location)
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let percent = (Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)) * 100.0
        let message = String(format: "%.2f%%", percent)
        print("\(__FUNCTION__) : \(message)")
    }

    
    // MARK: - BackgroundSession
    // MARK: static functions
    static func structuresForIdentifier(identifier: String) -> (NSURLSession, BackgroundSessionDelegate) {
        
        print("\(__FUNCTION__) : \(identifier)")
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
        
        print("\(__FUNCTION__) : \(identifier)")
//        assert(!systemCompletionHandlers.keys.contains(identifier))
        
        systemCompletionHandlers[identifier] = completionHandler
    }
    
    
    // MARK: private functions
    private func popSystemCompletionHandler(identifier: String?) {
        
        print(__FUNCTION__)
        if let identifier = identifier, handler = BackgroundSessionDelegate.systemCompletionHandlers.removeValueForKey(identifier) {

            handler()
        }
    }
}
