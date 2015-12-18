//
//  UserAuthenticationServicesTests.swift
//  Reuben
//
//  Created by Daniel Norton on 8/11/15.
//  Copyright © 2015 Daniel Norton. All rights reserved.
//

import XCTest
@testable import Reuben

class UserAuthenticationServicesTests: XCTestCase {
    
    let noAccountService = "\(self.self)_noAccountService"
    let hasAccountService = "\(self.self)_hasAccountService"
    let user = UserAuthenticationServices.tokenName
    let password = "password"
    
    override func setUp() {
        
        let service = CredentialStore.self
        service.save(user, serviceName: hasAccountService, password: password)
        service.remove(user, serviceName: noAccountService)
    }
    
    override func tearDown() {
        
        let service = CredentialStore.self
        service.remove(user, serviceName: hasAccountService)
        service.remove(user, serviceName: noAccountService)
    }
    
    func testHasAccount() {
        
        let service = UserAuthenticationServices(hasAccountService)
        XCTAssert(service.hasUser)
    }
    
    func testDoesntHaveAccount() {
        
        let service = UserAuthenticationServices(noAccountService)
        XCTAssertFalse(service.hasUser)
    }
    
    func testLogout() {
        
        let service = UserAuthenticationServices(hasAccountService)
        service.logout()
        XCTAssertFalse(service.hasUser)
    }
    
    func testReLogout() {
        
        let service = UserAuthenticationServices(hasAccountService)
        service.logout()
        service.logout()
        XCTAssertFalse(service.hasUser)
    }
    
    func testFindController() {
        
        let service = UserAuthenticationServices(hasAccountService)
        
        let controller = service.loginViewController as? LoginViewController
        XCTAssert(controller != nil)
    }
}
