//
//  Data.swift
//  OnTheMap
//
//  Created by Jeremy Broutin on 7/16/15.
//  Copyright (c) 2015 Jeremy Broutin. All rights reserved.
//

import Foundation
import MapKit


class Data: NSObject {
  
  // Udacity username and password
  var username: String!
  var password: String!
  
  // Udacity student data
  var userID: String!
  var userFirstName: String!
  var userLastName: String!
  
  // Facebook data
  var fbAccessToken: String!
  
  // MARK: - Shared Instance
  class func sharedInstance() -> Data {
    struct Singleton {
      static var sharedInstance = Data()
    }
  return Singleton.sharedInstance
  }
}