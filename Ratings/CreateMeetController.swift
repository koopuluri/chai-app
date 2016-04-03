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

class CreateMeetController : FormViewController, CLLocationManagerDelegate {
    
    var currentPosition: CLLocationCoordinate2D?
    
    var newMeetId: String?
    
    let dummyUserId = "56dbb2013cd9a60ed58b1ae3" // currently DUMMY_USER2!
    
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBAction func unwindToCreateMeet(segue: UIStoryboardSegue) {}
    
    var locationManager = CLLocationManager()
    
    // loading spinner displayed on submit():
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (self.currentPosition == nil) {
            self.currentPosition = manager.location!.coordinate
            let locRow: ButtonRow = self.form.rowByTag("Location")!
            locRow.value = "\(self.currentPosition!.latitude), \(self.currentPosition!.longitude)"
            locRow.title = "\(self.currentPosition!.latitude), \(self.currentPosition!.longitude)"
            print("set the title! for location row \(self.currentPosition!)!")
            locRow.reload()
        } else {
            // do nothing: currentPosition is already set.
        }
    }
    
    // set the meetId for the meetController...
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // display the tabBar at the bottom now:
        self.tabBarController?.tabBar.hidden = false
        
        
        if let locationController = segue.destinationViewController as? LocationSelectionViewController {
            locationController.initialCoords = self.currentPosition
        }
        
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
        
        if values["StartTime"]! == nil {
            pass = false
            messages += "Start time not set."
        } else {
            let startTime = values["StartTime"]! as! NSDate!
            let currDate = NSDate()
            
            // this means that the startTime has passed!
            if currDate.compare(startTime) == NSComparisonResult.OrderedDescending {
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
        if self.currentPosition == nil {
            print("currentPosition: \(self.currentPosition)")
            pass = false
            messages += "Location not set\n"
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
            print("location: \(self.currentPosition)")
            
            
            // make the call:
            let url = "https://one-mile.herokuapp.com/create_meet"
            
            Alamofire.request(.POST, url,
                parameters: [
                    "userId": self.dummyUserId,
                    "title": values["Title"]! as! String!,
                    "description": values["Description"]! as! String!,
                    "maxAttendees": values["MaxAttendees"]! as! String!,
                    "duration": values["Duration"]! as! Int!,
                    "startTime": values["StartTime"]! as! NSDate!,
                    "lat": Double((self.currentPosition?.latitude)!),
                    "long": Double((self.currentPosition?.longitude)!)
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
                        self.performSegueWithIdentifier("NewMeetSegue", sender: nil)
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
        
        // hiding bottom tabBar:
        self.tabBarController?.tabBar.hidden = true
        
        // location stuffs:
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        // form stuffs:
        self.form +++= Section("About")
        
            <<< TextRow("Title") {
                $0.placeholder = "Title"
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
                if self.currentPosition == nil {
                    //row.title = "Current Location"
                } else {
                    //row.title = "Location: long: \(String(self.currentPosition!.latitude)) lat: \(String(self.currentPosition?.longitude))"
                }
        
                row.presentationMode = .SegueName(segueName: "SelectLocationSegue", completionCallback:{  vc in vc.dismissViewControllerAnimated(true, completion: nil) })
            }
    }
}
