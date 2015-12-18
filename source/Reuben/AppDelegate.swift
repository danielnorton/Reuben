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

    // MARK: -
    // MARK: UIApplicationDelegate
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {

        GHStatusService.refresh(completionHandler)
    }
}

