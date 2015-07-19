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
  
}
