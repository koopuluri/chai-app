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
    
    let dummyUserId = "56dbb2013cd9a60ed58b1ae2"

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
            if isCurrentUserAttendee {
                self.joinSettingsButton.title = "settings"
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
                self.meet = JSON["meet"]
                self.isCurrentUserAttendee = (JSON["isAttending"]! as! Bool!)
                self.isCurrentUserHost = (JSON["isHost"]! as! Bool!)
                self.setTheMeet()
            }
        }
    }
    
    func joinMeet() {
        print("joining meet!")
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        print("handling Refresh!")
        fetchMeet()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        // ---> http://stackoverflow.com/questions/14718850/uirefreshcontrol-beginrefreshing-not-working-when-uitableviewcontroller-is-ins
        
        self.tableView.setContentOffset(CGPointMake(0, self.tableView.contentOffset.y-(self.refreshControl?.frame.size.height)!), animated: true);
        self.refreshControl?.beginRefreshing()
        self.refreshControl?.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        
        // setting the unwind button text:
        unwindButton.title = from
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
            // stay in this view; send request to server,
            // and render a UIAlertView when it comes back
            // notifiying user that they've succesfully joined / failed.
            // and then refresh the view --> will now have member display.
//            isCurrentUserAttendee = true // HACK for UI DEmo!
//            self.joinSettingsButton.title = "settings"
//            self.threadToolbar.hidden = false
            
            // temporary UI changes to reflect update in meet count:
            joinMeet()
            
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


















