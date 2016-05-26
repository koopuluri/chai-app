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
        //let acController = GMSAutocompleteViewController()
        self.delegate = self
        //self.presentViewController(acController, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let createMeetController = segue.destinationViewController as? CreateMeetController {
            print("Going back to CreateMeetController!")
            
            let locRow: ButtonRow = createMeetController.form.rowByTag("Location")!
            locRow.value = "\(self.selectedCoords!.latitude), \(self.selectedCoords!.longitude)"
            locRow.title = "\(self.selectedCoords!.latitude), \(self.selectedCoords!.longitude)"
            
            print("set loc: \(self.selectedCoords!.latitude), \(self.selectedCoords!.longitude)")
            locRow.reload()

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
        let createMeetController = self.presentingViewController?.childViewControllers.first as! CreateMeetController!
        
        // setting the location info to pass back:
        var locInfo = Util.LocationInfo()
        locInfo.name = place.name
        locInfo.address = place.formattedAddress
        locInfo.coords = place.coordinate
        
        createMeetController.selectedLocationInfo = locInfo

        // setting the value of the location selection row:
        let locRow: ButtonRow = createMeetController.form.rowByTag("Location")!
        locRow.value = place.formattedAddress
        locRow.title = place.formattedAddress
        
        print("set loc: \(self.selectedCoords!.latitude), \(self.selectedCoords!.longitude)")
        locRow.reload()
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