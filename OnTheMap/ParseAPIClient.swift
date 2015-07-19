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
    
    /* 1. Set the parameters */
    // no need for additional parameters
    
    /* 2/3. Build the URL and configure the request */
    let urlString = Constants.baseSecureURLString + method + ParseAPIClient.escapedParameters(parameters)
    let url = NSURL(string: urlString)!
    let request = NSMutableURLRequest(URL: url)
    request.addValue(ParseAPIClient.Constants.ParseApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
    request.addValue(ParseAPIClient.Constants.RESTAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")

    
    /* 4. Make the request */
    let task = session.dataTaskWithRequest(request) {data, response, downloadError in
      
      /* 5/6. Parse the data and use the data (happens in completion handler) */
      if let error = downloadError {
        let newError = ParseAPIClient.errorForData(data, response: response, error: error)
        completionHandler(result: nil, error: downloadError)
      } else {
        ParseAPIClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
      }
    }
    
    /* 7. Start the request */
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
