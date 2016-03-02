//
//  MeetController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 2/18/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit
import MapKit

class MeetController: UITableViewController {
    
    var meet: Meetup?
    var from: String?
    
    var isCurrentUserMember = false
    

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var unwindButton: UIBarButtonItem!
    
    @IBOutlet weak var hostLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var threadToolbar: UIToolbar!
    
    @IBOutlet weak var locationView: MKMapView!
    
    @IBOutlet weak var joinSettingsButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMeet(self.meet!)
        
        // setting the join button text:
        if isCurrentUserMember {
            self.joinSettingsButton.title = "settings"
        } else {
            self.joinSettingsButton.title = "join"
            threadToolbar.hidden = true
        }
        
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
        if !isCurrentUserMember {
            // stay in this view; send request to server,
            // and render a UIAlertView when it comes back
            // notifiying user that they've succesfully joined / failed.
            // and then refresh the view --> will now have member display.
            isCurrentUserMember = true // HACK for UI DEmo!
            self.joinSettingsButton.title = "settings"
            self.threadToolbar.hidden = false
            
            // temporary UI changes to reflect update in meet count:
            meet!.count = meet!.count + 1
            self.numberLabel.text = String(meet!.count) + "/" + String(meet!.maxCount)
            self.numberLabel.textColor = UIColor.greenColor()
            
            print("Meet join")
        } else {
            // this is the settings:
            // programmatically trigger: "show" segue to the settings, that has only one direction out:
            // back to this view. It's the Meet Settings!
            // only members / hosts have this option.
            print("Meet Settings")
            self.performSegueWithIdentifier("segueMeetSettings", sender: self)
        }
    }
    
    func setMeet(meet: Meetup) {
        self.titleLabel.text = meet.title
        self.descriptionLabel.text = meet.description
        
        print("MeetView setting the description: \(meet.description)")
        
        self.timeLabel.text = meet.time
        self.hostLabel.text = meet.hostName
        self.numberLabel.text = String(meet.count) + "/" + String(meet.maxCount)
    }
    
}


















