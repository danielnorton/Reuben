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
    func applicationDidFinishLaunching(application: UIApplication) {
    
        print(__FUNCTION__)
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
}

