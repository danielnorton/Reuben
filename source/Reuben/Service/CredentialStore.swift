//
//  CredentialStore.swift
//  Reuben
//
//  Created by Daniel Norton on 4/13/15.
//  Copyright (c) 2015 Daniel Norton. All rights reserved.
//

import UIKit
import Security

public class CredentialStore: NSObject {
   
    let secClass = String(format: kSecClass as String)
    let secClassGenericPassword = String(format: kSecClassGenericPassword as String)
    let secAttrAccount = String(format: kSecAttrAccount as String)
    let secAttrService = String(format: kSecAttrService as String)
    let secMatchCaseInsensitive = String(format: kSecMatchCaseInsensitive as String)
    let secReturnAttributes = String(format: kSecReturnAttributes as String)
    let secReturnData = String(format: kSecReturnData as String)
    let secValueData = String(format: kSecValueData as String)
    
    // MARK: -
    // MARK: CredentialStore
    // MARK: Public Methods
    public func save(userName: String, serviceName: String, password: String) {
        
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
    
    public func read(userName: String, serviceName: String) -> String? {
        
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
    
    public func remove(userName: String, serviceName: String) {
        
        self.find(userName
            , serviceName: serviceName
            , attributes: true
            , foundAction: { (answer: AnyObject) -> Void in
                
                var change: Dictionary<String, AnyObject> = answer as! Dictionary<String, AnyObject>
                change.updateValue(self.secClassGenericPassword, forKey: self.secClass)
                
                SecItemDelete(change)
                
            }, notFoundAction: nil)
    }
    
    
    //MARK: Private Methods
    func find(userName: String
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


