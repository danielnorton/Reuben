//
//  UserAuthenticationServices.swift
//  Reuben
//
//  Created by Daniel Norton on 8/11/15.
//  Copyright © 2015 Daniel Norton. All rights reserved.
//

import UIKit

class UserAuthenticationServices {
    
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
            
            let service = CredentialStore.self
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
        
        let service = CredentialStore.self
        service.remove(UserAuthenticationServices.tokenName, serviceName: securityServiceName)
    }
    
    var loginViewController: UIViewController {
        
        get {
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            return storyboard.instantiateViewControllerWithIdentifier("LoginViewController")
        }
    }
}
