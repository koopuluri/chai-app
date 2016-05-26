//  CreateMeetController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 3/12/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import Eureka
import UIKit
import Foundation
import MapKit
import Alamofire
import GoogleMaps
import AddressBookUI

class CreateMeetController : FormViewController, CLLocationManagerDelegate {
    
    var meetTimestamp = NSDate()
    
    var currentLocInfo: Util.LocationInfo?
    
    var selectedLocationInfo: Util.LocationInfo?
    
    var locationSpinner: UIActivityIndicatorView?
    
    var newMeetId: String?
    
    let dummyUserId = "56dbb2013cd9a60ed58b1ae3" // currently DUMMY_USER2!
    
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBAction func unwindToCreateMeet(segue: UIStoryboardSegue) {}
    
    var locationManager = CLLocationManager()
    
    // loading spinner displayed on submit():
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    
    func reverseGeocoding(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        print("REVERSE GEOENCODING")
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            var address = ""
            var name = ""
            let locRow: ButtonRow = self.form.rowByTag("Location")!
            
            if error != nil {
                print(error)
                
                // tell user that current location information could not be retreived.
                locRow.title = "Could not find current location"
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
            self.currentLocInfo = Util.LocationInfo()
            self.currentLocInfo!.name = name
            self.currentLocInfo!.address = address
            self.currentLocInfo!.coords = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            // now updating the location row:
            locRow.title = address
            locRow.value = address
            
            print("address: \(address)")
            print("name: \(name)")
            
            locRow.updateCell()
        })
        
        // stop the spinner:
        self.locationSpinner!.hidden = true
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (self.currentLocInfo == nil) {
            let currentPosition = manager.location!.coordinate
            
             // now making a call with the current coordinates to obtain the address for this location:
            
            //self.reverseGeocoding((currentPosition.latitude), longitude: (currentPosition.longitude))
            let lat = CLLocationDegrees(33.783766033)
            let long = CLLocationDegrees(-84.3979370)
            self.reverseGeocoding((lat), longitude: long)
            
        } else {
            // do nothing: currentPosition is already set.
        }
    }
    
    // when location manager fails:
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("loc failed! \(error.localizedDescription)")
    }
    
    // set the meetId for the meetController...
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if let meetNavController = segue.destinationViewController as? MeetChatNavController {
            let meetController = meetNavController.viewControllers.first as! MeetChatPageViewController
            meetController.meetId = self.newMeetId!
            meetController.from = "All Meets"
            meetController.mode = "Meet"
            
            print("meetController meet set coming from CreateMeetController")
        }
    }
    
    
    // submit and perform the "JoinMeet()" style call to the server to createMeet.
    // if values don't pass validation:
    // - spring up an AlertView with the required message!
    @IBAction func submit(sender: UIBarButtonItem) {
        
        // the values submitted by user:
        var values = self.form.values()
        
        // whether all the values submitted by user pass validations:
        var pass = true
        
        // the error message to be output via an AlertView if validations not met
        var messages = ""
        
        
        // validations:
        
        // TITLE:
        if values["Title"]! == nil || ((values["Title"]! as! String!).characters.count == 0) {
            pass = false
            messages += "Title can't be empty.\n"
        } else if (values["Title"]! as! String!).characters.count > 40{
            pass = false
            messages += "Title is longer than 40 characters.\n"
        }
        
        
        // DESCRIPTION:
        if values["Description"]! != nil && ((values["Description"]! as! String!).characters.count > 300) {
            pass = false
            messages += "Description is longer than 300 characters\n"
        } else if values["Description"]! == nil {
            values["Description"]! = ""
        }
        
        // MAX ATTENDEE COUNT:
        let attendeeCounts = ["2", "5", "10", "20", "50", "100", "No Limit"]
        if !attendeeCounts.contains((values["MaxAttendees"]! as! String!)) {
            pass = false
            messages += "Incorrect maximum attendee count.\n"
        }
        
        
        // START-TIME:
        let day = values["Day"]! as! String!
        
        if values["StartTime"]! == nil {
            pass = false
            messages += "Start time not set."
        } else {
            let startTime = values["StartTime"]! as! NSDate!
            let currDate = NSDate()
            
            if (day == "today") {
                self.meetTimestamp = startTime
            } else {
                let allUnits = NSCalendarUnit(rawValue: UInt.max)
                let startTimeComponents = NSCalendar.currentCalendar().components(allUnits, fromDate: startTime)
                
                startTimeComponents.day = startTimeComponents.day + 1
                
                let calendar = NSCalendar.currentCalendar()
                self.meetTimestamp = calendar.dateFromComponents(startTimeComponents)!
            }

            // this means that the startTime has passed!
            if currDate.compare(meetTimestamp) == NSComparisonResult.OrderedDescending {
                pass = false
                messages += "Start Time has already passed.\n"
            }
        }

        // DURATION;
        let duration = values["Duration"]! as! Int!
        let durationOptions = [10, 30, 60, 120]
        if !durationOptions.contains(duration) {
            pass = false
            messages += "Duraction value is incorrect.\n"
        }
        
        // LOCATION:
        
        // need to make sure lat, long points exist:
        pass = false
        if ((self.currentLocInfo != nil) && (self.currentLocInfo?.coords != nil)) {
            pass = true
        }
        

        // ========================================== NOW submitting to server / displaying error ==========================================:
        // if pass:
        // send request via Alamofire to the server, and do the loading shenanigans.
        if pass {

            self.hideForm()
            self.displayLoadingSpinner()
            
            // going to print everything we have, to predict the request:
            print("title: \(values["Title"])")
            print("description: \(values["Description"])")
            print("maxAttendees: \(values["MaxAttendees"])")
            print("startTime: \(values["StartTime"])")
            print("duration: \(values["Duration"])")
            
            
            // make the call:
            let url = "https://one-mile.herokuapp.com/create_meet"
            
            Alamofire.request(.POST, url,
                parameters: [
                    "userId": self.dummyUserId,
                    "title": values["Title"]! as! String!,
                    "description": values["Description"]! as! String!,
                    "maxAttendees": values["MaxAttendees"]! as! String!,
                    "duration": values["Duration"]! as! Int!,
                    "timestamp": self.meetTimestamp,
                    "loc.lat": (self.currentLocInfo!.coords?.latitude)!,
                    "loc.long": (self.currentLocInfo!.coords?.longitude)!,
                    "loc.name": self.currentLocInfo!.name!,
                    "loc.address": self.currentLocInfo!.address!
                ])
                .responseJSON { response in
                
                // setting isJoining to false (must be true right now, or we wouldn't be here);
                print("handling the returned thing from Request");
                
                if let JSON = response.result.value {
                    
                    if (JSON["error"]! != nil) {
                        
                        // replacing the loading spinner with the submit button again:
                        let submitButtonItem = UIBarButtonItem(title: "Submit", style: .Plain, target: self, action: "submit:")
                        self.navigationItem.rightBarButtonItem? = submitButtonItem
                        
                        // un-disabling the form:
                        self.showForm()
                        
                        // display a UIAlertView with message:
                        let alert = UIAlertController(title: ":(", message: (JSON["error"]! as! String!), preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        self.newMeetId = JSON["savedMeetId"]! as! String!
                        
                        // programmatically seguing to the meetController to render the just created meet:
                        //self.performSegueWithIdentifier("NewMeetSegue", sender: nil)
                    }
                }
            }
        } else {
            // need to render an alertView:
            // display a UIAlertView with message:
            let alert = UIAlertController(title: ":(", message: messages, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    func displayLoadingSpinner() {
        self.activityIndicator.startAnimating()
        let loadingView = UIBarButtonItem(customView: self.activityIndicator)
        self.navigationItem.rightBarButtonItem? = loadingView
    }
    

    func hideForm() {
        for row in self.form.rows {
            row.disabled = true
            row.evaluateDisabled()
        }
    }
    
    func showForm() {
        for row in self.form.rows {
            row.disabled = false
            row.evaluateDisabled()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        // spinner for the location row:
        locationSpinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        
        locationSpinner!.color = UIColor.orangeColor()
        locationSpinner!.startAnimating()
        
    
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            print("locationManager stuff set in viewdidLoad()")
        }
        
        
        // form stuffs:
        self.form +++= Section("About")
        
            <<< TextRow("Title") {
                $0.placeholder = "Title"
            }.cellSetup { cell, row in
                //cell.backgroundColor = UIColor.orangeColor()
                cell.layer.borderWidth = 1.0
                cell.layer.cornerRadius = 5.0
                cell.textField.delegate = TitleTextFieldDelegate()
            }.onChange { [weak self] row in
                    //print("description change: \(row.value!.characters.count)")
                    if row.value != nil {
                        if row.value!.characters.count > 12 {
//                            let index = row.value!.startIndex.advancedBy(40)
//                            row.value = row.value!.substringToIndex(index);
//                            print("modified row: \(row.value)")
                            row.cell.layer.borderColor = UIColor.redColor().CGColor
                        } else {
                            row.cell.layer.borderColor = UIColor.lightGrayColor().CGColor
                        }
                    }
            }
            
    
            <<< TextAreaRow("Description") {
                $0.placeholder = "Description"
            }.onChange { [weak self] row in
                //print("description change: \(row.value!.characters.count)")
                if row.value != nil {
                    if row.value!.characters.count > 40 {
                        let index = row.value!.startIndex.advancedBy(40)
                        row.value = row.value!.substringToIndex(index);
                        print("modified row: \(row.value)")
                    }
                }
            }
            
            <<< AlertRow<String>("MaxAttendees") {
                $0.title = "Maximum Num of Attendees"
                $0.options = ["2", "5", "10", "20", "50", "100", "No Limit"]
                $0.value = "10"
            }


        self.form +++= Section("When")
            
            <<< SegmentedRow<String>("Day") {
                $0.title = "Which day: "
                $0.options = ["today", "tomorrow"]
                $0.value = "today"
            }
            
            <<< TimeRow("StartTime") {
                $0.title = "Start Time: "
            }
            
            <<< SegmentedRow<Int>("Duration") {
                $0.title = "Duration (minutes): "
                $0.options = [10, 30, 60, 120]
                $0.value = 10
            }
        
        self.form +++= Section("Where")
        
            <<< ButtonRow("Location") { row in
                
                locationSpinner!.center = row.cell.contentView.center
                row.cell.contentView.addSubview(locationSpinner!)
                
                
                row.presentationMode = .SegueName(segueName: "SelectLocationSegue", completionCallback:{  vc in vc.dismissViewControllerAnimated(true, completion: nil) })
            }
    }
}

class TitleTextFieldDelegate: NSObject, UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        print("textFieldFunc!!!")
        guard let text = textField.text else { return true }
        let newLength = text.utf16.count + string.utf16.count - range.length
        return newLength <= 10 // Bool
    }
    
    func textFieldDidBeginEditing(textField: UITextField!) {    //delegate method
        print("text field begin editing")
    }
    
    func textFieldShouldEndEditing(textField: UITextField!) -> Bool {  //delegate method
        print("textFieldShouldEndEditin")
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {   //delegate method
        print("textFieldShouldReturn")
        textField.resignFirstResponder()
        
        return true
    }
}

class DescriptionTextFieldDelegate: NSObject, UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength <= 25
    }
}
