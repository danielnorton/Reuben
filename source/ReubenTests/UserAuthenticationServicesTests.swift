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
    let user = "user"
    let password = "password"
    var uaSaveFailObserver: NSObjectProtocol?
    
    override func setUp() {
        
        let service = CredentialStore.sharedStore()
        service.save(user, serviceName: hasAccountService, password: password)
        service.remove(user, serviceName: noAccountService)
    }
    
    override func tearDown() {
        
        let service = CredentialStore.sharedStore()
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
    
    func testLogin() {
        
        let identifier = __FUNCTION__
        let waitHandler = self.expectationWithDescription(identifier)
        
        let service = UserAuthenticationServices(hasAccountService)
        
        uaSaveFailObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            UserAuthenticationServices.SaveFailNotification,
            object: nil,
            queue: NSOperationQueue.currentQueue()) { (notification) -> Void in

                self.uaSaveFailObserver = nil
                waitHandler.fulfill()
        }
        
        service.login("fred", password: "fred")
        self.waitForExpectationsWithTimeout(120.0, handler: nil)
    }
}
