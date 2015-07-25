//
//  StudentLocation.swift
//  OnMyMap
//
//  Created by Jeremy Broutin on 7/19/15.
//  Copyright (c) 2015 Jeremy Broutin. All rights reserved.
//

import Foundation

struct StudentLocation {
  
  // Parse Information
  let objectID: String
  let uniqueKey: String
  let firstName: String
  let lastName: String
  let mapString: String
  let mediaURL: String
  var latitude: Double
  var longitude: Double
  
  init(dictionary: [String: AnyObject]){
    objectID = dictionary[ParseAPIClient.JSONResponseKeys.ObjectID] as! String
    uniqueKey = dictionary[ParseAPIClient.JSONResponseKeys.UniqueKey] as! String
    firstName = dictionary[ParseAPIClient.JSONResponseKeys.FirstName] as! String
    lastName = dictionary[ParseAPIClient.JSONResponseKeys.LastName] as! String
    mapString = dictionary[ParseAPIClient.JSONResponseKeys.MapString] as! String
    mediaURL = dictionary[ParseAPIClient.JSONResponseKeys.MediaURL] as! String
    latitude = dictionary[ParseAPIClient.JSONResponseKeys.Latitude] as! Double
    longitude = dictionary[ParseAPIClient.JSONResponseKeys.Longitude] as! Double
  }
  
  /* Helper: Given an array of dictionaries, convert them to an array of StudentLocation objects */
  static func studentsLocationsFromResults(results: [[String : AnyObject]]) -> [StudentLocation] {
    var studentsLocations = [StudentLocation]()
    
    for result in results {
      studentsLocations.append(StudentLocation(dictionary: result))
    }
    
    return studentsLocations
  }
}