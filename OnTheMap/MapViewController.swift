//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jeremy Broutin on 7/18/15.
//  Copyright (c) 2015 Jeremy Broutin. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class MapViewController: UIViewController, MKMapViewDelegate {
  
  @IBOutlet weak var mapView: MKMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate = self
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // Get students locations
    ParseAPIClient.sharedInstance().getStudentsLocation { success, studentsLocations, error in
      if success {
        if let studentsLocations = studentsLocations {
          dispatch_async(dispatch_get_main_queue()) {
            
            //store new students locations data set
            Data.sharedInstance().studentsLocations = studentsLocations
            
            //create the annotations using the recently stored data set
            let annotations = Annotation.annotationsFromStudentsLocations(Data.sharedInstance().studentsLocations)

            //remove any previous annotations
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            //add annotations to the mapView object
            self.mapView.addAnnotations(annotations)
          }
        }
        // scenario: studentsLocations doesn't exist
        else {
          if let error = error {
            dispatch_async(dispatch_get_main_queue()){
              self.dataFailure(error)
            }
          }
        }
      }
      // scenario: success equals false
      else {
        if let error = error {
          dispatch_async(dispatch_get_main_queue()){
            self.dataFailure(error)
          }
        }
      }
    }
  }
  
  // Helper function to handle getStudentsLocation failure
  func dataFailure(error: NSError?) {
    if error!.code == 0 {
      // set variables
      let title = "Network Error"
      let message = "The app is having troubles to access the data, please verify your Internet connection"
      let action = "I understand"
      // trigger alert
      var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
      alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
      self.presentViewController(alert, animated: true, completion: nil)
    }
    else {
      // set variables
      let title = "Oups... there seems to be an issue"
      let message = "The app couldn't retrieve the students locations data!"
      let action = "OK"
      // trigger alert
      var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
      alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
      self.presentViewController(alert, animated: true, completion: nil)
    }
  }
  
  // MARK: - MKMapViewDelegate
  
  // Here we create a view with a "right callout accessory view". You might choose to look into other
  // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
  // method in TableViewDataSource.
  
  // Thanks to RayWenderlich.com for its tutorial: http://www.raywenderlich.com/90971/introduction-mapkit-swift-tutorial
  func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    if let annotation = annotation as? Annotation {
      let identifier = "pin"
      var view: MKPinAnnotationView
      if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        as? MKPinAnnotationView {
          dequeuedView.annotation = annotation
          view = dequeuedView
      } else {
        view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        view.canShowCallout = true
        view.calloutOffset = CGPoint(x: -5, y: 5)
        view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
      }
      return view
    }
    return nil
  }

  
  // This delegate method is implemented to respond to taps. It opens the system browser
  // to the URL specified in the annotationViews subtitle property.
  func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
    let annotation = view.annotation as! Annotation

    let annotationURL = NSURL(string: annotation.subtitle!)
  
    //check if the URL can be opened
    if UIApplication.sharedApplication().canOpenURL(annotationURL!){
      UIApplication.sharedApplication().openURL(annotationURL!)
    }
    else{
      // set variables
      let title = "Oups... an error ocurred!"
      let message = "The URL couldn't be opened."
      let action = "OK"
      // trigger alert
      var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
      alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
      self.presentViewController(alert, animated: true, completion: nil)
    }
  }
  

  
}
