//
//  LoginViewController.swift
//  Reuben
//
//  Created by Daniel Norton on 9/12/15.
//  Copyright © 2015 Daniel Norton. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var keyboardChangeObserver: NSObjectProtocol?
    var keyboardHideObserver: NSObjectProtocol?
    
    // MARK: -
    // MARK: UIViewController
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        keyboardChangeObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            UIKeyboardWillChangeFrameNotification,
            object: nil,
            queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
                
                let info = notification.userInfo!
                let eFv = info[UIKeyboardFrameEndUserInfoKey] as! NSValue
                let eF = eFv.CGRectValue()
                let i = self.scrollView.contentInset
                let nI = UIEdgeInsets(top: i.top, left: i.left, bottom: eF.height, right: i.right)
                self.scrollView.contentInset = nI
                self.scrollView.scrollIndicatorInsets = nI
                self.scrollView.contentOffset = CGPoint(x: 0.0, y: eF.height / 2.0)
        }
        
        keyboardHideObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            UIKeyboardWillHideNotification,
            object: nil,
            queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
                
                self.scrollView.contentInset = UIEdgeInsetsZero
                self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero
                self.scrollView.contentOffset = CGPointZero
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        if let change = keyboardChangeObserver {
            
            NSNotificationCenter.defaultCenter().removeObserver(change)
            self.keyboardChangeObserver = nil
        }
        
        if let hide = keyboardHideObserver {
            
            NSNotificationCenter.defaultCenter().removeObserver(hide)
            self.keyboardHideObserver = nil
        }
    }
    
    // MARK: -
    // MARK: ViewController
    @IBAction func didTapOutsideView(sender: UITapGestureRecognizer) {
        
        self.userNameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
}

