//
//  MeetController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 2/18/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit
import MapKit
import Alamofire

class MeetController: UITableViewController {
    
    var meetId: String?
    var from: String?
    
    var meet: AnyObject?
    
    var isCurrentUserHost = false
    var isCurrentUserAttendee = false
    
    let dummyUserId = "56dbb2013cd9a60ed58b1ae3" // currently DUMMY_USER2!
    
    var isJoining = false;

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var unwindButton: UIBarButtonItem!
    
    @IBOutlet weak var hostLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var threadToolbar: UIToolbar!
    
    @IBOutlet weak var locationView: MKMapView!
    
    @IBOutlet weak var joinSettingsButton: UIBarButtonItem!
    
    func setTheMeet() {
        if (self.meet != nil) {
            self.titleLabel.text = self.meet!["title"]! as! String!
            self.descriptionLabel.text = self.meet!["description"]! as! String!
            self.timeLabel.text = self.meet!["time"]! as! String!
            self.hostLabel.text = self.meet!["createdBy"]!!["firstName"]! as! String!
            self.numberLabel.text = String(self.meet!["count"]! as! Int!) + "/" + String(self.meet!["maxCount"]! as! Int!)
            
            // setting the join button text:
            if isCurrentUserAttendee || isCurrentUserHost{
                self.joinSettingsButton.title = "settings"
                
                // setting the color:
                if isCurrentUserHost {
                    self.numberLabel.textColor = UIColor.orangeColor()
                } else {
                    self.numberLabel.textColor = UIColor.greenColor();
                }
                
            } else {
                self.joinSettingsButton.title = "join"
                threadToolbar.hidden = true
            }
            
            // end refreshing:
            self.refreshControl?.endRefreshing()
        } else {
            print("meet is null right now")
        }
    }
    
    func fetchMeet() {
        // Pulling meet from server
        let url = "https://one-mile.herokuapp.com/get_meet?id=\(self.meetId!)&userId=\(self.dummyUserId)"
        print("url: \(url)")
        
        Alamofire.request(.GET, url) .responseJSON { response in
            
            
            if let JSON = response.result.value {
                // TODO: handle the error case!!
                print("Got meet")
                print(JSON)
                self.meet = JSON["meet"]
                self.isCurrentUserAttendee = (JSON["isAttending"]! as! Bool!)
                self.isCurrentUserHost = (JSON["isHost"]! as! Bool!)
                self.setTheMeet()
            }
        }
    }
    
    func joinMeet() {
        print("joining meet!")
        
        // making POST request to server to join meets:
        let url = "https://one-mile.herokuapp.com/join_meet"
        print("joinMeet() url: \(url)")
        
        
        Alamofire.request(.POST, url, parameters: ["meetId": self.meetId!, "userId": self.dummyUserId]) .responseJSON { response in
            
            // setting isJoining to false (must be true right now, or we wouldn't be here);
            self.isJoining = false
            print("handling the returned thing from Request");
            
            if let JSON = response.result.value {
                
                if (JSON["error"]! != nil) {

                    // need to explicitly end refreshing in this method because setTheMeet() not called in this conditional brach:
                    self.refreshControl?.endRefreshing()
                    
                    // display a UIAlertView with message:
                    let alert = UIAlertController(title: ":(", message: (JSON["error"]! as! String!), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                } else {
                    self.meet = JSON["meet"]
                    print(JSON["meet"])
                    
                    // TODO: setting the following bools w/ values returned from the Server would be much safer. Current code
                    // is making an assumption.
                    print("received meet: \(self.meet!["_id"]! as! String!)")
                    self.isCurrentUserAttendee = true;
                    self.isCurrentUserHost = false;
                    self.setTheMeet()
                }
            }
        }
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        print("handling Refresh!")
        if (self.isJoining) {
            joinMeet()
        } else {
            fetchMeet()
        }
    }
    
    func startRefresh() {
        self.tableView.setContentOffset(CGPointMake(0, self.tableView.contentOffset.y-(self.refreshControl?.frame.size.height)!), animated: true);
        self.refreshControl?.beginRefreshing()
        self.refreshControl?.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        // ---> http://stackoverflow.com/questions/14718850/uirefreshcontrol-beginrefreshing-not-working-when-uitableviewcontroller-is-ins
        startRefresh()

        
        // setting the unwind button text:
        unwindButton.title = from
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let peopleViewController = segue.destinationViewController as? PeopleViewController {
            peopleViewController.meetId = self.meetId!
        }
    }
    
    @IBAction func unwindMeet(sender: UIBarButtonItem) {
        if (from == "All Meets") {
            print("going to All Meets!")
            self.performSegueWithIdentifier("unwindMeets", sender: self)
        } else if (from == "Your Meets"){
            print("going to Your Meets!")
            self.performSegueWithIdentifier("unwindYourMeets", sender: self)
        }
    }
    
    @IBAction func settingsOrJoin(sender: UIBarButtonItem) {
        if !isCurrentUserAttendee {
            // trigger join meet:
            self.isJoining = true;
            
            // now starting the refresh:
            startRefresh()
            
        } else {
            // this is the settings:
            // programmatically trigger: "show" segue to the settings, that has only one direction out:
            // back to this view. It's the Meet Settings!
            // only members / hosts have this option.
            print("Meet Settings")
            self.performSegueWithIdentifier("segueMeetSettings", sender: self)
        }
    }
    
}


















