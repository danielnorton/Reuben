//
//  LoginViewControllerUnitTests.swift
//  Reuben
//
//  Created by Daniel Norton on 9/13/15.
//  Copyright © 2015 Daniel Norton. All rights reserved.
//

@testable import Reuben
import UIKit
import XCTest

class LoginViewControllerUnitTests: XCTestCase {
    
    var controller: LoginViewController?
    
    override func setUp() {
        super.setUp()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let name = (NSStringFromClass(LoginViewController.self) as NSString).pathExtension
        if let vc = storyboard.instantiateViewControllerWithIdentifier(name) as? LoginViewController {
            
            self.controller = vc
            XCTAssertNotNil(vc.view, "no view")
            
        } else {
            
            XCTAssert(false, "no view controller")
        }
    }
    
    func testStartupDependancies() {
        
        if let vc = controller {
        
            XCTAssertNotNil(vc.userNameTextField, "no user name text field")
            XCTAssertNotNil(vc.passwordTextField, "no password text field")
        }
    }
}
