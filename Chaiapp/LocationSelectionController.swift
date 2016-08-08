//
//  LocationSelectionController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 5/24/16.
//  Copyright © 2016 Poop. All rights reserved.
//
// This code snippet demonstrates adding a
// full-screen Autocomplete UI control

import UIKit
import GoogleMaps
import Eureka

class LocationSelectionController: GMSAutocompleteViewController {
    
    var selectedCoords: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        self.delegate = self
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let createMeetController = segue.destinationViewController as? PoopForm {
            print("Going back to PoopForm!")
        }
    }
}

extension LocationSelectionController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(viewController: GMSAutocompleteViewController, didAutocompleteWithPlace place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        print("place coords: \(place.coordinate)")
        self.selectedCoords = place.coordinate
        
        // TODO: HOLY SHIT THIS IS BAD PRACTICE, this VC should have no idea what parent is.
        let createMeetController = self.presentingViewController?.childViewControllers.first as! PoopForm!
        
        // setting the location info to pass back:
        let locInfo = Util.LocationInfo()
        locInfo.name = place.name
        locInfo.address = place.formattedAddress
        locInfo.coords = place.coordinate
        
        // setting the locInfo
        createMeetController.locInfo = locInfo

        // setting the value of the location selection row:
        let locRow = createMeetController.locationLabel
        locRow.text = place.formattedAddress
        print("set loc: \(self.selectedCoords!.latitude), \(self.selectedCoords!.longitude)")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func viewController(viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: NSError) {
        // TODO: handle the error.
        print("Error: \(error.description)")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // User canceled the operation.
    func wasCancelled(viewController: GMSAutocompleteViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}