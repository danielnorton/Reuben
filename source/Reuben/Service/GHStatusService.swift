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
    static let SaveNotificationFileName = "notificationSaveFileName"
    
    static var latestCache: (status: String, lastUpdated: NSDate)?
    
    // MARK: - GHStatusService
    // MARK: public static properties
    static let dateFormatter: NSDateFormatter = {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd\'T\'HH:mm:ssZ"
        return formatter
    }()
    
    
    // MARK: public static functions
    static func cleanAndSave(tempFile: NSURL) throws -> Bool {
    
        if let data = NSData(contentsOfURL: tempFile) {

            if self.validate(data) {
         
                try self.clean()
                try self.save(tempFile)
                
                return true
                
            }
        }
        return false
    }
    
    static func validate(data: NSData) -> Bool {
        
        var status = false
        var statusValue = false
        var lastUpdated = false
        var lastUpdatedValue = false

        do {
            
            let deserialized = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
            if let json = deserialized as? Dictionary<String, AnyObject> {
             
                if (json.indexForKey("status") != nil) { status = true }
                if let _ = json["status"] as? String {
                    
                    statusValue = true
                }
                
                if (json.indexForKey("last_updated") != nil) { lastUpdated = true }
                if let updated = json["last_updated"] as? String {
                    
                    if let _ = self.dateFormatter.dateFromString(updated) {
                        
                        lastUpdatedValue = true
                    }
                }
            }
            
        } catch {}
        
        return status && statusValue && lastUpdated && lastUpdatedValue
    }
    
    static func clean() throws {
        
        self.clearBackgroundFetchInterval()
        latestCache = nil
        let fm = NSFileManager.defaultManager()
        
        do {
            
            let files = try fm.contentsOfDirectoryAtURL(self.store, includingPropertiesForKeys: [], options: .SkipsSubdirectoryDescendants)
            for file in files {
                
                try fm.removeItemAtURL(file)
            }
        }
    }
    
    static func refresh(completionHandler: ((UIBackgroundFetchResult) -> Void)?) {
        
        let url = NSURL(string: "https://status.github.com/api/status.json")!
        let (session, delegate) = BackgroundSessionDelegate.structuresForUrl(url)
        delegate.completion = {(task: NSURLSessionDownloadTask, url: NSURL) in
            
            do {
                
                self.beginBackgroundFetchInterval()
                try self.save(url)
                latestCache = nil
                latestCache = readLatest()
                if let handler = completionHandler {
                
                    handler(.NewData)
                }
                NSLog("📯📯 %@ %@ success", NSStringFromClass(self), __FUNCTION__)
                
            } catch {

                NSLog("📯📯😡 %@ %@ failed", NSStringFromClass(self), __FUNCTION__)
                
                if let handler = completionHandler {
                    
                    handler(.Failed)
                }
            }
        }
        
        let request = NSMutableURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 30)
        let task = session.downloadTaskWithRequest(request)
        task.resume()
    }
    
    static func readLatest() -> (status: String, lastUpdated: NSDate)? {
        
        if latestCache != nil {
            
            return latestCache
        }
        
        let fm = NSFileManager.defaultManager()
        
        do {
            
            let files = try fm.contentsOfDirectoryAtURL(self.store, includingPropertiesForKeys: [NSURLContentModificationDateKey], options: .SkipsSubdirectoryDescendants)
            
            let fileProps = files.sort({ (first, second) -> Bool in
                
                do {
                    
                    var firstResource: AnyObject?
                    try first.getResourceValue(&firstResource, forKey: NSURLContentModificationDateKey)
                    var secondResource: AnyObject?
                    try second.getResourceValue(&secondResource, forKey: NSURLContentModificationDateKey)
                    
                    if let firstDate = firstResource as? NSDate, let secondDate = secondResource as? NSDate {
                        
                        return firstDate.compare(secondDate) != NSComparisonResult.OrderedDescending
                    }
                    
                } catch {
                    
                }
                
                return false
            })
            
            if let file = fileProps.last {

                return try read(file)
            }
            
        } catch {
            
        }

        return nil
    }
    
    static func read(file: NSURL) throws -> (status: String, lastUpdated: NSDate)? {

        if let data = NSData(contentsOfURL: file) {
            
            if self.validate(data) {
                
                let deserialized = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
                if let json =  deserialized as? Dictionary<String, AnyObject> {
                    
                    let date = self.dateFormatter.dateFromString(json["last_updated"] as! String)!
                    return (json["status"] as! String, date)
                }
            }
        }
        
        return nil
    }
    
    static func clearBackgroundFetchInterval() {
        
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
    }
    
    static func beginBackgroundFetchInterval() {
        
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
    }
    
    
    // MARK: private static properties
    private static let store: NSURL = {

        let fm = NSFileManager.defaultManager()
        let urls = fm.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        if let url = urls.first {
            
            let fullPath = url.URLByAppendingPathComponent(NSStringFromClass(GHStatusService))
            
            do {
                
                _ = try fm.createDirectoryAtURL(fullPath, withIntermediateDirectories: true, attributes: nil)
                return fullPath
                
            } catch {

            }
        }
        
        return NSURL(fileURLWithPath: NSTemporaryDirectory())
    }()

    
    // MARK: private static functions
    private static func save(tempFile: NSURL) throws {
    
        let fm = NSFileManager.defaultManager()
        let name = NSUUID().UUIDString
        let newName = self.store.URLByAppendingPathComponent("\(name).json")
        NSLog("📯📯 %@ %@ to %@", NSStringFromClass(self), __FUNCTION__, newName.absoluteString)
        
        if fm.fileExistsAtPath(newName.absoluteString) {
        
            try fm.removeItemAtPath(newName.absoluteString)
        }
        
        try fm.moveItemAtURL(tempFile, toURL: newName)
        self.notifySave(newName)
        
    }
    
    private static func notifySave(file: NSURL) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(SaveNotification, object: self, userInfo: [SaveNotificationFileName: file])
    }
}