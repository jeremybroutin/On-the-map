//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Jeremy Broutin on 7/15/15.
//  Copyright (c) 2015 Jeremy Broutin. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
  

  @IBOutlet weak var headerTextLabel: UILabel!
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var loginButton: BorderedButton!
  @IBOutlet weak var signupTextLabel: UILabel!
  @IBOutlet weak var debugTextLabel: UILabel!
  @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!

  
  var appDelegate: AppDelegate!
  var session: NSURLSession!
  
  /* Constants */
  let baseURLSecureString = "https://www.udacity.com/api/"
  var genericFailureReason = "Login Failed (Session ID)."
  
  var backgroundGradient: CAGradientLayer? = nil
  var tapRecognizer: UITapGestureRecognizer? = nil
  var signupTapRecognizer: UITapGestureRecognizer? = nil
  
  var keyboardAdjusted = false
  var lastKeyboardOffset : CGFloat = 0.0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Get the app delegate
    appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // Get the shared URL session
    session = NSURLSession.sharedSession()
    
    // Configure the UI and gesture recognizers
    self.configureUI()
    
    // Set the delegates
    usernameTextField.delegate = self
    passwordTextField.delegate = self

    facebookLoginButton.delegate = self
    facebookLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
    
    // Redirect user to next view if already logged in with FB
    if FBSDKAccessToken.currentAccessToken() != nil {
      
      // Update UI
      loginButton.hidden = true
      loginActivityIndicator.hidden = false
      debugTextLabel.text = "Logging in via Facebook..."
      loginActivityIndicator.startAnimating()
      
      // Store access token
      Data.sharedInstance().fbAccessToken = FBSDKAccessToken.currentAccessToken().tokenString
      
      // Run authentication method from UdacityAPIClient
      UdacityAPIClient.sharedInstance().authenticateWithFacebook() { success, error in
        if success {
          dispatch_async(dispatch_get_main_queue()){
            self.completeLogin()
          }
        }
        else {
          dispatch_async(dispatch_get_main_queue()){
            self.failLogin(error)
          }
        }
      }
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    self.addKeyboardDismissRecognizer()
    self.subscribeToKeyboardNotifications()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    self.removeKeyboardDismissRecognizer()
    self.unsubscribeToKeyboardNotifications()
  }
  
  @IBAction func loginButtonTouch(sender: AnyObject) {
    
    if passwordTextField.text.isEmpty && usernameTextField.text.isEmpty {
      debugTextLabel.text = "Username and Password Empty."
    } else if usernameTextField.text.isEmpty {
      debugTextLabel.text = "Username Empty."
    } else if passwordTextField.text.isEmpty {
      debugTextLabel.text = "Password Empty."
    } else {
      
      // Set user expectation regarding login connection
      debugTextLabel.text = "Connecting..."
      loginButton.hidden = true
      loginActivityIndicator!.hidden = false
      loginActivityIndicator!.startAnimating()
      
      // Store user's inputs in Data for next authentication
      Data.sharedInstance().username = usernameTextField.text
      Data.sharedInstance().password = passwordTextField.text
      
      // Call UdacityAPIClient authentication method
      UdacityAPIClient.sharedInstance().authenticateWithUdacity() { success, error in
        if success {
          dispatch_async(dispatch_get_main_queue()) {
            self.completeLogin()
          }
        }
        else {
          dispatch_async(dispatch_get_main_queue()) {
            self.failLogin(error)
          }
        }
      }
    }

  }
  
  // Helper FB Login delegate methods
  func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
    if let error = error {
      self.debugTextLabel.text = error.localizedDescription
    }
    else {
      
      // Store the FB token
      Data.sharedInstance().fbAccessToken = FBSDKAccessToken.currentAccessToken().tokenString
      // Run login method with authenticateWithFB
      UdacityAPIClient.sharedInstance().authenticateWithFacebook() { success, error in
        if success{
          dispatch_async(dispatch_get_main_queue()){
            self.completeLogin()
          }
        }
        else {
          dispatch_async(dispatch_get_main_queue()){
            self.failLogin(error)
          }
        }
      }
    }
  }
  
  func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    // TODO: (eventually) could handle the early/quick click on Log out button
  }
  
  
  // Helper function to redirect user to the next view once login is completed
  func completeLogin() {
    dispatch_async(dispatch_get_main_queue(), {
      self.debugTextLabel.text = ""
      self.loginActivityIndicator.stopAnimating()
      self.loginButton.hidden = false
      self.performSegueWithIdentifier("showMap", sender: self)
      //let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapTabBarController") as! UITabBarController
      //self.presentViewController(controller, animated: true, completion: nil)
      //NB: the two lines above don't allow to reach the MapViewController
      println("login was successful, taking user to MapTabBarCtrller")
    })
  }
  
  // Helper function to stop login process if error
  func failLogin(error: NSError?) {
    dispatch_async(dispatch_get_main_queue()) {
      self.loginActivityIndicator.stopAnimating()
      self.loginButton.hidden = false
      if let error = error {
        switch error.code {
          case 0:
            self.debugTextLabel!.text = "Oups... connection lost! \nCheck your internet connection"
          case 1:
            self.debugTextLabel!.text = "Sorry, invalid username/password \nTry again or sign up!"
          default:
            self.debugTextLabel!.text = "Humm... there was an error \nPlease try again"
        }
  
        self.view.endEditing(true)
        self.loginActivityIndicator.stopAnimating()
        self.loginButton.enabled = true
      }
    }
  }

  // Sign Up label touch
  func signupButtonTouch(sender: UITapGestureRecognizer) {
    let urlString = "https://www.udacity.com/account/auth#!/signin"
    let url = NSURL(string: urlString)
    let application = UIApplication.sharedApplication()
    application.openURL(url!)
  }
  
  // MARK: - Keyboard Fixes
  
  func addKeyboardDismissRecognizer() {
    self.view.addGestureRecognizer(tapRecognizer!)
  }
  
  func removeKeyboardDismissRecognizer() {
    self.view.removeGestureRecognizer(tapRecognizer!)
  }
  
  func handleSingleTap(recognizer: UITapGestureRecognizer) {
    self.view.endEditing(true)
  }
  
  // MARK: - Helper methods
  
  // UIConfig
  
  func configureUI() {
    /* Configure background gradient */
    self.view.backgroundColor = UIColor.clearColor()
    let colorTop = UIColor(red: 0.988, green: 0.568, blue: 0.121, alpha: 1.0).CGColor
    let colorBottom = UIColor(red: 0.988, green: 0.396, blue: 0.133, alpha: 1.0).CGColor
    self.backgroundGradient = CAGradientLayer()
    self.backgroundGradient!.colors = [colorTop, colorBottom]
    self.backgroundGradient!.locations = [0.0, 1.0]
    self.backgroundGradient!.frame = view.frame
    self.view.layer.insertSublayer(self.backgroundGradient, atIndex: 0)
    
    /* Configure header text label */
    headerTextLabel.font = UIFont(name: "AvenirNext-Medium", size: 24.0)
    headerTextLabel.textColor = UIColor.whiteColor()
    
    /* Configure email textfield */
    let emailTextFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0);
    let emailTextFieldPaddingView = UIView(frame: emailTextFieldPaddingViewFrame)
    usernameTextField.leftView = emailTextFieldPaddingView
    usernameTextField.leftViewMode = .Always
    usernameTextField.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
    usernameTextField.backgroundColor = UIColor.whiteColor()
    //set the text color to light blue
    usernameTextField.textColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
    usernameTextField.attributedPlaceholder = NSAttributedString(string: usernameTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
    usernameTextField.tintColor = UIColor(red: 0.988, green:0.368, blue:0.156, alpha: 1.0)
    
    /* Configure password textfield */
    let passwordTextFieldPaddingViewFrame = CGRectMake(0.0, 0.0, 13.0, 0.0);
    let passwordTextFieldPaddingView = UIView(frame: passwordTextFieldPaddingViewFrame)
    passwordTextField.leftView = passwordTextFieldPaddingView
    passwordTextField.leftViewMode = .Always
    passwordTextField.font = UIFont(name: "AvenirNext-Medium", size: 17.0)
    passwordTextField.backgroundColor = UIColor.whiteColor()
    //set the text color to light blue
    passwordTextField.textColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
    passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
    passwordTextField.tintColor = UIColor(red: 0.988, green:0.368, blue:0.156, alpha: 1.0)
    
    /* Configure header and debug text labels */
    headerTextLabel.font = UIFont(name: "AvenirNext-Medium", size: 20)
    headerTextLabel.textColor = UIColor.whiteColor()
    
    self.debugTextLabel.numberOfLines = 2
    self.debugTextLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
    
    self.loginActivityIndicator.hidden = true
    
    /* Configure tap recognizers */
    //for keyboard notifications
    tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
    tapRecognizer?.numberOfTapsRequired = 1
    //for signup UILabel
    self.signupTextLabel.userInteractionEnabled = true
    signupTapRecognizer = UITapGestureRecognizer(target: self, action: "signupButtonTouch:")
    signupTapRecognizer?.numberOfTapsRequired = 1
    signupTextLabel.addGestureRecognizer(signupTapRecognizer!)
  }
  
  // KeyboardNotifications
  
  func subscribeToKeyboardNotifications() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
  }
  
  func unsubscribeToKeyboardNotifications() {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
  }
  
  func keyboardWillShow(notification: NSNotification) {
    if keyboardAdjusted == false {
      lastKeyboardOffset = getKeyboardHeight(notification) / 2
      self.view.superview?.frame.origin.y -= lastKeyboardOffset
      keyboardAdjusted = true
    }
  }
  
  func keyboardWillHide(notification: NSNotification) {
    if keyboardAdjusted == true {
      self.view.superview?.frame.origin.y += lastKeyboardOffset
      keyboardAdjusted = false
    }
  }
  
  func getKeyboardHeight(notification: NSNotification) -> CGFloat {
    let userInfo = notification.userInfo
    let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
    return keyboardSize.CGRectValue().height
  }
  
  // UITextFieldsDataSource: allow return interaction for text fields
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    self.view.endEditing(true)
    return false
  }
}

