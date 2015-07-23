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
  
  /*   GETUSERID METHOD TO QUERY UDACITY SERVER  */
  
  func getUserID(jsonBody: [String: AnyObject], completionHandler: (userID: String?, error: NSError?) -> Void) {
    
    // Make the request using taskForPost method defined in UdacityAPIClient
    let task = self.taskForPostMethod(UdacityAPIClient.Methods.Session, jsonBody: jsonBody) { JSONResult, downloadError in
      
      // Set the completion handler accordingly
      // Case 1: download error
      if let error = downloadError {
        completionHandler(userID: nil, error: NSError(domain: "getUserID", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network Error"]))
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
            }
          }
          else {
            completionHandler(userID: nil, error: NSError(domain: "getUserID", code: 2, userInfo: [NSLocalizedDescriptionKey: "Could not find account"]))
          }
        }
      }
    }
  }
  
  /*   ACCESS USER DATA FOR POSTING  */
  
  func getUserData(completionHandler: (error: NSError?) -> Void){
    
    // Make the request using taskForPost method defined in UdacityAPIClient
    let task = self.taskForGETMethod(UdacityAPIClient.Methods.UserData, userID: Data.sharedInstance().userID!) { JSONResult, downloadError in
      
      // Set the completion handler accordingly
      // Case 1: download error
      if let error = downloadError {
        println("erro task for get method: user data")
        completionHandler(error: NSError(domain: "GetUserData", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network Error"]))
      }
      // Case 2: download successful
      else {
        println("success with task for get method: user data.")
        // check for the user data and grab the last name
        if let user = JSONResult.valueForKey(JSONResponseKeys.User) as? NSDictionary {
          if let userLastName = user.valueForKey(JSONResponseKeys.UserLastName) as? String {
            // store the user last name in our data
            Data.sharedInstance().userLastName = userLastName
            
            // then check for the first name
            if let userFirstName = user.valueForKey(JSONResponseKeys.UserFirstName) as? String {
              Data.sharedInstance().userFirstName = userFirstName
              //set the completion handler
              completionHandler(error: nil)
            }
            else {
              println("couldn't find first name in \(user)")
              completionHandler(error: NSError(domain: "GetUserData", code: 2, userInfo: [NSLocalizedDescriptionKey: "Parsing error for first_name in \(user)"]))
            }
          }
          else {
            println("couldn't find last name in \(user)")
            completionHandler(error: NSError(domain: "GetUserData", code: 2, userInfo: [NSLocalizedDescriptionKey: "Parsing error for last_name in \(user)"]))
          }
        }
        else {
          println("couldn't find user \(JSONResult)")
          completionHandler(error: NSError(domain: "GetUserData", code: 2, userInfo: [NSLocalizedDescriptionKey: "Parsing error for user in \(JSONResult)"]))
        }
      }
    }
  }
  
  /* LOGOUT UDACITY SESSION */
  func logoutFromUdacity(completionHandler: ((success: Bool, error: NSError?) -> Void)) {
    
    // 1- Specify parameters
    let method = Methods.Session
    
    // 2- Make the request using taskfordelete method
    let task = self.taskForDELETEMethod(method) { JSONResult, downloadError in
      
      // Set the completion handler accordingly
      // Case 1: download error
      if let error = downloadError {
        completionHandler(success: false, error: NSError(domain: "LogoutFromUdacity", code: 0, userInfo: [NSLocalizedDescriptionKey: "Network Error"]))
      }
      // Case 2: download successful
      else {
        if let sessionDictioanry = JSONResult.valueForKey(JSONResponseKeys.Session) as? NSDictionary {
          if let id = sessionDictioanry.valueForKey(JSONResponseKeys.ID) as? String {
            completionHandler(success: true, error: nil)
            
          } else {
            completionHandler(success: false, error: NSError(domain: "LogoutFromUdacity", code: 1, userInfo: [NSLocalizedDescriptionKey: "Parsing error for id"]))
          }
          
        } else {
          completionHandler(success: false, error: NSError(domain: "LogoutFromUdacity", code: 2, userInfo: [NSLocalizedDescriptionKey: "Parsing error for session"]))
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
