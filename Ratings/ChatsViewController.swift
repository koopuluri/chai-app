//
//  ChatsViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 2/8/16.
//  Copyright (c) 2016 Poop. All rights reserved.
//

import UIKit

var dummyThreads = [
    ThreadItem(meetTitle: "Post Exam Stress Relief Punching", isSeenByCurrentUser: true, lastMessageAuthor: "Karthik", timestamp: "11:06pm", lastMessageContent: "I don't own any pillows :("),
    
    ThreadItem(meetTitle: "Chai in Student Center", isSeenByCurrentUser: false, lastMessageAuthor: "Vignesh", timestamp: "10:06pm", lastMessageContent: "I forgot the milk."),
    
    ThreadItem(meetTitle: "Ping Pong Tournament at CRC", isSeenByCurrentUser: true, lastMessageAuthor: "Karthik", timestamp: "6:06pm", lastMessageContent: "Why hasn't it started yet?"),
    
    ThreadItem(meetTitle: "Book Reading Club Meeting - Harry Potter", isSeenByCurrentUser: false, lastMessageAuthor: "Amy", timestamp: "4:06pm", lastMessageContent: "Bring your books!"),
]

class ChatsViewController: UITableViewController {
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return dummyThreads.count
    }
    
    @IBAction func unwindChats(segue: UIStoryboardSegue) {}
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ThreadCell", forIndexPath: indexPath)
        
        let thread = dummyThreads[indexPath.row] as ThreadItem
        
        if thread.isSeenByCurrentUser {
        
            if let titleLabel = cell.viewWithTag(100) as? UILabel {
                titleLabel.text = thread.meetTitle
            }
            
            if let timeLabel = cell.viewWithTag(101) as? UILabel {
                timeLabel.text = thread.timestamp
            }
        
            if let lastAuthorLabel = cell.viewWithTag(102) as? UILabel {
                lastAuthorLabel.text = thread.lastMessageAuthor + ":"
            }
        
            if let lastCommentLabel = cell.viewWithTag(103) as? UILabel {
                lastCommentLabel.text = thread.lastMessageContent
            }
            return cell 
        } else {
            
            // if unread --> title is bolder, time color is blue, 
            // lastAuthor color is blue, message color is black:
            if let titleLabel = cell.viewWithTag(100) as? UILabel {
                titleLabel.text = thread.meetTitle
                titleLabel.textColor = UIColor.blackColor()
                titleLabel.font = UIFont.boldSystemFontOfSize(titleLabel.font.pointSize)
            }
            
            if let timeLabel = cell.viewWithTag(101) as? UILabel {
                timeLabel.text = thread.timestamp
                timeLabel.textColor = UIColor.blueColor()
            }
            
            if let lastAuthorLabel = cell.viewWithTag(102) as? UILabel {
                lastAuthorLabel.text = thread.lastMessageAuthor + ":"
                lastAuthorLabel.textColor = UIColor.blueColor()
            }
            
            if let lastCommentLabel = cell.viewWithTag(103) as? UILabel {
                lastCommentLabel.text = thread.lastMessageContent
                lastCommentLabel.textColor = UIColor.blackColor()
                lastCommentLabel.font = UIFont.boldSystemFontOfSize(lastCommentLabel.font.pointSize)
            }
            
            return cell 
        }
    }

}
