//
//  TableViewController.swift
//  OnMyApp
//
//  Created by Jeremy Broutin on 7/19/15.
//  Copyright (c) 2015 Jeremy Broutin. All rights reserved.
//

import Foundation
import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var refreshActivityIndicator: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    
    //set the navigation bar
    NavigationViewController.sharedInstance().setNavBar(self)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    refreshActivityIndicator.stopAnimating()
    refreshActivityIndicator.hidden = true
    tableView.hidden = false
    tableView.reloadData()
  }
  
  
  // MARK: - UITableViewDatSource
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Data.sharedInstance().studentsLocations.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    // define the cell
    let cellIdentifier = "customCell"
    let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! UITableViewCell
    
    // access single entry from data set
    let studentLocation = Data.sharedInstance().studentsLocations[indexPath.row]
    
    // set the cell properties
    cell.textLabel!.text = studentLocation.firstName + " " + studentLocation.lastName
    cell.detailTextLabel!.text = studentLocation.mediaURL
    cell.imageView!.image = UIImage(named: "Marker")
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let studentLocation = Data.sharedInstance().studentsLocations[indexPath.row]
    let studentURL = NSURL(string: studentLocation.mediaURL)!
    
    //check if the URL can be opened
    if UIApplication.sharedApplication().canOpenURL(studentURL){
      UIApplication.sharedApplication().openURL(studentURL)
    }
    else{
      // set variables
      let title = "Oups... an error ocurred!"
      let message = "The URL couldn't be opened."
      let action = "OK"
      // trigger alert
      var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
      alert.addAction(UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil))
      self.presentViewController(alert, animated: true, completion: nil)
    }
    
  }
  
}