//
//  UdacityAPIConstants.swift
//  OnTheMap
//
//  Created by Jeremy Broutin on 7/16/15.
//  Copyright (c) 2015 Jeremy Broutin. All rights reserved.
//

import Foundation

extension UdacityAPIClient {
  
  //Constants
  struct Constants {
    static let baseSecureURLString = "https://www.udacity.com/api/"
  }
  
  //Methods
  struct Methods {
    static let Session = "session"
    static let PublicData = "users"
  }
  
  //JSON Body Keys
  struct JSONBodyKeys {
    static let Udacity = "udacity"
    static let Username = "username"
    static let Password = "password"
    static let FacebookMobile = "facebook_mobile"
    static let AccessToken = "access_token"
  }
  
  //JSON Response Keys
  struct JSONResponseKeys {
    static let Account = "account"
    static let Key = "key"
    static let StatusCode = "status"
    static let Error = "error"
    static let User = "user"
    static let UserFirstName = "first_name"
    static let UserLastName = "last_name"
    static let Session = "session"
    static let ID = "id"
    static let StatusMessage = "status_message"
  }
}