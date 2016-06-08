//
//  MeetSettingsModalViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 6/5/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit
import SwiftyButton

class MeetSettingsModalViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var meetId: String?
    var isHost: Bool?
    var isMeetCancelled: Bool?
    
    @IBOutlet weak var exitOrCancelButton: SwiftyButton!
    @IBOutlet weak var notifSwitch: UISwitch!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var exitSpinner: UIActivityIndicatorView!
    
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        print("gestureRecognized")
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clearColor()
        view.opaque = false
        
        exitOrCancelButton.shadowHeight = 0
        exitOrCancelButton.cornerRadius = 5
        exitOrCancelButton.highlightedColor = UIColor.whiteColor()
        
        let buttonTitle = self.isHost! ? "Cancel Meet" : "Exit Meet"
        exitOrCancelButton.setTitle(buttonTitle, forState: UIControlState.Normal)
        
        exitSpinner.tintColor = Util.getMainColor()
        exitSpinner.hidesWhenStopped = true
        
        containerView.layer.cornerRadius = 5
        
        API.getMeetIsNotifications(self.meetId!, callback: self.onNotifReturn)
        
        // don't display the cancel button for a host if the meet is already canceled.
        if (self.isHost! && self.isMeetCancelled!) {
            self.exitOrCancelButton.hidden = true
        }
        
        // recognizer to handle the exit tap:
        let exitTap = UITapGestureRecognizer(target: self, action: Selector("dismiss"))
        exitTap.delegate = self
        view.addGestureRecognizer(exitTap)
        
        // handler to toggle notifications:
        notifSwitch.addTarget(self, action: "notifToggle", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func notifToggle() {
        let isNotif = self.notifSwitch.on
        API.setMeetNotifications(self.meetId!, isNotif: isNotif)
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onNotifReturn(isNotif: Bool) {
        self.notifSwitch.setOn(isNotif, animated: true)
    }
    
    // refresh the parent MeetController on dismissal:
    func onDismissal() {
        print("MeetSettingsModal dismissed!")
    }
    
    func onExitOrCancel(success: Bool) {
        // transition to the MainController (dismiss the parent's parent's navigation controller:
        self.dismissViewControllerAnimated(true, completion: onDismissal)
    }

    @IBAction func exitOrCancel(sender: SwiftyButton) {
        exitOrCancelButton.hidden = true
        exitSpinner.startAnimating()
        
        if (isHost!) {
            // cancel:
            API.cancelMeet(self.meetId!, callback: self.onExitOrCancel)
        } else {
            // exit:
            API.exitMeet(self.meetId!, callback: self.onExitOrCancel)
        }
    }
}