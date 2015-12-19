//
//  CredentialStore.swift
//  Reuben
//
//  Created by Daniel Norton on 4/13/15.
//  Copyright (c) 2015 Daniel Norton. All rights reserved.
//

import UIKit
import Security

struct CredentialStore {
   
    static let secClass = kSecClass as String
    static let secClassGenericPassword = kSecClassGenericPassword as String
    static let secAttrAccount = kSecAttrAccount as String
    static let secAttrService = kSecAttrService as String
    static let secMatchCaseInsensitive = kSecMatchCaseInsensitive as String
    static let secReturnAttributes = kSecReturnAttributes as String
    static let secReturnData = kSecReturnData as String
    static let secValueData = kSecValueData as String
    
    // MARK: -
    // MARK: CredentialStore
    // MARK: Public Functions
    static func sharedStore() -> CredentialStore.Type {
    
        return CredentialStore.self
    }
    
    static func save(userName: String, serviceName: String, password: String) {
        
        let data = password.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        if data == nil { return }

        self.find(userName
            , serviceName: serviceName
            , attributes: true
            , foundAction: { (answer: AnyObject) -> Void in

                var change: Dictionary<String, AnyObject> = answer as! Dictionary<String, AnyObject>
                change.updateValue(self.secClassGenericPassword, forKey: self.secClass)
                
                let changeData = [self.secValueData: data!]
                SecItemUpdate(changeData, change)
                
            }) { (query: Dictionary<String, AnyObject>) -> Void in
            
                var edit = query
                edit.removeValueForKey(self.secMatchCaseInsensitive)
                edit.removeValueForKey(self.secReturnAttributes)
                edit[self.secValueData] = data
                
                SecItemAdd(edit, nil)
        }
    }
    
    static func read(userName: String, serviceName: String) -> String? {
        
        var password: NSString?
        
        self.find(userName
            , serviceName: serviceName
            , attributes: false
            , foundAction: { (answer: AnyObject) -> Void in

                let data = answer as! NSData
                password = NSString(data: data, encoding: NSUTF8StringEncoding)
                
        }, notFoundAction: nil)
        
        return password as String?
    }
    
    static func remove(userName: String, serviceName: String) {
        
        self.find(userName
            , serviceName: serviceName
            , attributes: true
            , foundAction: { (answer: AnyObject) -> Void in
                
                var change: Dictionary<String, AnyObject> = answer as! Dictionary<String, AnyObject>
                change.updateValue(self.secClassGenericPassword, forKey: self.secClass)
                
                SecItemDelete(change)
                
            }, notFoundAction: nil)
    }
    
    
    //MARK: Private Functions
    private init() { }
    
    static func find(userName: String
        , serviceName: String
        , attributes: Bool
        , foundAction: ((AnyObject) -> Void)?
        , notFoundAction: ((Dictionary<String, AnyObject>) -> Void)?
        ) {

            let returnKey = attributes
                ? secReturnAttributes
                : secReturnData
        
            let query: Dictionary<String, AnyObject> = [
                secClass : secClassGenericPassword,
                secAttrAccount: userName,
                secAttrService: serviceName,
                secMatchCaseInsensitive: kCFBooleanTrue,
                returnKey: kCFBooleanTrue
            ]
            
            
            var found: UnsafeMutablePointer<AnyObject?> = UnsafeMutablePointer<AnyObject?>(nilLiteral: ())
            let err: OSStatus = withUnsafeMutablePointer(&found) { SecItemCopyMatching(query, UnsafeMutablePointer($0)) }
            if (err == noErr) {
                
                let unwrap = Unmanaged<AnyObject>.fromOpaque(COpaquePointer(found))
                let answer = unwrap.takeRetainedValue() as AnyObject
                if let action = foundAction  {
                    
                    action(answer)
                }
                
            } else {
                
                if let action = notFoundAction {
                    
                    action(query)
                }
            }
    }
}


