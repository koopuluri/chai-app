//
//  YourMeetsViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 2/23/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit
import Alamofire


class YourMeetsViewController: UITableViewController {
    
    let dummyUserId = "56dbb2013cd9a60ed58b1ae3" // currently DUMMY_USER2!
    
    var upcomingMeets: NSMutableArray = []
    var previousMeets: NSMutableArray = []
    
    var data: [NSMutableArray] = []
    
    var start = 0
    var count = 10
    
    let headerTitles = ["Upcoming", "Previous"]
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func startRefresh() {
        self.tableView.setContentOffset(CGPointMake(0, self.tableView.contentOffset.y-(self.refreshControl?.frame.size.height)!), animated: true);
        self.refreshControl?.beginRefreshing()
        self.refreshControl?.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        startRefresh()
    }

    func handleRefresh(refreshControl: UIRefreshControl) {
        // get current location to use for the query:
        // TODO: currently using dummy:
        
        // Pulling meets from the server:
        let url = "https://one-mile.herokuapp.com/user_meets?userId=\(self.dummyUserId)&start=\(start)&count=\(count)"
        print("yourMeets.url: \(url)")
        
        Alamofire.request(.GET, url) .responseJSON { response in
            
            if let JSON = response.result.value {
                let meets = JSON["meets"] as? NSMutableArray
                let currentTime = NSDate()
                
                if (JSON["error"]! != nil) {
                    
                    // display a UIAlertView with message:
                    let alert = UIAlertController(title: ":(", message: (JSON["error"]! as! String!), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    return
                }
                
                // Slightly inefficient, optimize later...
                if self.previousMeets.count == 0 {
                    for meet in meets! {
                        
                        // getting current time:
                        let startTimeString = meet["startTime"]! as! String!
                        
                        print("startTimeString: \(startTimeString)")
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                        let startTime = dateFormatter.dateFromString(startTimeString)
                        
                        if startTime!.compare(currentTime) ==  NSComparisonResult.OrderedDescending {
                            self.upcomingMeets.addObject(meet)
                        } else {
                            self.previousMeets.addObject(meet)
                        }
                    }
                } else {
                    // all fetched meets are previous meets:
                    self.previousMeets.addObjectsFromArray(meets! as [AnyObject])
                }
                
                self.data.append(self.upcomingMeets)
                self.data.append(self.previousMeets)
                
                // reload data, and end refreshing:
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data.count > 0 {
            return data[section].count
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("YourMeetCell", forIndexPath: indexPath)
        let meet = data[indexPath.section][indexPath.row]
    
        // if current user is host of meet, special background color:
        if (meet["isHost"]! as! Bool) {
            cell.backgroundColor = UIColor.lightGrayColor()
        }
        
        if let titleLabel = cell.viewWithTag(100) as? UILabel {
            titleLabel.text = meet["meet"]!!["title"]! as! String!
            titleLabel.textColor = UIColor.blackColor()
        }
        
        if let hostLabel = cell.viewWithTag(101) as? UILabel {
            hostLabel.text = (meet["meetHost"]!!["firstName"]! as! String!) + (meet["meetHost"]!!["lastName"]! as! String!)
        }
        
        if let timeLabel = cell.viewWithTag(102) as? UILabel {
            timeLabel.text = meet["startTime"] as! String!
            if (indexPath.section == 0) {
                timeLabel.textColor = UIColor.blueColor()
            }
        }
        
        if let countLabel = cell.viewWithTag(103) as? UILabel {
            countLabel.text = String(meet["meet"]!!["count"]! as! Int!)
            if (indexPath.section == 0) {
                countLabel.textColor = UIColor.blueColor()
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
                meetController.meetId = meet["meet"]!!["_id"]! as! String!
                meetController.isCurrentUserAttendee = true
                meetController.from = "Your Meets"
                print("meetController meet set coming from MeetsController.prototypeCell")
            }
        }
    }

}
