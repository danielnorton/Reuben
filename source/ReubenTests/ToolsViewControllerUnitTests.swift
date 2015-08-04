//
//  ToolsViewControllerUnitTests.swift
//  Reuben
//
//  Created by Daniel Norton on 8/4/15.
//  Copyright © 2015 Daniel Norton. All rights reserved.
//

@testable import Reuben
import UIKit
import XCTest

class ToolsViewControllerUnitTests: XCTestCase {
    
    var tools: ToolsViewController?
    
    override func setUp() {
        super.setUp()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let name = NSStringFromClass(ToolsViewController.self).pathExtension
        if let vc = storyboard.instantiateViewControllerWithIdentifier(name) as? ToolsViewController {
         
            self.tools = vc
            
        } else {
            
            XCTAssert(false, "no view controller")
        }
    }

    func testStartupDependancies() {

        if let vc = tools {

            XCTAssertNotNil(vc.collectionView, "no CollectionView")
            XCTAssert(vc.collectionView?.delegate === vc, "view controller is not delegate")
            XCTAssert(vc.collectionView?.dataSource === vc, "view controller is not data source")
        }
    }
}
