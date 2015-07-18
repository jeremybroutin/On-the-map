//
//  UdacityAPIConvenience.swift
//  OnTheMap
//
//  Created by Jeremy Broutin on 7/16/15.
//  Copyright (c) 2015 Jeremy Broutin. All rights reserved.
//

import Foundation

extension UdacityAPIClient {
  
  /*   LOGIN WITH UDACITY  */
  
  // Authenticate with Udacity credentials
  func authenticateWithUdacity(completionHandler: (success: Bool, error: NSError?) -> Void) {
    
    // Define the required jsonBody for the POST request used in getUserID
    let jsonBody = [
      UdacityAPIClient.JSONBodyKeys.Udacity: [
        UdacityAPIClient.JSONBodyKeys.Username: "\(Data.sharedInstance().username!)",
        UdacityAPIClient.JSONBodyKeys.Password: "\(Data.sharedInstance().password!)"
      ]
    ]
    
    // Use the getUserID method to query Udacity server
    self.getUserID(jsonBody) { userID, error in
      
      // If User ID is retrieve, store it and return true in the completion handler
      if let userID = userID {
        Data.sharedInstance().userID = userID
        completionHandler(success: true, error: nil)
      }
        
        // If not, return false in the completio handler and set the error with the error returned in getUserID
      else {
        completionHandler(success: false, error: NSError(domain: "getUserID", code: error!.code, userInfo: [NSLocalizedDescriptionKey: error!.userInfo![NSLocalizedDescriptionKey]!]))
      }
    }
    
  }
  
  /*   LOGIN WITH FACEBOOK  */
  
  // Authenticate with Facebook credentials
  func authenticateWithFacebook(completionHandler: (success: Bool, error: NSError?) -> Void) {
    
    // Define the required jsonBody for the POST request used in getUserID
    let jsonBody = [
      UdacityAPIClient.JSONBodyKeys.FacebookMobile: [
        UdacityAPIClient.JSONBodyKeys.AccessToken: "\(Data.sharedInstance().fbAccessToken!)"
      ]
    ]
    
    // Use the getUserID method to query Udacity server
    // NB: this will create a Udacity session using FB credentials
    self.getUserID(jsonBody) { userID, error in
      
      // If User ID is retrieve, store it and return true in the completion handler
      if let userID = userID {
        Data.sharedInstance().userID = userID
        completionHandler(success: true, error: nil)
      }
        
        // If not, return false in the completio handler and set the error with the error returned in getUserID
      else {
        completionHandler(success: false, error: NSError(domain: "getUserID", code: error!.code, userInfo: [NSLocalizedDescriptionKey: error!.userInfo![NSLocalizedDescriptionKey]!]))
      }
    }
    
  }
  
  /*   GET USER ID METHOD TO QUERY UDACITY SERVER  */
  
  func getUserID(jsonBody: [String: AnyObject], completionHandler: (userID: String?, error: NSError?) -> Void) {
    
    // Make the request using taskForPost method defined in UdacityAPIClient
    let task = self.taskForPostMethod(UdacityAPIClient.Methods.Session, jsonBody: jsonBody) { JSONResult, downloadError in
      
      // Set the completion handler accordingly
      // Case 1: download error
      if let error = downloadError {
        completionHandler(userID: nil, error: NSError(domain: "getUserID", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network Error"]))
        println("Could not complete the request \(error)")
      }
        // Case 2: download successful
      else {
        // Case 2.1: invalid credentials
        if let status_code = JSONResult.valueForKey(UdacityAPIClient.JSONResponseKeys.StatusCode) as? Int {
          if status_code == 403 {
            let udacityError = JSONResult.valueForKey(JSONResponseKeys.Error) as! String
            completionHandler(userID: nil, error: NSError(domain: "getUserID", code: 1, userInfo: [NSLocalizedDescriptionKey: udacityError]))
          }
        }
          // Case 2.2: accessing JSON result
        else {
          if let account = JSONResult.valueForKey(JSONResponseKeys.Account) as? NSDictionary {
            if let userID = account.valueForKey(JSONResponseKeys.Key) as? String {
              completionHandler(userID: userID, error: nil)
            }
            else {
              completionHandler(userID: nil, error: NSError(domain: "getUserID", code: 3, userInfo: [NSLocalizedDescriptionKey:"Could not find user ID"]))
              println("Could not find key in \(account)")
            }
          }
          else {
            completionHandler(userID: nil, error: NSError(domain: "getUserID", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not find account"]))
            println("Could not find account in \(JSONResult)")
          }
        }
      }
    }
  }
  
  
  /*   HELPER METHODS  */
  
  // Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error
  class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
    if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
      if let errorMessage = parsedResult[UdacityAPIClient.JSONResponseKeys.StatusMessage] as? String {
        let userInfo = [NSLocalizedDescriptionKey: errorMessage]
        return NSError(domain: "Udacity Error", code: 0, userInfo: userInfo)
      }
    }
    return error
  }
  
  // Helper: Given raw JSON, return a usable Foundation object
  class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
    var parsingError: NSError? = nil
    let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
    let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
    if let error = parsingError {
      completionHandler(result: nil, error: error)
    } else {
      completionHandler(result: parsedResult, error: nil)
    }
  }
  
}
