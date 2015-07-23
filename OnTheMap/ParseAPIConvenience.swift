//
//  ParseAPIConvenience.swift
//  OnTheMap
//
//  Created by Jeremy Broutin on 7/19/15.
//  Copyright (c) 2015 Jeremy Broutin. All rights reserved.
//

import Foundation

extension ParseAPIClient {
  
  func getStudentsLocation(completionHandler: (success: Bool, result: [StudentLocation]?, error: NSError?) -> Void){
    //1 - set parameters
    let methodParameters = [
      "limit": 100
    ]
    
    //2 - make the request
    taskForGETMethod(ParseAPIClient.Methods.StudentLocation, parameters: methodParameters){ JSONResult, error in
      
      //3 - Handle the result and set completionHandler
      if let error = error {
        completionHandler(success: false, result: nil, error: NSError(domain: "ParseGetStudentLocation", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network Error"]))
      }
      else {
        if let result = JSONResult.valueForKey(ParseAPIClient.JSONResponseKeys.Results) as? [[String: AnyObject]] {
          var studentsLocations = StudentLocation.studentsLocationsFromResults(result)
          completionHandler(success: true, result: studentsLocations, error: nil)
        }
        else {
          println("Could not find results in \(JSONResult)")
          completionHandler(success: false, result: nil, error: NSError(domain: "ParseGetStudentLocation", code: 1, userInfo: [NSLocalizedDescriptionKey: "Parsing Error, results not found"]))
        }
      }
    }
  }
  
  func postStudentLocation(completionHandler: (data: AnyObject!, error: NSError?) -> Void) {
    
    //1 - set jsonBody for POST request
    let jsonBody: [String : AnyObject] = [
      JSONResponseKeys.UniqueKey: Data.sharedInstance().userID,
      JSONResponseKeys.FirstName: Data.sharedInstance().userFirstName,
      JSONResponseKeys.LastName: Data.sharedInstance().userLastName,
      JSONResponseKeys.MapString: Data.sharedInstance().mapString,
      JSONResponseKeys.MediaURL: Data.sharedInstance().mediaURL,
      JSONResponseKeys.Latitude: Data.sharedInstance().region.center.latitude,
      JSONResponseKeys.Longitude: Data.sharedInstance().region.center.longitude
    ]
    
    //2 - make the request
    let task = self.taskForPostMethod(ParseAPIClient.Methods.StudentLocation, jsonBody: jsonBody) { JSONResult, error in
      
      //3 - Handle the result and set completionHandler
      if let error = error {
        completionHandler(data: nil, error: NSError(domain: "ParsePostStudentLocation", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network Error"]))
      } else {
        if let objectID = JSONResult.valueForKey(JSONResponseKeys.ObjectID) as? String {
          Data.sharedInstance().objectID = objectID
          completionHandler(data: JSONResult, error: nil)
        }
        else {
          completionHandler(data: nil, error: NSError(domain: "ParsePostStudentLocation", code: 1, userInfo: [NSLocalizedDescriptionKey: "Parsing Error, objectID not found"]))
        }
      }
    }
  }
  
}
