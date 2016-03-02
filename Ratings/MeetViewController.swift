//
//  MeetViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 2/3/16.
//  Copyright (c) 2016 Poop. All rights reserved.
//

import UIKit
import MapKit

class MeetViewController: UIViewController {

    
    // set if transitioned from creating a new meet. This is a bad way to do this. Check out what good 
    // practice is --> probably some identifier stuff in the seguing.
    
    var newMeet: Meetup!
    
    var meet: Meetup!
    
    var isCurrentUserMember: Bool = false;
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hostLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var meetThreadToolbar: UIToolbar!
    
    @IBOutlet weak var settingsOrJoinButton: UIBarButtonItem!
    
    @IBOutlet weak var locationMapView: MKMapView!
    
    @IBOutlet weak var numberAttendingLabel: UILabel!
    
    @IBOutlet weak var meetMaxCountLabel: UILabel!
    
    // when settings / join is clicked:
    @IBAction func settingsOrJoin(sender: UIBarButtonItem) {
        if !isCurrentUserMember {
            // stay in this view; send request to server, 
            // and render a UIAlertView when it comes back 
            // notifiying user that they've succesfully joined / failed.
            // and then refresh the view --> will now have member display.
            isCurrentUserMember = true // HACK for UI DEmo!
            self.settingsOrJoinButton.title = "settings"
            print("Meet join")
        } else {
            // this is the settings:
            // programmatically trigger: "show" segue to the settings, that has only one direction out:
            // back to this view. It's the Meet Settings!
            // only members / hosts have this option.
            print("Meet Settings")

             self.performSegueWithIdentifier("MeetSettingsSegue", sender: self)
        }
    }
  
    @IBAction func backToMeets(sender: UIBarButtonItem) {
        print("going back!!")
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil);
    }
    
    
    func setMeet(meet: Meetup) {
        self.titleLabel.text = meet.title
        self.descriptionLabel.text = meet.description
        
        print("MeetView setting the description: \(meet.description)")
        
        self.timeLabel.text = "today 5pm"
        self.hostLabel.text = meet.hostName
        self.numberAttendingLabel.text = "3"
        self.meetMaxCountLabel.text = String(meet.maxCount)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        if isCurrentUserMember {
            setMeet(self.newMeet)
            self.settingsOrJoinButton.title = "settings"
        } else {
            setMeet(self.meet)
            self.settingsOrJoinButton.title = "join"
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}