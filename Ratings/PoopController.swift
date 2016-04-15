//
//  PoopController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 4/12/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit

class PoopController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 20
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            
            print("indexPath == 0, about to set all the labels")

            let cell = tableView.dequeueReusableCellWithIdentifier("MeetViewInfoCell", forIndexPath: indexPath)
            
//            if let titleLabel = cell.viewWithTag(100) as? UILabel {
//                titleLabel.text = "Chai iii1!!!"
//            } else {
//                print("titleLabel is nul :(")
//            }
//            
//            if let hostLabel = cell.viewWithTag(101) as? UILabel {
//                hostLabel.text = "Karthik Uppuluri"
//            }
//            
//            if let timeLabel = cell.viewWithTag(102) as? UILabel {
//                timeLabel.text = "in 2 hours"
//            }
//            
//            if let locationButton = cell.viewWithTag(103) as? UIButton {
//                locationButton.setTitle("123 this is not a street.", forState: UIControlState.Normal)
//            }
            return cell
        } else {
            // this is the Attendee cell:
            
            print("woah attendee cell!")
            let cell = tableView.dequeueReusableCellWithIdentifier("AttendeeCell", forIndexPath: indexPath)
            
            if let nameLabel = cell.viewWithTag(201) as? UILabel {
                nameLabel.text = "Woah!"
            } else {
                print("name label is null?")
            }
            return cell

        }
    }
}
