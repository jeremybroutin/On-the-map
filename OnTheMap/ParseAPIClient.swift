//
//  ParseAPIClient.swift
//  OnTheMap
//
//  Created by Jeremy Broutin on 7/19/15.
//  Copyright (c) 2015 Jeremy Broutin. All rights reserved.
//

import Foundation

class ParseAPIClient: NSObject {
  
  // Shared session
  var session: NSURLSession
  
  override init() {
    session = NSURLSession.sharedSession()
    super.init()
  }
  
  // MARK: - task for GET method
  
  func taskForGETMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
    
    // 1- Set the parameters
    // no need for additional parameters
    
    // 2- Build the url
    let urlString = Constants.baseSecureURLString + method + ParseAPIClient.escapedParameters(parameters)
    let url = NSURL(string: urlString)!
    
    // 3- Configure the request
    let request = NSMutableURLRequest(URL: url)
    request.addValue(ParseAPIClient.Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue(ParseAPIClient.Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")

    
    // 4- Make the request
    let task = session.dataTaskWithRequest(request) {data, response, downloadError in
      
      // 5&6- Parse and use the data
      if let error = downloadError {
        let newError = ParseAPIClient.errorForData(data, response: response, error: error)
        completionHandler(result: nil, error: downloadError)
      } else {
        ParseAPIClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
      }
    }
    
    // 7- Start the request
    task.resume()
    
    return task
  }
  
  // MARK: - task for POST Method
  func taskForPostMethod(method: String, jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
    
    // 1- Set the parameters
    //Defined in the jsonBody argument
    
    // 2- Build the url
    let urlString = Constants.baseSecureURLString + method
    let url = NSURL(string: urlString)!
    
    // 3- Configure the request
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "POST"
    request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
    var jsonifyError: NSError? = nil
    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: nil, error: &jsonifyError)
    
    // 4- Make the request
    let task = session.dataTaskWithRequest(request) { data, response, downloadError in
      
      // 5&6- Parse and use the data
      if let error = downloadError {
        let newError = UdacityAPIClient.errorForData(data, response: response, error: error)
        completionHandler(result: nil, error: newError)
      }
      else {
        println("task for post: task was successful")
        ParseAPIClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
      }
    }
    
    
    // 7- Start the request
    task.resume()
    
    return task
    
  }
  
  // MARK: - Helper functions
  
  /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
  class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
    
    if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
      
      if let errorMessage = parsedResult[ParseAPIClient.JSONResponseKeys.StatusMessage] as? String {
        
        let userInfo = [NSLocalizedDescriptionKey : errorMessage]
        
        return NSError(domain: "Parse Error", code: 0, userInfo: userInfo)
      }
    }
    
    return error
  }
  
  /* Helper: Given raw JSON, return a usable Foundation object */
  class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
    
    var parsingError: NSError? = nil
    let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
    
    if let error = parsingError {
      completionHandler(result: nil, error: error)
    } else {
      completionHandler(result: parsedResult, error: nil)
    }
  }
  
  /* Helper function: Given a dictionary of parameters, convert to a string for a url */
  class func escapedParameters(parameters: [String : AnyObject]) -> String {
    var urlVars = [String]()
    for (key, value) in parameters {
      
      /* Make sure that it is a string value */
      let stringValue = "\(value)"
      
      /* Escape it */
      let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
      
      /* Append it */
      urlVars += [key + "=" + "\(escapedValue!)"]
    }
    return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
  }
  
  // MARK: - Shared Instance
  
  class func sharedInstance() -> ParseAPIClient {
    struct Singleton {
      static var sharedInstance = ParseAPIClient()
    }
    return Singleton.sharedInstance
  }
  
  
}
