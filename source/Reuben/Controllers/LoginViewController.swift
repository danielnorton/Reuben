//
//  LoginViewController.swift
//  Reuben
//
//  Created by Daniel Norton on 9/12/15.
//  Copyright © 2015 Daniel Norton. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var login: UIButton!
    
    
    var keyboardChangeObserver: NSObjectProtocol?
    var keyboardHideObserver: NSObjectProtocol?
    var uaSaveObserver: NSObjectProtocol?
    var uaSaveFailObserver: NSObjectProtocol?
    
    var startupPasswordPlaceholder: String?

    // MARK: -
    // MARK: UIViewController
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setupObservers()

        startupPasswordPlaceholder = passwordTextField.placeholder ?? ""
        self.setControlState(.Ready)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        tearDownObservers()
    }
    
    
    // MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        
        self.setControlState(.Ready)
    }
    
    // MARK: -
    // MARK: LoginViewController
    // MARK: IBActions
    @IBAction func didTapOutsideView(sender: UITapGestureRecognizer) {
        
        dismissKeyboard()
    }
    
    
    @IBAction func didTapCancel(sender: UITapGestureRecognizer) {
    
        self.leave()
    }
    
    @IBAction func didTapSubmit(sender: UIButton) {
        
        self.setControlState(.Waiting)
        let service = UserAuthenticationServices(UserAuthenticationServices.defaultServiceName)
        service.login(userNameTextField.text!, password: passwordTextField.text!)
    }
    
    
    // MARK: Private Functions
    private enum ControlStates {
        
        case Ready
        case Waiting
        case Error(String)
    }
    
    private func setControlState(state: ControlStates) {
        
        switch state {
            
        case .Ready:
            
            userNameTextField.enabled = true
            passwordTextField.enabled = true
            login.hidden = false
            activity.stopAnimating()
            resetPasswordPlaceholder()
            
        case .Waiting:
            
            userNameTextField.enabled = false
            passwordTextField.enabled = false
            login.hidden = true
            activity.startAnimating()
            
        case .Error(let message):

            userNameTextField.enabled = true
            passwordTextField.enabled = true
            login.hidden = false
            activity.stopAnimating()
            let attributes = [NSForegroundColorAttributeName: UIColor(red: 1.0, green: 160.0/255.0, blue: 162.0/255.0, alpha: 1.0)]
            self.passwordTextField.attributedPlaceholder = NSAttributedString(string: message, attributes: attributes)
            self.passwordTextField.text = nil
        }
    }
    
    private func resetPasswordPlaceholder() {

        if (passwordTextField.attributedPlaceholder != nil) {
        
            passwordTextField.attributedPlaceholder = nil
            passwordTextField.placeholder = startupPasswordPlaceholder
        }
    }
    
    private func leave() {
        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
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
                
                NSLog("🐠🐠 LoginViewController received: %@", UserAuthenticationServices.SaveNotification)
                self.setControlState(.Ready)
                self.leave()
        }
        
        uaSaveFailObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            UserAuthenticationServices.SaveFailNotification,
            object: nil,
            queue: NSOperationQueue.currentQueue()) { (notification) -> Void in
                
                NSLog("🦀🦀 LoginViewController received: %@", UserAuthenticationServices.SaveNotification)
                self.setControlState(.Error("Oops! Try again."))
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

