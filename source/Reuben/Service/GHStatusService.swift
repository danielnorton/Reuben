//
//  GHStatusService.swift
//  Reuben
//
//  Created by Daniel Norton on 10/14/15.
//  Copyright © 2015 Daniel Norton. All rights reserved.
//

import Foundation
import UIKit

class GHStatusService {

    static let SaveNotification = "GHStatusService.Notification.Save"
    static let SaveNotificationFileName = "GHStatusService.Notification.Save.FileName"
    
    private let storeService: FileStoreService = {
       
        let storeName = NSStringFromClass(GHStatusService)
        return FileStoreService(storeName: storeName, validate: GHStatusService.validate)
    }()
    
    static let dateFormatter: NSDateFormatter = {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd\'T\'HH:mm:ssZ"
        return formatter
    }()

    static func validate(data: NSData) -> Bool {

        do {
            
            if let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))  as? Dictionary<String, AnyObject> where
                (json.indexForKey("status") != nil),
                let _ = json["status"] as? String where
                (json.indexForKey("last_updated") != nil),
                let rawLast = json["last_updated"] as? String,
                let _ = GHStatusService.dateFormatter.dateFromString(rawLast) {
                    
                    return true
            }
        } catch { }
        
        return false
    }
    
    func refresh(completionHandler: ((UIBackgroundFetchResult) -> Void)?) {
        
        let url = NSURL(string: "https://status.github.com/api/status.json")!
        let (session, delegate) = BackgroundSessionDelegate.structuresForUrl(url)
        delegate.completion = {(task: NSURLSessionDownloadTask, url: NSURL) in

            let service = self.storeService
            self.beginBackgroundFetchInterval()
            
            do {

                let newUrl = try service.save(url)
                self.notifySave(newUrl)
                if let handler = completionHandler {
                    
                    handler(.NewData)
                }

            } catch {
                
                if let handler = completionHandler {
                    
                    handler(.Failed)
                }
            }
        }
        
        let request = NSMutableURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 30)
        let task = session.downloadTaskWithRequest(request)
        task.resume()
    }
    
    func clean() throws {
        
        try storeService.clean()
    }
    
    func cleanAndSave(tempFile: NSURL) throws -> Bool{
        
        return try storeService.cleanAndSave(tempFile)
    }
    
    func flushCache() {
        
        storeService.flushCache()
    }
    
    func read() -> (status: String, lastUpdated: NSDate)? {
        
        do {
            
            if let data = storeService.read(),
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))  as? Dictionary<String, AnyObject> where
                (json.indexForKey("status") != nil),
                let status = json["status"] as? String where
                (json.indexForKey("last_updated") != nil),
                let rawLast = json["last_updated"] as? String,
                let last = GHStatusService.dateFormatter.dateFromString(rawLast) {
                
                return (status, last)
            }
            
        } catch { }
        
        return nil
    }
    
    func clearBackgroundFetchInterval() {
        
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
    }
    
    func beginBackgroundFetchInterval() {
        
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
    }
    
    func notifySave(file: NSURL) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(GHStatusService.SaveNotification, object: self, userInfo: [GHStatusService.SaveNotificationFileName: file])
    }
}