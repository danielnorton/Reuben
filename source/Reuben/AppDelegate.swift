//
//  AppDelegate.swift
//  Reuben
//
//  Created by Daniel Norton on 4/10/15.
//  Copyright (c) 2015 Daniel Norton. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // MARK: - UIApplicationDelegate
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {

        print("\(__FUNCTION__) : launchOptions: \(launchOptions)")
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        return true;
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        print(__FUNCTION__)
        
        // TODO: 👦🏽 this works, but is turned off while I figure out the other background transfer
        performBackgroundFetchTest(completionHandler)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        
        print(__FUNCTION__)
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        
        print(__FUNCTION__)
    }

    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        
        print("🎯🎯🎯🎯 \(__FUNCTION__) : \(identifier)")
        BackgroundSessionDelegate.setSystemCompletionHandler(completionHandler, forIdentifier: identifier)
        _ = BackgroundSessionDelegate.structuresForIdentifier(identifier)
    }
    
    
    // MARK: - Private Functions
    private func performBackgroundFetchTest(completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        let url = NSURL(string: "https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.pdf")!
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
//        let (session, delegate) = BackgroundSessionDelegate.structuresForUrl(url)
//
//        delegate.completion = {(task: NSURLSessionDownloadTask, url: NSURL) in
//            
//            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
//            if let fileName = task.originalRequest?.URL?.lastPathComponent {
//                
//                let newName = documentsPath.stringByAppendingPathComponent(fileName)
//                let newUrl = NSURL(fileURLWithPath: newName)
//                let mgr = NSFileManager()
//                
//                if mgr.fileExistsAtPath(newName) {
//                    
//                    do {
//                        
//                        try mgr.removeItemAtURL(newUrl)
//                        
//                        
//                    } catch { }
//                }
//                
//                do {
//                    
//                    try mgr.moveItemAtURL(url, toURL: newUrl)
//                    print("\(NSDate()) - finish \(url.absoluteString) - \(newUrl.absoluteString)")
//                    
//                } catch {
//                    
//                    print("\(NSDate()) - 😨😨😨 FAILED!! Moving \(url.absoluteString) to \(newUrl.absoluteString)")
//                    
//                }
//            }
//            
//            completionHandler(.NewData)
//        }
        
        let request = NSMutableURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 30)
        
        let task = session.dataTaskWithRequest(request) { (data, _, error) -> Void in
            
            if (error === nil) {
                
                completionHandler(.Failed)
                return
            }
            
            let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            
            print("completionHandler(.NewData)")
            completionHandler(.NewData)
        }
        
        print("\(NSDate()) - start \(url.host!)")
        task.resume()
    }
}

