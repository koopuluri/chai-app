//
//  MeetsViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 1/27/16.
//  Copyright (c) 2016 Poop. All rights reserved.
//

import UIKit



let meetsData = [
    Meetup(
        title: "Slacklining on Skiiles",
        time: "in 30 mins",
        count: 15,
        description: "Slacklining is fun!",
        hostName: "Stew Pickle",
        maxCount: 100,
        locationX: 0.0,
        locationY: 0.0),
    
    Meetup(
        title: "Chai in Student Center",
        time: "in 1 hour",
        count: 30,
        description: "Making a some chai, will be fun! In room 301. Bring snacks if you'd like!",
        hostName: "Dan Man",
        maxCount: 100,
        locationX: 0.0,
        locationY: 0.0),
    
    Meetup(
        title: "Ping Pong",
        time: "in 3 hours",
        count: 2,
        description: "Ping pong tournament at the CRC. $5 entry fee.",
        hostName: "Kevin Cho",
        maxCount: 100,
        locationX: 0.0,
        locationY: 0.0),
    
    Meetup(
        title: "Mini Hackathon",
        time: "in 5 hours",
        count: 64,
        description: "We're having a 7 hour mini-hackathon at the Amelie's coffee shop. Food provided! Stay tuned the thread for announcements about food!",
        hostName: "Ash Ketchum",
        maxCount: 200,
        locationX: 0.0,
        locationY: 0.0),

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
        locationY: 0.0),

]

class MeetsViewController: UITableViewController {
    
    var meets:[Meetup] = meetsData

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

    }
    
    @IBAction func unwindMeets(segue: UIStoryboardSegue) {}
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let meetNavController = segue.destinationViewController as? MeetNavigationController {
            
            if let index = self.tableView.indexPathForSelectedRow?.row {
                let meet = meetsData[index]
                
                // setting the newMEet var for MeetViewController (the first view controller in the MeetNav stack:
                let meetController = meetNavController.viewControllers.first as! MeetController
                meetController.meet = meet
                meetController.from = "All Meets"
                print("meetController meet set coming from MeetsController.prototypeCell")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return meets.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MeetCell", forIndexPath: indexPath)
        
        let meet = meets[indexPath.row] as Meetup
        
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
        
        return cell 
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
