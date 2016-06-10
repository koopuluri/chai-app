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
    
    static let MAX_TITLE_SIZE = 20
    static let MAX_DESCRIPTION_SIZE = 80
    
    static var CURRENT_USER_ID = "57129ebcedd2393b22395684"
    static var DEVICE_TOKEN: String?
    
    
    static func getDeviceTokenString(token: NSData) -> String {
        let tokenChars = UnsafePointer<CChar>(token.bytes)
        var tokenString = ""
        
        for i in 0..<token.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        return tokenString
    }
    
    
    // getting the day for display in format: mm/33/yyyy if date before today, else, "today" / "tomorrow" for future dates.
    static func getDay(date: NSDate) -> String {
        if (NSCalendar.currentCalendar().isDateInToday(date)) {
            return "today"
        }
        
        if (NSCalendar.currentCalendar().isDateInTomorrow(date)) {
            return "tomorrow"
        }
        
        // date is definitely in the past:
        return Util.getChatTimestamp(date)
    }
    
    
    static func getMeetTimestamp(meetTime: NSDate) -> String {
        if NSDate().compare(meetTime) == NSComparisonResult.OrderedAscending {
            return Util.getUpcomingMeetTimestamp(meetTime)
        } else {
            return Util.getChatTimestamp(meetTime)
        }
    }
    
    
    // for upcoming meets --> currently used for all timestamps in MeetsViewController as all meets displayed there are upcoming only.
    static func getUpcomingMeetTimestamp(meetTime: NSDate) -> String {
        let now = NSDate()
        
        if (now.hoursFrom(meetTime) == 0) {
            // return num minutes:
            return "in " + String(now.minutesFrom(meetTime)) + "m"
        } else {
            // return the time:
            let formatter = NSDateFormatter()
            formatter.timeStyle = .ShortStyle
            let dateString = formatter.stringFromDate(meetTime)
            
            print("dateString: \(dateString)")
            let comps = dateString.componentsSeparatedByString(" ")
            
            // now getting the last 2 sections:
            return comps[comps.count - 2] + comps[comps.count - 1].lowercaseString
        }
    }
    
    // FB messenger style timestamps
    static func getChatTimestamp(chatTime: NSDate) -> String {
        let now = NSDate()
        
        if (now.daysFrom(chatTime) == 0) {
            // display in terms of hours / mins ago
            let hours = now.hoursFrom(chatTime)
            if (hours == 0) {
                // display in mins:
                let mins = now.minutesFrom(chatTime)
                return "\(mins)m ago"
            } else {
                return "\(hours)h ago"
            }
        } else {
            // return the date:
            let formatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            let dateString = formatter.stringFromDate(chatTime)
            let comps = dateString.componentsSeparatedByString(" ")
            return comps[0]
        }
    }
    
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

// convenience methods to get deltas b/w two dates. Obtained from: http://stackoverflow.com/a/27184261; author: S/O user "Leo Dabus"
extension NSDate {
    func yearsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: self, options: []).year
    }
    func monthsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: []).month
    }
    func weeksFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
    }
    func daysFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: []).day
    }
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
    }
    func minutesFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
    }
    func secondsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: []).second
    }
    func offsetFrom(date:NSDate) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))w"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return ""
    }
}


