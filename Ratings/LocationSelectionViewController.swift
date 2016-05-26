//
//  LocationSelectionViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 2/1/16.
//  Copyright (c) 2016 Poop. All rights reserved.
//

import UIKit
import MapKit

class LocationSelectionViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var pointerImage: UIImageView!
    
    @IBOutlet weak var createMeetButton: UIButton!

    var initialCoords: CLLocationCoordinate2D?
    
    var selectedCoords: CLLocationCoordinate2D?

    var meetTitle: String!
    var meetDescription: String!
    
    var locManager = CLLocationManager()
    var span = MKCoordinateSpanMake(0.01, 0.01)
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: false)
    }
    
    var initialized = false
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.selectedCoords = mapView.centerCoordinate
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // if initial location not set to current location, do so: else nothing.
        if (!self.initialized) {
            let initialLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(self.initialCoords!.latitude, self.initialCoords!.longitude)
            centerMapOnLocation(initialLocation)
            self.initialized = true
        } else {
            print("already initialized, doing nothing for this redraw!")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        // Core Location Manager asks for GPS location
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startMonitoringSignificantLocationChanges()
        
        // Check if the user allowed authorization
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways)
        {
            locManager.startUpdatingLocation()
            
        }  else {
            // if not authorized --> just show gatech? (But needs to be authorized in order to see the
            // list meets. In fact, that has to be done in the MainView as well (when querying server
            // to get the list of meets based on certain coordinates).
            print("location not authorized")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let createMeetController = segue.destinationViewController as? CreateMeetController {
            print("Going back to CreateMeetController!")
            //createMeetController.currentPosition = self.selectedCoords
            
        }
    }
}











