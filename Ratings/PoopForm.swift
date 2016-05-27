//
//  PoopForm.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 5/25/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import AddressBookUI
import Alamofire
import SwiftyButton

class Validation: NSObject {
    var titleText = false
    var location = false
}

class PoopForm: UITableViewController, UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var submitSpinner: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: SwiftyButton!
    @IBOutlet weak var startTimeDatePicker: UIDatePicker!
    @IBOutlet weak var daySegment: UISegmentedControl!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var maxAttendeesSegment: UISegmentedControl!
    @IBOutlet weak var durationSegment: UISegmentedControl!
    
    @IBOutlet weak var locationSpinner: UIActivityIndicatorView!

    // validation variables:
    var locInfo: Util.LocationInfo?
    var meetTimestamp = NSDate()
    
    var isDisabled = false
    
    var validation = Validation()
    
    // location manager used to grab user's current location
    var locationManager = CLLocationManager()
    
    // new meet id (if creating meet was successful)
    var newMeetId: String?
    
    // FORM TOGGLING:
    func _toggleForm(val: Bool) {
        self.isDisabled = !val  // for the location segue to not be triggered.
        self.daySegment.userInteractionEnabled = val
        self.titleTextField.userInteractionEnabled = val
        self.descriptionTextView.userInteractionEnabled = val
        self.maxAttendeesSegment.userInteractionEnabled = val
        self.durationSegment.userInteractionEnabled = val
        self.startTimeDatePicker.userInteractionEnabled = val
    }
    
    // nothing can be edited / selected when disabled.
    func disableForm() {
        self._toggleForm(false)
    }
    
    func enableForm() {
        self._toggleForm(true)
    }
    
    
    @IBAction func submit(sender: AnyObject) {
        // button could not have been pressed if validations did not hold.
        // disable form:
        self.disableForm()
        
        // replace the submit button with spinner:
        self.submitButton.hidden = true
        self.submitSpinner.hidden = false
        self.submitSpinner.startAnimating()
        
        // now make a call to the server with the new meet information:
        // first need to convert a few values:
        
        // meet timestamp:
        let startTime = self.startTimeDatePicker.date
        let daySelection = self.daySegment.selectedSegmentIndex
        
        if (daySelection == 0) {
            self.meetTimestamp = startTime
        } else {
            // need to add a day to startTime to get the meet timestamp:
            let allUnits = NSCalendarUnit(rawValue: UInt.max)
            let startTimeComponents = NSCalendar.currentCalendar().components(allUnits, fromDate: startTime)
            startTimeComponents.day = startTimeComponents.day + 1
            let calendar = NSCalendar.currentCalendar()
            self.meetTimestamp = calendar.dateFromComponents(startTimeComponents)!
        }
        
        // duration --> calculating in seconds:
        let selectedDuration = self.durationSegment.selectedSegmentIndex
        var duration = 0
        
        if (selectedDuration == 0) {
            duration = 60*30
        } else if (selectedDuration == 1) {
            duration = 60*60
        } else if (selectedDuration == 2) {
            duration = 60*60*2
        } else {
            duration = 60*60*3
        }
        
        
        // maxAttendees:
        let maxAttendees = Int(self.maxAttendeesSegment.titleForSegmentAtIndex(self.maxAttendeesSegment.selectedSegmentIndex)!)
        
        
        // doing final validation:
        if (locInfo == nil) {
            // stop and tell user
        }
        
        if (NSDate().compare(self.meetTimestamp) == NSComparisonResult.OrderedDescending) {
            print("Oh no! --> startTime has passed!")
            // stop and tell user
        }
        
        
        // combining information and sending to server:
        // make the call:
        let url = "https://one-mile.herokuapp.com/create_meet"
        
        print("title: \(titleTextField.text!)")
        print("description: \(descriptionTextView.text)")
        print("maxAttendees: \(maxAttendees)")
        print("duration: \(duration)")
        print("loc.coords: \(locInfo?.coords)")
        print("loc.address: \(locInfo?.address)")
        
        
        Alamofire.request(.POST, url,
            parameters: [
                "title": self.titleTextField.text!,
                "description": self.descriptionTextView.text,
                "maxAttendees": maxAttendees!,
                "duration": duration,
                "timestamp": self.meetTimestamp,
                "loc.lat": (self.locInfo!.coords?.latitude)!,
                "loc.long": (self.locInfo!.coords?.longitude)!,
                "loc.name": self.locInfo!.name!,
                "loc.address": self.locInfo!.address!
            ])
            .responseJSON { response in
                
                // setting isJoining to false (must be true right now, or we wouldn't be here);
                print("handling the returned thing from Request");
                
                if let JSON = response.result.value {
                    
                    if (JSON["error"]! != nil) {
                        
                        // replacing the loading spinner with the submit button again:
                        self.submitSpinner.hidden = true
                        self.submitButton.hidden = false
                        
                        // un-disabling the form:
                        self.enableForm()
                        
                        // display a UIAlertView with message:
                        let alert = UIAlertController(title: ":(", message: (JSON["error"]! as! String!), preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        
                        self.newMeetId = JSON["savedMeetId"]! as! String!
                        
                        // programmatically seguing to the meetController to render the just created meet:
                        self.performSegueWithIdentifier("NewMeetSegue", sender: self)
                    }
                }
        }
        
        
    }
    
    // takes coords and gives name and address for a location:
    func reverseGeocoding(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            var address = ""
            var name = ""
            
            if error != nil {
                print(error)
                
                // tell user that current location information could not be retreived.
                return
                
            } else if placemarks?.count > 0 {
                let pm = placemarks![0]
                address = ABCreateStringWithAddressDictionary(pm.addressDictionary!, false)
                if pm.areasOfInterest?.count > 0 {
                    name = (pm.areasOfInterest?[0])!
                } else {
                    //print("No area of interest found.")
                }
            }
            
            // setting current location:
            self.locInfo = Util.LocationInfo()
            self.locInfo!.name = name
            self.locInfo!.address = address
            self.locInfo!.coords = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            self.locationLabel.text = address
            
            // validate the submit button:
            self.validation.location = true
            self.validateButton()
            
        })
        
        // stop the spinner:
        self.locationSpinner!.hidden = true
    }
    
    func validateButton() {
        if (validation.titleText && validation.location) {
            self.submitButton.enabled = true
        } else {
            self.submitButton.enabled = false
        }
    }
    
    
    // grabbing the user's current location information:
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (self.locInfo == nil) {
            let currentPosition = manager.location!.coordinate
            // now making a call with the current coordinates to obtain the address for this location:
            self.reverseGeocoding((currentPosition.latitude), longitude: (currentPosition.longitude))
            
        } else {
            // do nothing: locInfo already set.
        }
    }
    
    
    // when location row selected, launch the Google Place Picker:
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell number: \(indexPath.row)!")
        if (indexPath.row == 2 && !self.isDisabled) {
            print("selected the location row!")
            self.performSegueWithIdentifier("SelectLocationSegue", sender: self)
        }
    }
    
    
    // for the Title text field:
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.utf16.count + string.utf16.count - range.length
        
        if newLength == 0 {
            // show error:
            titleTextField.layer.borderColor = UIColor.redColor().CGColor
            
            validation.titleText = false
            self.submitButton.enabled = false
            return true
        } else {
            validation.titleText = true
            validateButton()
        }
        
        titleTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        return newLength <= 5 // Bool
    }
    
    // for the description text view:
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let maxtext: Int = 140
        guard let string = textView.text else {return true}
        //If the text is larger than the maxtext, the return is false
        
        // Swift 2.0
        return textView.text.characters.count + (text.characters.count - range.length) <= maxtext
    }
    
    override func viewDidLoad() {
        
        submitButton.enabled = false
        submitSpinner.hidden = true
        
        self.locationSpinner.startAnimating()
        
        
        // setting the location manager stuff:
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            print("locationManager stuff set in viewdidLoad()")
        }
        
        // title text field
        titleTextField.delegate = self
        titleTextField.layer.borderWidth = 1.0
        titleTextField.layer.cornerRadius = 5.0
        titleTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        titleTextField.attributedPlaceholder = NSAttributedString(string: "Meet Title", attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()])
        
        // description text view:
        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        descriptionTextView.layer.cornerRadius = 5.0
        descriptionTextView.backgroundColor = UIColor.whiteColor()
        descriptionTextView.delegate = self
        
        // attendees segment:
        maxAttendeesSegment.setTitle("2", forSegmentAtIndex: 0)
        maxAttendeesSegment.setTitle("3", forSegmentAtIndex: 1)
        maxAttendeesSegment.setTitle("5", forSegmentAtIndex: 2)
        maxAttendeesSegment.setTitle("10", forSegmentAtIndex: 3)
        maxAttendeesSegment.setTitle("20", forSegmentAtIndex: 4)
        maxAttendeesSegment.setTitle("100", forSegmentAtIndex: 5)
        maxAttendeesSegment.tintColor = UIColor.orangeColor()
        
        // startTimePicker:
        startTimeDatePicker.datePickerMode = UIDatePickerMode.Time
        
        // day:
        let dateFormatter = NSDateFormatter()
        //To prevent displaying either date or time, set the desired style to NoStyle.
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
        dateFormatter.timeZone = NSTimeZone()
        dateFormatter.dateFormat = "MM/dd"
        
        let todayLabel = "today: \(dateFormatter.stringFromDate(NSDate()))"
        let tomorrowLabel = "tomorrow: \(dateFormatter.stringFromDate(NSDate().dateByAddingTimeInterval(60*60*24)))"
        
        daySegment.setTitle(todayLabel, forSegmentAtIndex: 0)
        daySegment.setTitle(tomorrowLabel, forSegmentAtIndex: 1)
        
        
        // duration:
        durationSegment.setTitle("30 mins", forSegmentAtIndex: 0)
        durationSegment.setTitle("1 hr", forSegmentAtIndex: 1)
        durationSegment.setTitle("2 hr", forSegmentAtIndex: 2)
        durationSegment.setTitle("3 hr", forSegmentAtIndex: 3)
        
        // tableView:
        tableView.backgroundColor = UIColor.orangeColor()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let meetChatNavController = segue.destinationViewController as? MeetChatNavController {
            let meetChatController = meetChatNavController.viewControllers.first as! MeetChatPageViewController
            print("seguing to meetChatController view UserMeets:: \(newMeetId)")
            meetChatController.meetId = newMeetId!
            meetChatController.from = "Meets"
            meetChatController.mode = "Meet"
        }
    }
}




























