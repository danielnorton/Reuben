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
    func applicationDidEnterBackground(application: UIApplication) {
        
        print("applicationDidEnterBackground")
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        
        print("applicationWillEnterForeground")
    }
}

