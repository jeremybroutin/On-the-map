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
    
    // Get the user data
    UdacityAPIClient.sharedInstance().getUserData { error in
      if let error = error {
        dispatch_async(dispatch_get_main_queue()){
          println("Error getting user data (to be improved)")
          /*
          // set variables
          let title = "Network Error"
          let message = "The app is having troubles to access the data, please verify your Internet connection"
          let action = "I understand"
          // trigger alert
          var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
          alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
          self.presentViewController(alert, animated: true, completion: nil)
          */
        }
      }
      else {
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
