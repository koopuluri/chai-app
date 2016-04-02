//
//  MeetsViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 1/27/16.
//  Copyright (c) 2016 Poop. All rights reserved.
//

import UIKit
import Alamofire



class MeetsViewController: UITableViewController {
    
    var meets: NSMutableArray?
    var start = 0
    var count = 10
    
 
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

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.hidden = false
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // get current location to use for the query:
        // TODO: currently using dummy:
        var currentLocation = [0.0, 0.0]

        // Pulling meets from the server:
        let url = "https://one-mile.herokuapp.com/meets_by_location?long=\(currentLocation[0])&lat=\(currentLocation[1])&start=\(start)&count=\(count)"
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
        if let meetNavController = segue.destinationViewController as? MeetNavigationController {
            
            if let index = self.tableView.indexPathForSelectedRow?.row {
                let meetId = meets![index]["_id"]! as! String!  // getting the meetId for the selected meet.
                let meetController = meetNavController.viewControllers.first as! MeetController
                meetController.meetId = meetId
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
        if self.meets == nil {
            return 0
        } else {
            return self.meets!.count
        }
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MeetCell", forIndexPath: indexPath)
    
        let meet = meets![indexPath.row]
        
        if let titleLabel = cell.viewWithTag(100) as? UILabel {
            titleLabel.text = (meet["title"]! as! String!)
        }
        
        if let hostLabel = cell.viewWithTag(101) as? UILabel {
            hostLabel.text = (meet["createdBy"]!!["firstName"]! as! String!)
        }
        
        if let timeLabel = cell.viewWithTag(102) as? UILabel {
            timeLabel.text = (meet["startTime"]! as! String!)
        }
        
        if let countLabel = cell.viewWithTag(103) as? UILabel {
            let count = (meet["count"]! as! Int!)
            
            countLabel.text = String(count)
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
