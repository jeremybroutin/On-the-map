//
//  ParseAPIConvenience.swift
//  OnTheMap
//
//  Created by Jeremy Broutin on 7/19/15.
//  Copyright (c) 2015 Jeremy Broutin. All rights reserved.
//

import Foundation

extension ParseAPIClient {
  
  // Get all students locations to be used in the map or in the table
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
  
  // Post a new student location to be used in the PostLocation VC
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
  
  // Get the current user existing location using its unique key - to be used for checking existing location
  func queryStudentLocations(completionHandler: ( success: Bool, data: AnyObject!, error: NSError?) -> Void) {
    
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
        //the JSON response is an array of results
        if let resultsArray = JSONResult.valueForKey(JSONResponseKeys.Results) as? NSArray {
          //if a user has several locations, there will be several results with each a unique objectID
          var returnedObjectIDs = [String]()
          //we loop through each result
          for result in resultsArray {
            //if we find it...
            if let returnedObjectID = result.valueForKey(JSONResponseKeys.ObjectID) as? String {
              //.. we had it to the array
              returnedObjectIDs.append(returnedObjectID)
              
            }
            else {
              completionHandler(success: false, data: nil, error: NSError(domain: "ParseQueryStudentsLocations", code: 2, userInfo: [NSLocalizedDescriptionKey: "Parsing Error, objectID not found"]))
            }
          }
          //if we end up with no object id
          if returnedObjectIDs.isEmpty {
            //store this info in our Data class
            Data.sharedInstance().userHasExistingLocation = false
            completionHandler(success: false, data: JSONResult, error: nil)
            
          }
          //otherwise (it means we do have previous location(s)
          else {
            //store this info in our Data class
            Data.sharedInstance().userHasExistingLocation = true
            completionHandler(success:true, data: JSONResult, error: nil)
          }
          //finally don't forget to store these results so that we can use it to update a location
          Data.sharedInstance().returnedObjectIDs = returnedObjectIDs
        }
        else {
          completionHandler(success: false, data: nil, error: NSError(domain: "ParseQueryStudentsLocations", code: 1, userInfo: [NSLocalizedDescriptionKey: "Parsing Error, results not found"]))
        }
      }
    }
  }
  
}
