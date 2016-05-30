//
//  MeetThreadViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 2/5/16.
//  Copyright (c) 2016 Poop. All rights reserved.
//

import UIKit
import Foundation
import JSQMessagesViewController
import Alamofire

// extends JSQMessagesViewController to provide chat UI. 
class MeetThreadViewController: JSQMessagesViewController{
    
    var start = 0
    var count = 10
    
    var meetId: String?
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.orangeColor())
    
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    
    var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setup()
        self.fetchMessages()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }
    
    func fetchMessages() {
        let url = "https://one-mile.herokuapp.com/meet_chat?meetId=\(self.meetId!)&accessToken=poop"
        
        Alamofire.request(.GET, url) .responseJSON { response in
            
            if let JSON = response.result.value {
                
                if (JSON["error"] != nil) {
                    // handle this!
                }
                
                // should be obtained in decreasing order of timestamp:
                let chatMessages = JSON["meets"] as? NSMutableArray
                
                for message in (chatMessages! as NSArray as! [AnyObject]) {
                    let messageTimeString = message["timestamp"]! as! String!
                    print("messageTimestring: \(messageTimeString)")
                    
                    let messageTime = Util.convertUTCTimestampToDate(messageTimeString)
                    let userId = message["createdBy"]!!["user"]!!["_id"]! as! String!
                    let text = message["message"]! as! String!
                    let username = message["createdBy"]!!["user"]!!["name"]! as! String!

                    // now create a JSQMessage object and append to the messages list:
                    self.messages.append(JSQMessage(senderId: userId, senderDisplayName: username, date: messageTime, text: text))
                }
                
                // reload the messages:
                self.reloadMessagesView()
            }
        }
    }
}



//MARK - Setup
extension MeetThreadViewController {
    
    
    func setup() {
        self.senderId = "0"
        self.senderDisplayName = "Karthik"
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    // username over bubble:
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = self.messages[indexPath.item];
        
        // Sent by me, skip
        if message.senderId == self.senderId {
            return nil;
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.senderId == message.senderId {
                print("ooh, skipping the sender display1")
                return nil;
            }
        }
        
        print("message sender: \(message.senderDisplayName)")
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    // no idea what this is:
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        
        // Sent by me, skip
        if message.senderId == self.senderId {
            return CGFloat(0.0);
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.senderId == message.senderId {
                return CGFloat(0.0);
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        self.messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        switch(data.senderId) {
        case self.senderId:
            return self.outgoingBubble
        default:
            return self.incomingBubble
        }
    }
    
    // display avatar image:
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    func sendMesage(message: String?) {
        print("sending message to the server: \(message)")
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages += [message]
        self.finishSendingMessage()
        
        // making a call to the server:
        self.sendMesage(text)

    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
    }
}






























