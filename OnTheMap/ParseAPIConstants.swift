//
//  ParseAPIConstants.swift
//  OnTheMap
//
//  Created by Jeremy Broutin on 7/19/15.
//  Copyright (c) 2015 Jeremy Broutin. All rights reserved.
//

import Foundation

extension ParseAPIClient {
  
  //Constants
  struct Constants {
    static let baseSecureURLString = "https://api.parse.com/"
    static let ParseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let RESTAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
  }
  
  //Methods
  struct Methods {
    static let StudentLocation = "1/classes/StudentLocation"
  }
  
  //JSON Body Keys
  struct JSONBodyKeys {
    
  }
  
  //JSON Response Keys
  struct JSONResponseKeys {
    
    static let StatusMessage = "status_message"
    static let Results = "results"
    
    static let ObjectID = "objectId"
    static let UniqueKey = "uniqueKey"
    static let FirstName = "firstName"
    static let LastName = "lastName"
    static let MapString = "mapString"
    static let MediaURL = "mediaURL"
    static let Latitude = "latitude"
    static let Longitude = "longitude"
    
    /* No need to parse DATE and ACL */
    //static let CreatedAt = "createdAt"
    //static let UpdatedAt = "updatedAt"
    //static let ACL = "ACL"
  }
  
}
