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
    
    static let defaultServiceName = "Reuben.UserAuthenticationServices"
    let securityServiceName: String
    internal static let tokenName = "Reuben.UserAuthenticationServices.Token"
    

    private let storeService: FileStoreService = {
        
        let storeName = NSStringFromClass(UserAuthenticationServices)
        let service = FileStoreService(storeName: storeName, validate: UserAuthenticationServices.validate)
        service.useCache = true
        service.fileExtension = "json"
        
        return service
    }()
    
    // MARK: - init
    init(_ securityServiceName: String) {
        
        self.securityServiceName = securityServiceName
    }
    
    
    // MARK: - UserAuthenticationServices
    // MARK: Public Functions
    var hasUser: Bool {

        get {
            
            var answer = false
            
            if let (userName, _) = readUser() {
            
                let service = CredentialStore.sharedStore()
                service.find(userName
                    , serviceName: securityServiceName
                    , attributes: true
                    , foundAction: { (_) -> Void in

                        answer = true
                        
                    }, notFoundAction: nil)
                
                return answer
            }
            
            return false
        }
    }
    
    func logout() {
        
        if !self.hasUser { return }
        
        let service = CredentialStore.sharedStore()
        service.remove(UserAuthenticationServices.tokenName, serviceName: securityServiceName)
        
        _ = try? storeService.clean()
    }
    
    func login(userName: String, password: String) {

        let url = NSURL(string: "https://api.github.com/user")!
        let (session, delegate) = BackgroundSessionDelegate.structuresForUrl(url)
        delegate.completion = {(task: NSURLSessionDownloadTask, url: NSURL) in
            
            if let response = task.response as? NSHTTPURLResponse {
                
                if response.statusCode != 200 {
                    
                    UserAuthenticationServices.notifySaveFail(userName)
                    
                } else {

                    do {
                        
                        try self.storeService.save(url)
                        let service = CredentialStore.sharedStore()
                        service.save(userName, serviceName: self.securityServiceName, password: password)
                        
                    } catch {
                        
                        UserAuthenticationServices.notifySaveFail(userName)
                    }

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
    
    
    // MARK: Private Functions
    static func validate(data: NSData) -> Bool {
        
        do {
            
            if let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))  as? Dictionary<String, AnyObject> where
                (json.indexForKey("login") != nil),
                let _ = json["login"] as? String where
                (json.indexForKey("avatar_url") != nil),
                let _ = json["avatar_url"] as? String {
                    
                    return true
            }
        } catch { }
        
        return false
    }
    
    func readUser() -> (userName: String, avatarURL: NSURL)? {
        
        do {

            if let data = storeService.read(),
                json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))  as? Dictionary<String, AnyObject> where
                (json.indexForKey("login") != nil),
                let userName = json["login"] as? String where
                (json.indexForKey("avatar_url") != nil),
                let avatarPath = json["avatar_url"] as? String {
                    
                    return (userName, NSURL(fileURLWithPath: avatarPath))
            }
        } catch { }
        
        return nil
    }
    
    private static func notifySave(userName: String) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(SaveNotification, object: self, userInfo: [SaveNotificationUserName: userName])
    }
    
    private static func notifySaveFail(userName: String) {
        
        NSNotificationCenter.defaultCenter().postNotificationName(SaveFailNotification, object: self, userInfo: [SaveNotificationUserName: userName])
    }
}
