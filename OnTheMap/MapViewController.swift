//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jeremy Broutin on 7/18/15.
//  Copyright (c) 2015 Jeremy Broutin. All rights reserved.
//

import Foundation
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
  
  @IBOutlet weak var mapView: MKMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mapView.delegate = self
  }
  
}
