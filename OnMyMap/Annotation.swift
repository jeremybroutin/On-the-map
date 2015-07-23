//
//  Annotations.swift
//  OnTheMap
//
//  Created by Jeremy Broutin on 7/19/15.
//  Copyright (c) 2015 Jeremy Broutin. All rights reserved.
//

import Foundation
import MapKit

// Thanks to RayWenderlich.com for its tutorial: http://www.raywenderlich.com/90971/introduction-mapkit-swift-tutorial
class Annotation: NSObject, MKAnnotation {
  
  let title: String
  // subtitle might be empty
  var subtitle: String?
  let coordinate: CLLocationCoordinate2D
  
  init(firstName: String, lastName: String, mediaUrl: String?, lat:Double, lon: Double){
    self.title = firstName + " " + lastName
    // unwrap mediaUrl
    if let mediaUrl = mediaUrl {
      self.subtitle = mediaUrl
    }
    else {
      self.subtitle = ""
    }
    self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    
    super.init()
  }
  
  /* Helper: Given an array of StudentLocation, convert them to an array of Annotation objects */
  static func annotationsFromStudentsLocations(studentsLocations: [StudentLocation]) -> [Annotation] {
    var annotations = [Annotation]()
    
    for studentLocation in studentsLocations {
      let annotation = Annotation(firstName: studentLocation.firstName, lastName: studentLocation.lastName, mediaUrl: studentLocation.mediaURL, lat: studentLocation.latitude, lon: studentLocation.longitude)
      annotations.append(annotation)
    }
    
    return annotations
  }
  
}