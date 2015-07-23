//
//  NavigationViewController.swift
//  OnMyMap
//
//  Created by Jeremy Broutin on 7/22/15.
//  Copyright (c) 2015 Jeremy Broutin. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit

class NavigationViewController: NSObject, UIAlertViewDelegate {
  
  var view: UIViewController!
  
  // Set the navigation bar
  func setNavBar(viewController: UIViewController) {
    view = viewController
    
    let markerButton = UIBarButtonItem(image: UIImage(named: "Marker"), style: UIBarButtonItemStyle.Plain, target: self, action: "checkForExistingLocation")
    let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshData")
    let logoutButton = UIBarButtonItem(image: UIImage(named:"Logout"), style: UIBarButtonItemStyle.Plain, target: self, action: "logout")
    let logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
    logoView.contentMode = .ScaleAspectFit
    let logoImage = UIImage(named: "Logo")
    logoView.image = logoImage
    
    viewController.parentViewController!.navigationItem.leftBarButtonItems = [markerButton, refreshButton]
    viewController.parentViewController!.navigationItem.titleView = logoView
    viewController.parentViewController!.navigationItem.rightBarButtonItem = logoutButton
  }
  
  /* NAVIGATION ACTIONS */
  
  // Add a pin
  func checkForExistingLocation() {
    
    // Query Parse user data to look for existing location(s) (aka object id(s))
    ParseAPIClient.sharedInstance().queryStudentLocations { success, data, error in
      
      // if we have existing locations...
      if success {
        // create an alert VC to alert the user
        
        //create the alertVC
        let alertController = UIAlertController(
          title: "Kaapooooom",
          message: "Its looks like you already have some location(s) posted. \n By continuing, you might override it.",
          preferredStyle: .Alert)
        
        //create the continue button
        let continueButton = UIAlertAction(
          title: "Continue",
          style: UIAlertActionStyle.Default,
          handler: { (action: UIAlertAction!) in self.continueToPostLocationVC()}
        )
        
        //create the cancel button
        let cancelButton = UIAlertAction(
          title: "Cancel",
          style: UIAlertActionStyle.Default,
          handler: { (action: UIAlertAction!) in alertController.dismissViewControllerAnimated(true, completion: nil)}
        )
        
        //add the two actions to the alertController object
        alertController.addAction(continueButton)
        alertController.addAction(cancelButton)
        
        //present the alertController
        self.view.presentViewController(alertController, animated: true, completion: nil)
      }
        
        // if we don't have existing locations and no error...
      else if (!success && error == nil) {
        // take the user to the PostLocationVC
        let controller = self.view.storyboard!.instantiateViewControllerWithIdentifier("PostLocationViewController") as! PostLocationViewController
        self.view.presentViewController(controller, animated: true, completion: nil)
      }
        
        // if we have error...
      else if let error = error {
        // present an error alert
        let title = "Unknown Error"
        let message = "Sorry about that... please try to close and reopen the app!"
        let action = "OK"
        // trigger alert
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
        self.view.presentViewController(alert, animated: true, completion: nil)
      }
    }
  }
  

  // Helper method for getting user data and presenting PostLocVC
  func continueToPostLocationVC() {
    // Get the user data
    UdacityAPIClient.sharedInstance().getUserData { error in
      if let error = error {
        println("Error getting the user data when updating location")
        dispatch_async(dispatch_get_main_queue()) {
          // set variables
          let title = "Network Error"
          let message = "The app is having troubles to access the data, please verify your Internet connection"
          let action = "I understand"
          // trigger alert
          var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
          alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
          self.view!.presentViewController(alert, animated: true, completion: nil)
        }
      }
      else {
        println("success getting user data, going to post location vc")
        dispatch_async(dispatch_get_main_queue()){
          let controller = self.view.storyboard!.instantiateViewControllerWithIdentifier("PostLocationViewController") as! PostLocationViewController
          self.view.presentViewController(controller, animated: true, completion: nil)
        }
        
      }
    }
  }


  // Refresh data
  func refreshData(){
    /*
    mapView.hidden = true
    refreshActivityIndicator.hidden = false
    refreshActivityIndicator.startAnimating()
    self.viewWillAppear(true)
    */
    println("refresh button clicked")
    
    //if VC is map, simply refresh the view as it will reload the parse functions
    if self.view is MapViewController {
      self.view!.viewWillAppear(true)
    }
      //if VC is table, manually call Parse to get the data
    else if self.view is TableViewController {
      
      ParseAPIClient.sharedInstance().getStudentsLocation { success, studentsLocations, error in
        if let studentsLocations = studentsLocations {
          dispatch_async(dispatch_get_main_queue()) {
            //store the new/fresh data
            Data.sharedInstance().studentsLocations = studentsLocations
            //reload the view and the tableview delegate will rebuild the table accordingly
            self.view!.viewWillAppear(true)
            println("students locations updated")
          }
          
        } else {
          dispatch_async(dispatch_get_main_queue()) {
            if error!.code == 0 {
              // set variables
              let title = "Network Error"
              let message = "The app is having troubles to access the data, please verify your Internet connection"
              let action = "I understand"
              // trigger alert
              var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
              alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
              self.view!.presentViewController(alert, animated: true, completion: nil)
            }
          }
        }
      }
    }
  }
  
  // Logout from session
  func logout() {
    
    // Logout from FB session
    // FB doc: https://developers.facebook.com/docs/reference/android/current/class/LoginManager/
    if Data.sharedInstance().fbAccessToken != nil {
      let fbLoginManager = FBSDKLoginManager()
      fbLoginManager.logOut()
      self.view!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Logout from Udacity session using convenience method
    UdacityAPIClient.sharedInstance().logoutFromUdacity{ success, error in
      
      // simply dismiss the VC if logout is successful
      if success{
        self.view!.dismissViewControllerAnimated(true, completion: nil)
      }
      // otherwise display an alert
      else {
        dispatch_async(dispatch_get_main_queue()) {
          if error!.code == 0 {
            // set variables
            let title = "Network Error"
            let message = "The app is having troubles to access the data, please verify your Internet connection"
            let action = "I understand"
            // trigger alert
            var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
            self.view!.presentViewController(alert, animated: true, completion: nil)
          }
        }
      }
    }
  }
  
  
  // MARK: - Shared Instance
  
  class func sharedInstance() -> NavigationViewController {
    struct Singleton {
      static var sharedInstance = NavigationViewController()
    }
    return Singleton.sharedInstance
  }
  

}
