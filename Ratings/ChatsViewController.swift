//
//  ChatsViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 2/8/16.
//  Copyright (c) 2016 Poop. All rights reserved.
//

import UIKit
import Alamofire

class ChatsViewController: UITableViewController {
    
    var chatThreads: NSMutableArray?
    
    let dummyUserId = "56dbb2013cd9a60ed58b1ae3" // currently DUMMY_USER2!
    
    var start = 0
    var count = 10
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if self.chatThreads != nil {
            return self.chatThreads!.count
        } else {
            return 0
        }
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
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let meetNavController = segue.destinationViewController as? MeetChatNavController {
            
            if let index = self.tableView.indexPathForSelectedRow?.row {
                let meetId = chatThreads![index]["meet"]!!["_id"]! as! String!  // getting the meetId for the selected meet.
                let meetController = meetNavController.viewControllers.first as! MeetChatPageViewController
                meetController.meetId = meetId
                meetController.from = "Chats"
                meetController.mode = "Chat"
                print("meetController meet set coming from MeetsController.prototypeCell")
            }
        }
    }

    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // get current location to use for the query:
        // TODO: currently using dummy:
        
        // Pulling meets from the server:
        let url = "https://one-mile.herokuapp.com/user_chats?userId=\(self.dummyUserId)&start=\(start)&count=\(count)"
        
        Alamofire.request(.GET, url) .responseJSON { response in
            
            if let JSON = response.result.value {
                if (JSON["error"]! != nil) {
                    
                    // display a UIAlertView with message:
                    let alert = UIAlertController(title: ":(", message: (JSON["error"]! as! String!), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    return
                }
                
                // All clear:
                self.chatThreads = JSON["results"]! as? NSMutableArray
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }

    
    @IBAction func unwindChats(segue: UIStoryboardSegue) {}
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ThreadCell", forIndexPath: indexPath)
        
        let thread = self.chatThreads![indexPath.row]

        // getting the times for when the chat was opened and the last chat message: compared to see if user has seen the last
        // message or not:
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let lastChatTime = dateFormatter.dateFromString(thread["meet"]!!["lastChatMessage"]!!["timestamp"]! as! String!)
        let lastOpenedTime = dateFormatter.dateFromString(thread["lastOpenedChat"]! as! String!)
        let isSeen = lastChatTime!.compare(lastOpenedTime!) == NSComparisonResult.OrderedAscending
        
        let title = thread["meet"]!!["title"]! as! String!
        //let authorFirstName = thread["meet"]!!["lastChatMessage"]!!["author"]!!["firstName"]! as! String!
        let authorFirstName = "gottaFix"
        let content = thread["meet"]!!["lastChatMessage"]!!["content"]! as! String!
        
        if  isSeen{
        
            if let titleLabel = cell.viewWithTag(100) as? UILabel {
                titleLabel.text = title
            }
            
            if let timeLabel = cell.viewWithTag(101) as? UILabel {
                timeLabel.text = String(lastChatTime!)
            }
        
            if let lastAuthorLabel = cell.viewWithTag(102) as? UILabel {
                lastAuthorLabel.text = authorFirstName + ":"
            }
        
            if let lastCommentLabel = cell.viewWithTag(103) as? UILabel {
                lastCommentLabel.text = content
            }
            return cell 
        } else {
            
            // if unread --> title is bolder, time color is blue, 
            // lastAuthor color is blue, message color is black:
            if let titleLabel = cell.viewWithTag(100) as? UILabel {
                titleLabel.text = title
                titleLabel.textColor = UIColor.blackColor()
                titleLabel.font = UIFont.boldSystemFontOfSize(titleLabel.font.pointSize)
            }
            
            if let timeLabel = cell.viewWithTag(101) as? UILabel {
                timeLabel.text = String(lastChatTime!)
                timeLabel.textColor = UIColor.blueColor()
            }
            
            if let lastAuthorLabel = cell.viewWithTag(102) as? UILabel {
                lastAuthorLabel.text = authorFirstName + ":"
                lastAuthorLabel.textColor = UIColor.blueColor()
            }
            
            if let lastCommentLabel = cell.viewWithTag(103) as? UILabel {
                lastCommentLabel.text = content
                lastCommentLabel.textColor = UIColor.blackColor()
                lastCommentLabel.font = UIFont.boldSystemFontOfSize(lastCommentLabel.font.pointSize)
            }
            
            return cell 
        }
    }

}
