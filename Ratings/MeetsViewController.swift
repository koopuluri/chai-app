//
//  MeetsViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 1/27/16.
//  Copyright (c) 2016 Poop. All rights reserved.
//

import UIKit
import Alamofire

import FBSDKLoginKit
import FBSDKCoreKit


class MeetsViewController: UITableViewController {

    // to have access to parent pageViewController for page shift on button press
    var parentPageViewController: MainController?
    
    var meets: NSMutableArray?
    var start = 0
    var count = 10
    
    @IBAction func chat(sender: UIBarButtonItem) {
        let poop = self.navigationController?.parentViewController as? MainController
        poop!.programmaticallyMoveToPage(2, direction: UIPageViewControllerNavigationDirection.Forward)
    }
    
    @IBAction func settings(sender: UIBarButtonItem) {
        let poop = self.navigationController?.parentViewController as? MainController
        poop!.programmaticallyMoveToPage(0, direction: UIPageViewControllerNavigationDirection.Reverse)
    }
    
    func startRefresh() {
        self.tableView.setContentOffset(CGPointMake(0, self.tableView.contentOffset.y-(self.refreshControl?.frame.size.height)!), animated: true);
        self.refreshControl?.beginRefreshing()
        self.refreshControl?.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MEETS VIEW CONTROLLER")
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        startRefresh()
        
        self.navigationController!.navigationBar.barTintColor = UIColor.orangeColor()
    }
    
    // ==========================================================================
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.hidden = false
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // get current location to use for the query:
        // TODO: currently using dummy:
        var currentLocation = [0.0, 0.0]
        
        // Pulling meets from the server:
        let url = "https://one-mile.herokuapp.com/meets_by_location?long=\(currentLocation[0])&lat=\(currentLocation[1])&start=\(start)&count=\(count)&accessToken=poop"
        
        print("reloadMeetsFromServer: \(url)")
        
        Alamofire.request(.GET, url) .responseJSON { response in
            
            if let JSON = response.result.value {
                self.meets = JSON["meets"] as? NSMutableArray
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    @IBAction func unwindMeets(segue: UIStoryboardSegue) {}
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let meetChatNavController = segue.destinationViewController as? MeetChatNavController {
            
            if let index = self.tableView.indexPathForSelectedRow?.row {
                let meetId = meets![index]["_id"]! as! String!  // getting the meetId for the selected meet.
                let meetChatController = meetChatNavController.viewControllers.first as! MeetChatPageViewController
                
                print("seguing to meetChatController: \(meetId)")
                meetChatController.meetId = meetId
                meetChatController.from = "Meets"
                meetChatController.mode = "Meet"
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
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Upcoming"
        } else {
            return "All"
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if (section == 0) {
            return 1
        } else {
            // this is for the "all" section:
            if self.meets == nil {
                return 0
            } else {
                return self.meets!.count
            }
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("UpcomingCell") as! UpcomingCell
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MeetCell", forIndexPath: indexPath)
    
        let meet = meets![indexPath.row]
        
        if let titleLabel = cell.viewWithTag(100) as? UILabel {
            titleLabel.text = (meet["title"]! as! String!)
        }
        
        if let hostLabel = cell.viewWithTag(101) as? UILabel {
            //hostLabel.text = (meet["createdBy"]!!["firstName"]! as! String!)
            hostLabel.text = "by: Karthik Uppuluri"
        }
        
        if let timeLabel = cell.viewWithTag(102) as? UILabel {
            
            // converting the default time to: "today at 4:30pm" / "tomorrow at 3pm" format.
            let diceRoll = Int(arc4random_uniform(6) + 1)
            if (diceRoll <= 3) {
                //timeLabel.text = (meet["startTime"]! as! String!)
                timeLabel.text = "4pm today"
            } else {
                timeLabel.text = "3:30pm tomorrow"
            }
        }
        
        if let avatarImage = cell.viewWithTag(104) as? UIImageView {
            let picUrl = "https://scontent.xx.fbcdn.net/hprofile-xpf1/v/t1.0-1/p50x50/12509882_565775596928323_668499748259808876_n.jpg?oh=4733ef1dc8bc40849533f84e82e8a5a3&oe=57BA0EA0"
            
            let url = NSURL(string: picUrl)
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
                dispatch_async(dispatch_get_main_queue(), {
                    avatarImage.image = UIImage(data: data!)
                    avatarImage.layer.borderWidth = 0.5
                    avatarImage.layer.masksToBounds = false
                    avatarImage.layer.borderColor = UIColor.lightGrayColor().CGColor
                    avatarImage.layer.cornerRadius = avatarImage.frame.height/2
                    avatarImage.clipsToBounds = true
                });
            }
        }
        
        if let countLabel = cell.viewWithTag(103) as? UILabel {
            let count = (meet["count"]! as! Int!)
            
            countLabel.text = String(count) + "/3"
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
