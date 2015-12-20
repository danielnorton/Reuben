//
//  credentialStoreTests.swift
//  Reuben
//
//  Created by Daniel Norton on 4/13/15.
//  Copyright (c) 2015 Daniel Norton. All rights reserved.
//


import UIKit
import XCTest
@testable import Reuben


class CredentialStoreTests: XCTestCase {

    let readName = "readUser"
    let writeName = "writeUser"
    let serviceName = "credentialStoreTests"
    let password = "password"
    
    override func setUp() {
        super.setUp()
        
        let service = CredentialStore.sharedStore()
        service.save(readName, serviceName: serviceName, password: password)
    }
    
    override func tearDown() {
        
        let service = CredentialStore.sharedStore()
        service.remove(readName, serviceName: serviceName)
        service.remove(writeName, serviceName: serviceName)
        
        super.tearDown()
    }
    
    func testWriteCredential() {
        
        let service = CredentialStore.sharedStore()
        service.save(writeName, serviceName: serviceName, password: password)
        
        let answer = service.read(writeName, serviceName: serviceName)
        XCTAssertNotNil(answer, "Didn't write password")
    }
    
    func testReadCredential() {
        
        let service = CredentialStore.sharedStore()
        if let answer = service.read(readName, serviceName: serviceName) {
            
            XCTAssertEqual(answer, password)
            
        } else {
        
            XCTAssert(false, "Didn't read password")
        }
    }
    
    func testRemoveCredential() {
        
        let service = CredentialStore.sharedStore()
        service.remove(readName, serviceName: serviceName)
        if let _ = service.read(readName, serviceName: serviceName) {
            
            XCTAssert(false, "Didn't remove credential")
        }
    }
}
