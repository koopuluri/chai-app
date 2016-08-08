//
//  MapCell.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 5/30/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit
import GoogleMaps

class MapCell: UITableViewCell {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    var userLocation: CLLocationCoordinate2D?
    var meetLocation: CLLocationCoordinate2D?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // sets the user current location and the meet location in the map view:
    // called from parent tableView.
    func setMap(userLocation: CLLocationCoordinate2D?,
                meetLocation: CLLocationCoordinate2D?,
                meetLocationName: String?,
                meetLocationAddress: String?) {
        
        self.userLocation = userLocation
        self.meetLocation = meetLocation
        
        print("SET MAP: \(self.meetLocation) --> \(meetLocationAddress)")
        
        mapView.myLocationEnabled = true
        
        // place camera at the userLocation:
        let camera = GMSCameraPosition.cameraWithTarget(userLocation!, zoom: 12)
        mapView.camera = camera
        
        // now annotate map with the meetLocation:
        let marker = GMSMarker()
        marker.position = meetLocation!
        
        // setting the location name and address:

        
        if (meetLocationName != nil) {
            marker.title = meetLocationName!
        }
        
        if (meetLocationAddress != nil) {
            marker.snippet = meetLocationAddress!
        }
        
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = mapView
        
        self.loadingSpinner.hidden = true
        
        mapView.selectedMarker = marker

    }
    
    func setup() {
        self.loadingSpinner.color = Util.getMainColor()
        
        // let's try this first:
        mapView.myLocationEnabled = true
    }
    
    func startLoading() {
        self.loadingSpinner.hidden = false
        self.loadingSpinner.startAnimating()
        self.mapView.hidden = true
    }
    
    func stopLoading() {
        self.loadingSpinner.hidden = true
        self.loadingSpinner.stopAnimating()
        self.mapView.hidden = false
    }
}
