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

// extends JSQMessagesViewController to provide chat UI. 
class MeetThreadViewController: JSQMessagesViewController{
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.orangeColor())
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setup()
        self.addDemoMessages()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }
}

//MARK - Setup
extension MeetThreadViewController {
    func addDemoMessages() {
        
        // adding some dummy messages:
        self.messages = [
            JSQMessage(senderId: "0", senderDisplayName: "Woah", date: NSDate(), text: "Hey! Looking forward to the meet!"),
            JSQMessage(senderId: "1", senderDisplayName: "Abc", date: NSDate(), text: "Hey you!"),
            JSQMessage(senderId: "2", senderDisplayName: "Albert Einstein", date: NSDate(), text: "How fast is hey?"),
            JSQMessage(senderId: "3", senderDisplayName: "Ash Ketchum", date: NSDate(), text: "Hey! I choose you"),
            JSQMessage(senderId: "4", senderDisplayName: "Abe Lincoln", date: NSDate(), text: "Can't wait to punch pillows."),
            JSQMessage(senderId: "4", senderDisplayName: "Abe Lincoln", date: NSDate(), text: "What's up?"),
            JSQMessage(senderId: "5", senderDisplayName: "Mahatma Gandhi", date: NSDate(), text: "I don't believe in punching anything."),
            JSQMessage(senderId: "6", senderDisplayName: "Nicola Tesla", date: NSDate(), text: "... facepalm..."),
            JSQMessage(senderId: "7", senderDisplayName: "Karthik", date: NSDate(), text: "I don't own any pillows :(")
        ]
        
        // reloading to display the new messages:
        self.reloadMessagesView()
    }
    
    func setup() {
        self.senderId = "0"
        self.senderDisplayName = "Karthik"
//        self.senderId = UIDevice.currentDevice().identifierForVendor?.UUIDString
//        self.senderDisplayName = UIDevice.currentDevice().identifierForVendor?.UUIDString
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
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages += [message]
        self.finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
    }
}






























