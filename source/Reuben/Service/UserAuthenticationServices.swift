//
//  UserAuthenticationServices.swift
//  Reuben
//
//  Created by Daniel Norton on 8/11/15.
//  Copyright © 2015 Daniel Norton. All rights reserved.
//

import UIKit

class UserAuthenticationServices {
    
    static let SaveNotification = "UserAuthenticationServices.Notification.Save"
    static let SaveFailNotification = "UserAuthenticationServices.Notification.Save.Fail"
    static let SaveNotificationUserName = "UserAuthenticationServices.Notification.Save.UserName"
    
    static let defaultServiceName = "Reuben OAuth"
    let securityServiceName: String
    internal static let tokenName = "Reuben User OAuth Token"
    
    
    // MARK: -
    // MARK: UserAuthenticationServices
    init(_ securityServiceName: String) {
        
        self.securityServiceName = securityServiceName
    }
    
    
    // MARK: Public Functions
    var hasUser: Bool {

        get {
            
            var answer = false
            
            let service = CredentialStore.sharedStore()
            service.find(UserAuthenticationServices.tokenName
                , serviceName: securityServiceName
                , attributes: true
                , foundAction: { (_) -> Void in

                    answer = true
                    
                }, notFoundAction: nil)
            
            return answer
        }
    }
    
    func logout() {
        
        if !self.hasUser { return }
        
        let service = CredentialStore.sharedStore()
        service.remove(UserAuthenticationServices.tokenName, serviceName: securityServiceName)
    }
    
    func login(userName: String, password: String) {

        let url = NSURL(string: "https://api.github.com/user")!
        let (session, delegate) = BackgroundSessionDelegate.structuresForUrl(url)
        delegate.completion = {(task: NSURLSessionDownloadTask, url: NSURL) in
            
            if let response = task.response as? NSHTTPURLResponse {
                
                if response.statusCode != 200 {
                    
                    UserAuthenticationServices.notifySaveFail(userName)
                    
                } else {
                    
                    let service = CredentialStore.sharedStore()
                    service.save(userName, serviceName: self.securityServiceName, password: password)
                    UserAuthenticationServices.notifySave(userName)
                }
            }
        }
        
        let request = NSMutableURLRequest(URL: url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: 30)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        let loginString = NSString(format: "%@:%@", userName, password)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue:0))
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        let task = session.downloadTaskWithRequest(request)
        task.resume()
    }
    
    var loginViewController: UIViewController {
        
        get {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            return storyboard.instantiateViewControllerWithIdentifier("LoginViewController")
        }
    }
    
    // MARK: private functions
    private static func notifySave(userName: String) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(SaveNotification, object: self, userInfo: [SaveNotificationUserName: userName])
    }
    
    private static func notifySaveFail(userName: String) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(SaveFailNotification, object: self, userInfo: [SaveNotificationUserName: userName])
    }
}
