//
//  ParseAPIConvenience.swift
//  OnMyMap
//
//  Created by Jeremy Broutin on 7/19/15.
//  Copyright (c) 2015 Jeremy Broutin. All rights reserved.
//

import Foundation

extension ParseAPIClient {
  
  /* Get all students locations to be used in the map or in the table */
  func getStudentsLocation(completionHandler: (success: Bool, result: [StudentLocation]?, error: NSError?) -> Void){
    //1 - set parameters
    let methodParameters = [
      "limit": 500
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
  
  /* Post a new student location to be used in the PostLocation VC */
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
      }
      else {
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
  
  /* Get the current user existing location using its unique key - to be used for checking existing location */
  func queryStudentLocation(completionHandler: ( success: Bool, data: AnyObject!, error: NSError?) -> Void) {
    
    //1- set method to be used as per Parse's REST API doc
    let method =  ParseAPIClient.Methods.StudentLocation + "?where=%7B%22uniqueKey%22%3A%22" + Data.sharedInstance().userID! + "%22%7D"
    
    //1bis- set parameters (we still need it even if empty as the taskForGETMethod is expecting it!)
    let parameters = [
      "" : ""
    ]
    
    //2- make the request
    let task = self.taskForGETMethod(method, parameters: parameters) { JSONResult, error in
      
      //3 - Handle the result and set completionHandler
      if let error = error {
        completionHandler(success: false, data: nil, error: NSError(domain: "ParseQueryStudentsLocations", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network Error"]))
      }
      else {
        if let results = JSONResult.valueForKey(JSONResponseKeys.Results) as? NSArray {
          //note: as we want the user to only have one location (hence why we check for previous location and overwrite it),
          //we can satisfy ourselves with the first array entry
          if let objectID = results[0].valueForKey("objectId") as? String {
            Data.sharedInstance().objectID = objectID
            Data.sharedInstance().userHasExistingLocation = true
            completionHandler(success: true, data: JSONResult, error: nil)
          }
          else {
            completionHandler(success: false, data: nil, error: NSError(domain: "ParseQueryStudentsLocations", code: 2, userInfo: [NSLocalizedDescriptionKey: "Parsing Error, objectID not found"]))
            Data.sharedInstance().userHasExistingLocation = false
          }
        }
        else {
          completionHandler(success: false, data: nil, error: NSError(domain: "ParseQueryStudentsLocations", code: 2, userInfo: [NSLocalizedDescriptionKey: "Parsing Error, results not found"]))
          Data.sharedInstance().userHasExistingLocation = false
        }
      }
    }
  }

  /* Update student location if the entry already exists*/
  func updateStudentLocation(completionHandler: (data: AnyObject!, error: NSError?) -> Void) {
    
    //1- set jsonBody for PUT request
    let jsonBody: [String : AnyObject] = [
      JSONResponseKeys.UniqueKey: Data.sharedInstance().userID,
      JSONResponseKeys.FirstName: Data.sharedInstance().userFirstName,
      JSONResponseKeys.LastName: Data.sharedInstance().userLastName,
      JSONResponseKeys.MapString: Data.sharedInstance().mapString,
      JSONResponseKeys.MediaURL: Data.sharedInstance().mediaURL,
      JSONResponseKeys.Latitude: Data.sharedInstance().region.center.latitude,
      JSONResponseKeys.Longitude: Data.sharedInstance().region.center.longitude
    ]
    
    //2- Make the request
    let task = self.taskForPUTMethod(Methods.StudentLocation, objectID: Data.sharedInstance().objectID, jsonBody: jsonBody) { JSONResult, error in
      
      //3 - Handle the result and set completionHandler
      if let error = error {
        completionHandler(data: nil, error: NSError(domain: "ParseUpdateStudentLocation", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network Error"]))
      }
      else {
        if let updatedAt = JSONResult.valueForKey(JSONResponseKeys.UpdatedAt)  as? String {
          completionHandler(data: JSONResult, error: nil)
        }
        else {
          completionHandler(data: nil, error: NSError(domain: "ParseUpdateStudentLocation", code: 1, userInfo: [NSLocalizedDescriptionKey: "Parsing Error, updatedAt not found"]))
        }
      }
    }
  }
  
}
