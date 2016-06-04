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
    
    var chatThreads: [ChatInfo] = []
    
    let dummyUserId = "56dbb2013cd9a60ed58b1ae3" // currently DUMMY_USER2!
    
    var start = 0
    var count = 10
    
    // MARK: - Table view data source
    
    @IBAction func toMeets(sender: UIBarButtonItem) {
        let poop = self.navigationController?.parentViewController as? MainController
        poop!.programmaticallyMoveToPage(1, direction: UIPageViewControllerNavigationDirection.Reverse)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.chatThreads.count
    }
    
    func startRefresh() {
        self.tableView.setContentOffset(CGPointMake(0, self.tableView.contentOffset.y-(self.refreshControl?.frame.size.height)!), animated: true);
        self.refreshControl?.beginRefreshing()
        self.refreshControl?.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // styling navigation item:
        self.navigationItem.leftBarButtonItem?.tintColor = Util.getMainColor()
        self.navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        startRefresh()
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let meetNavController = segue.destinationViewController as? MeetChatNavController {
            
            if let index = self.tableView.indexPathForSelectedRow?.row {
                let meetId = chatThreads[index].meetId
                let meetController = meetNavController.viewControllers.first as! MeetChatPageViewController
                meetController.meetId = meetId
                meetController.from = "Chats"
                meetController.mode = "Chat"
                print("meetController meet set coming from MeetsController.prototypeCell")
            }
        }
    }
    
    func _setChatInfo(infos: [ChatInfo]) {
        self.chatThreads = infos
        
        // reload:
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }

    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // get current location to use for the query:
        // TODO: currently using dummy:
        
        // Pulling meets from the server:
        API.getUserChats(start, count: count, callback: _setChatInfo)
    }
    
    @IBAction func unwindChats(segue: UIStoryboardSegue) {}
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ThreadCell", forIndexPath: indexPath)
        
        let chatInfo = self.chatThreads[indexPath.row]

        if  chatInfo.isSeen {
        
            if let titleLabel = cell.viewWithTag(100) as? UILabel {
                titleLabel.text = chatInfo.meetTitle
            }
            
            if let timeLabel = cell.viewWithTag(101) as? UILabel {
                timeLabel.text = Util.getChatTimestamp(chatInfo.lastMessageTime)
            }
        
            if let lastCommentLabel = cell.viewWithTag(103) as? UILabel {
                lastCommentLabel.text = chatInfo.authorName + ": " + chatInfo.lastMessageContent
                lastCommentLabel.textColor = UIColor.blackColor()
            }
            
            return cell
        } else {
            
            // if unread --> title is bolder, time color is blue, 
            // lastAuthor color is blue, message color is black:
            if let titleLabel = cell.viewWithTag(100) as? UILabel {
                titleLabel.text = chatInfo.meetTitle
                titleLabel.textColor = UIColor.blackColor()
                titleLabel.font = UIFont.boldSystemFontOfSize(titleLabel.font.pointSize)
            }
            
            if let timeLabel = cell.viewWithTag(101) as? UILabel {
                timeLabel.text = Util.getChatTimestamp(chatInfo.lastMessageTime)
                timeLabel.textColor = UIColor.orangeColor()
            }
            
            
            if let lastCommentLabel = cell.viewWithTag(103) as? UILabel {
                lastCommentLabel.text = chatInfo.authorName + ": " + chatInfo.lastMessageContent
                lastCommentLabel.textColor = UIColor.blackColor()
            }
            
            return cell 
        }
    }

}




























