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
    var uaSaveObserver: NSObjectProtocol?
    var uaSaveFailObserver: NSObjectProtocol?
    

    // MARK: -
    // MARK: UIViewController
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setupObservers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        tearDownObservers()
    }
    
    
    // MARK: -
    // MARK: LoginViewController
    // MARK: IBActions
    @IBAction func didTapOutsideView(sender: UITapGestureRecognizer) {
        
        dismissKeyboard()
    }
    
    
    @IBAction func didTapCancel(sender: UITapGestureRecognizer) {
    
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapSubmit(sender: UIButton) {
        
        let service = UserAuthenticationServices(UserAuthenticationServices.defaultServiceName)
        service.login(userNameTextField.text!, password: passwordTextField.text!)
    }
    
    
    
    // MARK: Private Functions
    private func setupObservers() {
        
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
        
        uaSaveObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            UserAuthenticationServices.SaveNotification,
            object: nil,
            queue: NSOperationQueue.currentQueue()) { (notification) -> Void in
                
                NSLog("👒👒 LoginViewController received: %@", UserAuthenticationServices.SaveNotification)
        }
        
        uaSaveFailObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            UserAuthenticationServices.SaveFailNotification,
            object: nil,
            queue: NSOperationQueue.currentQueue()) { (notification) -> Void in
                
                NSLog("👒👒🦀🦀 LoginViewController received: %@", UserAuthenticationServices.SaveNotification)
        }
    }
    
    private func tearDownObservers() {
        
        if let change = keyboardChangeObserver {
            
            NSNotificationCenter.defaultCenter().removeObserver(change)
            self.keyboardChangeObserver = nil
        }
        
        if let hide = keyboardHideObserver {
            
            NSNotificationCenter.defaultCenter().removeObserver(hide)
            self.keyboardHideObserver = nil
        }
    }
    
    private func dismissKeyboard() {
        
        userNameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
}

