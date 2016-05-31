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
    
    // obtained from: http://stackoverflow.com/a/26794841
    static func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    static func getMainColor() -> UIColor {
        return Util.hexStringToUIColor("FF8000")
    }
    
    static func getDurationText(seconds: Int) -> String {
        // convert to human readable form:
        let (h, m, _) = Util.secondsToHoursMinutesSeconds(seconds)
        
        if (h != 0) {
            if (m != 0) {
                return "\(h)hr \(m)m"
            } else {
                let end = (h == 1) ? "hr" : "hrs"
                return "\(h)\(end)"
            }
        } else {
            return "\(m)m"
        }
    }
    
    // obtained from: http://stackoverflow.com/a/27203691
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
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
    
    static func getTimeString(hour: Int, min: Int) -> String {
        var minString = String(min)
        if (minString.characters.count == 1) {
            // need to pre-pend a 0:
            minString = "0" + minString
        }
        
        return String(hour) + ":" + minString
    }
    
    static func getComps(date: NSDate) -> NSDateComponents{
        let allUnits = NSCalendarUnit(rawValue: UInt.max)
        return NSCalendar.currentCalendar().components(allUnits, fromDate: date)
    }
    
    static func convertUTCTimestampToDate(timestamp: String?) -> NSDate{
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        let utcDate = formatter.dateFromString(timestamp!)
        return utcDate!
        
        // now converting to local date:
//        let tz = NSTimeZone.localTimeZone()
//        let seconds = tz.secondsFromGMTForDate(utcDate!)
//        return utcDate!.dateByAddingTimeInterval(NSTimeInterval(seconds))
    }
    
    // height for a specific UILabel:
    // http://stackoverflow.com/questions/25180443/adjust-uilabel-height-to-text
    static func setHeightForLabel(text: String, label: UILabel, font: UIFont) -> CGFloat{
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
    // calculate the height of a UILabel based on its contents:
    func heightForView(text: String, font: UIFont, width: CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
    class LocationInfo: NSObject {
        var name: String?
        var coords: CLLocationCoordinate2D?
        var address: String?
    }
}