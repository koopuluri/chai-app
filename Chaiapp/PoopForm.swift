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
    var meetTime = false
}

class PoopForm: UITableViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var submitSpinner: UIActivityIndicatorView!
    @IBOutlet weak var submitButton: SwiftyButton!
    
    @IBOutlet weak var startTimeDatePicker: UIDatePicker!
    @IBOutlet weak var daySegment: UISegmentedControl!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var maxAttendeesSegment: UISegmentedControl!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var durationSegment: UISegmentedControl!
    @IBOutlet weak var locationSpinner: UIActivityIndicatorView!

    let LOCATION_ROW = 3
    
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
        self.descriptionTextField.userInteractionEnabled = val
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
        print("title: \(titleTextField.text!)")
        print("description: \(descriptionTextField.text)")
        print("maxAttendees: \(maxAttendees)")
        print("duration: \(duration)")
        print("loc.coords: \(locInfo?.coords)")
        print("loc.address: \(locInfo?.address)")

        
        func success(meetId: String) {
            self.newMeetId = meetId
            self.performSegueWithIdentifier("NewMeetSegue", sender: self)
        }
        
        func fail(error: String) {
            // replacing the loading spinner with the submit button again:
            self.submitSpinner.hidden = true
            self.submitButton.hidden = false
            
            // un-disabling the form:
            self.enableForm()
            
            // display a UIAlertView with message:
            let alert = UIAlertController(title: ":(", message: error, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        API.createMeet(self.titleTextField.text!, desc: self.descriptionTextField.text!, maxAttendees: maxAttendees!, duration: duration, time: self.meetTimestamp, loc: self.locInfo!.coords!, locName: (self.locInfo?.name)!, locAddress: (self.locInfo?.address)!, success: success, fail: fail)

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
        if (validation.titleText && validation.location && validation.meetTime) {
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
        if (indexPath.row == self.LOCATION_ROW && !self.isDisabled) {
            print("selected the location row!")
            self.performSegueWithIdentifier("SelectLocationSegue", sender: self)
        }
    }
    
    
    override func viewDidLoad() {
        
        self.navigationItem.leftBarButtonItem?.tintColor = Util.getMainColor()
        self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        // no lines b/w the cells:
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // disabling and styling the submit button:
        submitButton.enabled = false
        submitButton.setTitle("Submit", forState: UIControlState.Normal)
        submitButton.buttonColor = Util.getMainColor()
        submitButton.shadowHeight = 0
        submitButton.highlightedColor = UIColor.greenColor()
        
        self.startTimeDatePicker.addTarget(self, action: Selector("datePickerChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        // hiding the spinner:
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
        titleTextField.returnKeyType = UIReturnKeyType.Done
        
        // description text view:
        descriptionTextField.delegate = self
        descriptionTextField.layer.borderWidth = 1.0
        descriptionTextField.layer.cornerRadius = 5.0
        descriptionTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        descriptionTextField.attributedPlaceholder = NSAttributedString(string: "Meet Description", attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()])
        descriptionTextField.font = UIFont(name: "System", size: CGFloat(12.0))
        descriptionTextField.returnKeyType = UIReturnKeyType.Done
        
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
        daySegment.addTarget(self, action: Selector("daySegmentChanged:"), forControlEvents: UIControlEvents.ValueChanged)

        
        
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
    
    // gets the timestamp by using the selected day and time information from "daySegment" and "startTimePicker"
    func validateFormTimestamp() {
        let selectedDate = self.startTimeDatePicker.date
        let daySelection = self.daySegment.selectedSegmentIndex
        
        if (daySelection == 0) {
            self.meetTimestamp = selectedDate
        } else {
            // need to add a day to startTime to get the meet timestamp:
            let allUnits = NSCalendarUnit(rawValue: UInt.max)
            let startTimeComponents = NSCalendar.currentCalendar().components(allUnits, fromDate: selectedDate)
            startTimeComponents.day = startTimeComponents.day + 1
            let calendar = NSCalendar.currentCalendar()
            self.meetTimestamp = calendar.dateFromComponents(startTimeComponents)!
        }

        if (NSDate().compare(self.meetTimestamp) == NSComparisonResult.OrderedAscending) {
            self.validation.meetTime = true
        } else {
            self.validation.meetTime = false
        }
        self.validateButton()
    }
    
    func daySegmentChanged(daySegment: UISegmentedControl) {
        validateFormTimestamp()
    }
    
    // for the datePicker, on change, validate:
    func datePickerChanged(datePicker:UIDatePicker) {
        validateFormTimestamp()
    }
    
    // Text Field delegate funcs:
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.utf16.count + string.utf16.count - range.length
        
        if (textField.tag == 1) {
            if newLength == 0 {
                // show error:
                textField.layer.borderColor = UIColor.redColor().CGColor
                
                self.validation.titleText = false
                self.validateButton()
                return true
            } else {
                self.validation.titleText = true
                self.validateButton()
            }
            
            textField.layer.borderColor = UIColor.lightGrayColor().CGColor
            return newLength <= Util.MAX_TITLE_SIZE // Bool
        } else {
            // desc text field:
            let newLength = text.utf16.count + string.utf16.count - range.length
            return newLength <= Util.MAX_DESCRIPTION_SIZE
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}



























