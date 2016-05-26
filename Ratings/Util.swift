//
//  Util.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 5/22/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class Util {
    
    // sets the avatar image from the image url (picUrl) into the image view (avatarImage):
    static func setAvatarImage(picUrl: String, avatarImage: UIImageView) {
        
        let url = NSURL(string: picUrl)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            dispatch_async(dispatch_get_main_queue(), {
                avatarImage.image = UIImage(data: data!)
                avatarImage.layer.borderWidth = 0.5
                avatarImage.layer.masksToBounds = false
                avatarImage.layer.borderColor = UIColor.lightGrayColor().CGColor
                avatarImage.layer.cornerRadius = avatarImage.frame.height/2
                avatarImage.clipsToBounds = true
            });
        }
    }
    
    class LocationInfo: NSObject {
        var name: String?
        var coords: CLLocationCoordinate2D?
        var address: String?
    }
}