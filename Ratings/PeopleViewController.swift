//
//  PeopleViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 2/10/16.
//  Copyright (c) 2016 Poop. All rights reserved.
//

import UIKit
import Alamofire

class PeopleViewController: UITableViewController {
    
    var attendees: NSMutableArray?
    var meetId: String?
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        startRefresh()
    }

    
    func startRefresh() {
        self.tableView.setContentOffset(CGPointMake(0, self.tableView.contentOffset.y-(self.refreshControl?.frame.size.height)!), animated: true);
        self.refreshControl?.beginRefreshing()
        self.refreshControl?.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        
        // Pulling attendees from the server:
        let url = "https://one-mile.herokuapp.com/meet_attendees?id=\(self.meetId!)"
        print("fetching attendees: \(url)")
        
        Alamofire.request(.GET, url) .responseJSON { response in
            
            if let JSON = response.result.value {
                
                if (JSON["error"]! != nil) {
                    
                    self.refreshControl?.endRefreshing()
                    
                    // display a UIAlertView with message:
                    let alert = UIAlertController(title: ":(", message: (JSON["error"]! as! String!), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                } else {
                    self.attendees = JSON["attendees"] as? NSMutableArray
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
 
        if let personViewController = segue.destinationViewController as? PersonViewController {
            
            if let index = self.tableView.indexPathForSelectedRow?.row {
                let userId = attendees![index]["user"]!!["_id"]! as! String!
                
                // setting the newMEet var for MeetViewController (the first view controller in the MeetNav stack:
                personViewController.userId = userId
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.attendees == nil {
            return 0
        }
        return self.attendees!.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PersonCell", forIndexPath: indexPath)
        
        let user = attendees![indexPath.row]["user"]!
        let firstName = user!["firstName"]! as! String!
        let lastName = user!["lastName"]! as! String!
        
        if let initialLabel = cell.viewWithTag(100) as? UILabel {
            
            print("firstName: \(firstName)")
            print("lastName: \(lastName)")
            initialLabel.text = "\(Array(firstName.characters)[0])\(Array(lastName.characters)[0])"
            
            // setting the color of the initials:
            let rgbValue = firstName.hash
            let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
            let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
            let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
            let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
            
            initialLabel.textColor = color

        }
        
        if let nameLabel = cell.viewWithTag(101) as? UILabel {
            nameLabel.text = firstName + " " + lastName
        }

        return cell 
    }

}
