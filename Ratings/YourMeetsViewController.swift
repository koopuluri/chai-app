//
//  YourMeetsViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 2/23/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit

var upcomingMeets = [
    Meetup(
        title: "Research Sharing over Coffee",
        time: "tomorrow at 5pm",
        count: 2,
        description: "Hey! I do research in physics, and am presenting a topic at a conference over the weekend. I'd love to run by my thoughts and get some feedback. You don't have to be versed in physics - in fact, I'd prefer it if you weren't. I'm open to hearing about anything you're doing as well, and will give you honest feedback. Coffee's on me! I'll also be bringing popcorn; let me know if you'll be bringing anything as well. See you there!",
        hostName: "Richard Feynman",
        maxCount: 3,
        locationX: 0.0,
        locationY: 0.0),
    
    Meetup(
        title: "Post Exam Stress Relief Punching",
        time: "tomorrow at 5pm",
        count: 15,
        description: "I bombed a test. I want to punch things. I'm taking my pillow out to Tech Lawn and punch it for as long as I can. I'd love to hear about your shitty test taking as well. Knowing others messed up makes me feel better... is that weird? Bring your pillow!",
        hostName: "Richard Feynman",
        maxCount: 20,
        locationX: 0.0,
        locationY: 0.0)
]


var previousMeets = [
    Meetup(
        title: "Starcraft Practice",
        time: "in 8 hours",
        count: 15,
        description: "Getting together to practice before the next nationwide tournament. All skill levels welcome! BYOFood.",
        hostName: "Jon Woo",
        maxCount: 100,
        locationX: 0.0,
        locationY: 0.0),

    Meetup(
    title: "Long Distance Running Partner",
    time: "tomorrow at 7am",
    count: 2,
    description: "Ping pong tournament at the CRC. $5 entry fee.",
    hostName: "Amy Chen",
    maxCount: 100,
    locationX: 0.0,
    locationY: 0.0),

    Meetup(
    title: "Help Make the Largest Cupcake",
    time: "tomorrow at 9am",
    count: 2,
    description: "Ping pong tournament at the CRC. $5 entry fee.",
    hostName: "Ken Pen",
    maxCount: 100,
    locationX: 0.0,
    locationY: 0.0),

    Meetup(
    title: "Settlers of Catan Game",
    time: "tomorrow at 3pm",
    count: 5,
    description: "Ping pong tournament at the CRC. $5 entry fee.",
    hostName: "Goldilocks Goldi",
    maxCount: 100,
    locationX: 0.0,
    locationY: 0.0),
]

class YourMeetsViewController: UITableViewController {
    
    let data = [upcomingMeets, previousMeets]
    let headerTitles = ["Upcoming", "Previous"]
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("YourMeetCell", forIndexPath: indexPath)
        let meet = data[indexPath.section][indexPath.row]
    
        
        
        if (indexPath.section == 0) {
            if let titleLabel = cell.viewWithTag(100) as? UILabel {
                titleLabel.text = meet.title
                titleLabel.textColor = UIColor.blackColor()
            }
            
            if let hostLabel = cell.viewWithTag(101) as? UILabel {
                hostLabel.text = meet.hostName
            }
            
            if let timeLabel = cell.viewWithTag(102) as? UILabel {
                timeLabel.text = meet.time
                timeLabel.textColor = UIColor.blueColor()
                
            }
            
            if let countLabel = cell.viewWithTag(103) as? UILabel {
                countLabel.text = String(meet.count)
                countLabel.textColor = UIColor.blueColor()
            }
            
        } else {
            if let titleLabel = cell.viewWithTag(100) as? UILabel {
                titleLabel.text = meet.title
            }
            
            if let hostLabel = cell.viewWithTag(101) as? UILabel {
                hostLabel.text = meet.hostName
            }
            
            if let timeLabel = cell.viewWithTag(102) as? UILabel {
                timeLabel.text = meet.time
            }
            
            if let countLabel = cell.viewWithTag(103) as? UILabel {
                countLabel.text = String(meet.count)
            }
        }
        
        return cell
        
        //  Now do whatever you were going to do with the title.
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < headerTitles.count {
            return headerTitles[section]
        }
        
        return nil
    }
    
    @IBAction func unwindYourMeets(segue: UIStoryboardSegue) {}
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let meetNavController = segue.destinationViewController as? MeetNavigationController {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let meet = data[indexPath.section][indexPath.row]
                
                // setting the newMEet var for MeetViewController (the first view controller in the MeetNav stack:
                let meetController = meetNavController.viewControllers.first as! MeetController
                meetController.meet = meet
                meetController.isCurrentUserAttendee = true
                meetController.from = "Your Meets"
                print("meetController meet set coming from MeetsController.prototypeCell")
            }
        }
    }

}
