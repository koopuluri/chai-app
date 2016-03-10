//
//  LocationSelectionViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 2/1/16.
//  Copyright (c) 2016 Poop. All rights reserved.
//

import UIKit
import MapKit

class LocationSelectionViewController: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var pointerImage: UIImageView!
    
    @IBOutlet weak var createMeetButton: UIButton!
    
    
    var meetTitle: String!
    var meetDescription: String!
    
    
    @IBAction func cancelToMeetsViewController(segue:UIStoryboardSegue) {
        print("canceling out of select location view to MeetsViewController!")
    }
    
    @IBAction func createMeet(segue:UIStoryboardSegue) {
        print("in createMeet(), \(self.meetTitle), \(self.meetDescription)")
    }
    
    var locManager = CLLocationManager()
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    var initialized = false
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // if initial location not set to current location, do so: else nothing.
        if (!self.initialized) {
            let locValue:CLLocationCoordinate2D = locManager.location!.coordinate
            print("current coordinates: \(locValue.latitude), \(locValue.longitude)")
            let initialLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
            centerMapOnLocation(initialLocation)
            self.initialized = true
        } else {
            //println("already initialized, doing nothing for this redraw!")
        }
    }
    
    // pass on the newMeet to the MeetView that this is seguing to!
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("LocationSelectionController.prepareForSegue().destination: \(segue.destinationViewController)")
        if let meetNavController = segue.destinationViewController as? MeetNavigationController {
            let newMeet = Meetup(
                title: self.meetTitle,
                time: "in 10 minutes",
                count: 10,
                description: self.meetDescription,
                hostName: "Karthik Uppuluri",
                maxCount: 10,
                locationX: self.mapView.centerCoordinate.latitude,
                locationY: self.mapView.centerCoordinate.longitude)
            
            // setting the newMEet var for MeetViewController (the first view controller in the MeetNav stack:
            let meetController = meetNavController.viewControllers.first as! MeetController
            meetController.meet = newMeet
            meetController.isCurrentUserAttendee = true
            meetController.from = "All Meets"
            
        }

    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }

}
