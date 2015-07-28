//
//  PostLocationViewController.swift
//  OnMyMap
//
//  Created by Jeremy Broutin on 7/20/15.
//  Copyright (c) 2015 Jeremy Broutin. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PostLocationViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
  
  @IBOutlet weak var headerUIView: UIView!
  @IBOutlet weak var bodyUIView: UIView!
  @IBOutlet weak var locationEntryUIView: UIView!
  @IBOutlet weak var locationEntryTextField: UITextField!
  @IBOutlet weak var headerTextView: UITextView!
  @IBOutlet weak var findOnMapButton: BorderedButton!
  @IBOutlet weak var linkTextField: UITextField!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //Hide/show the relevant elements

    self.headerTextView.hidden = false
    
    self.locationEntryUIView.hidden = false
    self.locationEntryTextField.hidden = false
    self.findOnMapButton.hidden = false
    
    self.linkTextField.hidden = true
    self.mapView.hidden = true
    self.loadingActivityIndicator.hidden = true
    
    //Remove the text fields default texts on click
    self.locationEntryTextField.clearsOnBeginEditing = true
    self.linkTextField.clearsOnBeginEditing = true
    
    //Set the delegate
    self.locationEntryTextField.delegate = self
    self.linkTextField.delegate = self
    self.mapView.delegate = self
    
  }
  
  //Click find on the map button
  @IBAction func findOnMap(sender: AnyObject) {
    
    if sender.currentTitle == "Find on the Map" {
      
      //1- Make sure the textfield is not empty or default
      if locationEntryTextField.text == "Enter your Location Here" || locationEntryTextField.text.isEmpty{
        
        // set variables
        let title = "Location not found"
        let message = "Make sure you entered a correct location!"
        let action = "I understand"
        // trigger alert
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
      }
        //2- if textfield is correct, move on
      else{
        
        //start the activity indicator while we load the map
        self.loadingActivityIndicator.hidden = false
        self.loadingActivityIndicator.startAnimating()
        
        // set the geocoder object
        // see doc: https://developer.apple.com/library/prerelease/ios/documentation/CoreLocation/Reference/CLGeocoder_class/index.html#//apple_ref/occ/instm/CLGeocoder/geocodeAddressString:completionHandler:
        // note: geocoder will look up placemark information for specified coordoniate values
        // note bis: forward geocoding: multiple placemarks objects may be returned!!
        
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(Data.sharedInstance().mapString!) { placemarks, error in
          
          // throw an error alert if there is an error
          if let error = error {
            dispatch_async(dispatch_get_main_queue()){
              //stop activity indicator
              self.loadingActivityIndicator.stopAnimating()
              
              // set variables
              let title = "Location not found"
              let message = "Make sure you entered a correct location!"
              let action = "I understand"
              // trigger alert
              var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
              alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
              self.presentViewController(alert, animated: true, completion: nil)
            }
          }
            
            // if no error, set the region and add annotation
          else {
            dispatch_async(dispatch_get_main_queue()){
              
              // MAP REGION
              //unwrap the placemarks data
              let placemarks = placemarks as! [CLPlacemark]
              
              //use the placemark(s) info to create the necessary region (to center and span the map)
              // a. define a region object
              var region: MKCoordinateRegion
              
              // b. loop through each placemark and use its info to create a MKCoordinate object
              for placemark in placemarks {
                // Apple doc: we need a center (aka coordinate) and a span for our MKCoordinateRegion
                let coordinate: CLLocationCoordinate2D = placemark.location.coordinate
                let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                
                // c. set the region using above infos
                region = MKCoordinateRegion(center: coordinate, span: span)
                
                // d. store it
                Data.sharedInstance().region = region
                
                // e. we take only the first entry so we break the loop
                break
              }
              
              // MAP ANNOTATION
              let annotation = Annotation(firstName: Data.sharedInstance().userFirstName!, lastName: Data.sharedInstance().userLastName!, mediaUrl: nil, lat: Data.sharedInstance().region.center.latitude, lon: Data.sharedInstance().region.center.longitude)
              
              // UPDATE VIEW
              //stop activity indicator
              self.loadingActivityIndicator.hidden = false
              self.loadingActivityIndicator.stopAnimating()
              
              // now that the data is ready, change the view elements
              self.headerTextView.hidden = true
              self.headerUIView.backgroundColor = UIColor(red: 0.980, green: 0.349, blue: 0.078, alpha: 1.0)
              
              self.locationEntryUIView.hidden = true
              self.locationEntryTextField.hidden = true
              
              self.linkTextField.hidden = false
              self.mapView.hidden = false
              
              self.findOnMapButton.setTitle("Submit", forState: .Normal)
              
              //add the region and the annotation to the map
              self.mapView.setRegion(Data.sharedInstance().region, animated: true)
              self.mapView.addAnnotation(annotation)
              
            }
          }
        }
      }
    }
    
    else if sender.currentTitle == "Submit" {
      // Case 1: no previous location, we create one
      if !Data.sharedInstance().userHasExistingLocation {
        self.submitLocation()
      }
        // Case 2: existing location, we update it
      else if (Data.sharedInstance().userHasExistingLocation == true) {
        // make sure the text field is not empty
        if !self.linkTextField.text.isEmpty {
          self.updateLocation()
        }
        // otherwise throw an error
        else {
          dispatch_async(dispatch_get_main_queue()){
            // set variables
            let title = "Missing stuff"
            let message = "Oups, you're missing your pin link!"
            let action = "Add now"
            // trigger alert
            var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
          }
        }
        
      }
      // Case 3: if any error, fail gracefully
      else {
        dispatch_async(dispatch_get_main_queue()){
          // set variables
          let title = "Oups... Error"
          let message = "Something weird happened, sorry about that! /n Please try again later."
          let action = "OK"
          // trigger alert
          var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
          alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
          self.presentViewController(alert, animated: true, completion: nil)
        }
      }
    }
  }
  
  //Helper function: submit location
  func submitLocation() {
    ParseAPIClient.sharedInstance().postStudentLocation { result, error in
      
      if let error = error {
        dispatch_async(dispatch_get_main_queue()){
          // set variables
          let title = "Network Error"
          let message = "The app is having troubles to access the data, please verify your Internet connection"
          let action = "I understand"
          // trigger alert
          var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
          alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
          self.presentViewController(alert, animated: true, completion: nil)
        }
      }
      else {
        // the submission is successful and we display an alert to take the user back to the HP
        dispatch_async(dispatch_get_main_queue()){
          // set variables
          let title = "Congratulations"
          let message = "Your location has been successfully added!"
          let action = "Return to home page"
          // trigger alert
          var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
          alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
          }))
          self.presentViewController(alert, animated: true, completion: nil)
        }
      }
    }
  }
  //Helper function: update existing location
  func updateLocation() {
    ParseAPIClient.sharedInstance().updateStudentLocation { result, error in
      
      if let error = error {
        dispatch_async(dispatch_get_main_queue()){
          // set variables
          let title = "Network Error"
          let message = "The app is having troubles to access the data, please verify your Internet connection"
          let action = "I understand"
          // trigger alert
          var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
          alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
          self.presentViewController(alert, animated: true, completion: nil)
        }
      }
      else {
        // the submission is successful and we display an alert to take the user back to the HP
        dispatch_async(dispatch_get_main_queue()){
          // set variables
          let title = "Congratulations"
          let message = "Your location has been successfully updated!"
          let action = "Return to home page"
          // trigger alert
          var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
          alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
          }))
          self.presentViewController(alert, animated: true, completion: nil)
        }
      }
    }
  }
  
  //Cancel posting new location
  @IBAction func cancelButtonTouch(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  // MARK: - UITextFieldDataSource
  
  //Remove keyboard when hitting return
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    self.view.endEditing(true)
    return false
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
    if locationEntryTextField.hidden == false && !locationEntryTextField.text.isEmpty{
      Data.sharedInstance().mapString = textField.text
    }
    else if linkTextField.hidden == false && !linkTextField.text.isEmpty{
      Data.sharedInstance().mediaURL = textField.text
    }
    else {
      println("debug error to highlight problem with textfield didendediting")
      println(Data.sharedInstance().mediaURL)
    }
  }
  
}
