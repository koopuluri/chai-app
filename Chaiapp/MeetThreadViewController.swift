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
import SocketIOClientSwift
import FBSDKLoginKit

// extends JSQMessagesViewController to provide chat UI. 
class MeetThreadViewController: JSQMessagesViewController{
    
    var start = 0
    var count = 10
    
    //var socket = SocketIOClient(socketURL: NSURL(fileURLWithPath: "https://one-mile.herokuapp.com"))
    var socket: SocketIOClient?
    
    var meetId: String?
    
    //let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.orangeColor())
    let incomingBubble = JSQMessagesBubbleImageFactory(bubbleImage: UIImage.jsq_bubbleCompactTaillessImage(), capInsets: UIEdgeInsetsZero).incomingMessagesBubbleImageWithColor(Util.getMainColor())

    
    let outgoingBubble = JSQMessagesBubbleImageFactory(bubbleImage: UIImage.jsq_bubbleCompactTaillessImage(), capInsets: UIEdgeInsetsZero).outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    
    var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setup()
        self.fetchMessages()
        
        // check if user is member:
        API.amIAttendee(self.meetId!, callback: ifNotMember)
    }
    
    func ifNotMember(amMember: Bool) {
        // exit back to the MAinController if not member:
        if (!amMember) {
            self.parentViewController?.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
        
    override func viewDidDisappear(animated: Bool) {
        // tell server that chat opened:
        API.openedChat(self.meetId!)
    }
    
    // handles socket.io message received for chat: renders if new message is not authored by current user.
    func handleSocketMessage(message: AnyObject) {
        let isBot = message["isBot"]! as! Bool!
        if (!isBot) {
            let userId = message["author"]!!["_id"]! as! String!
            if (userId == self.senderId) {
                print("userId == senderId: \(userId) vs. \(self.senderId)")
                // don't add.
            } else {
                // add to the messages:
                self.messages.append(getJSQMessageForChatMessage(message))
                self.reloadChatView()
            }
        } else {
            // if bot message, append.
            self.messages.append(getJSQMessageForChatMessage(message))
            self.reloadChatView()
        }
    }
    
    
    // sets a message:
    func getJSQMessageForChatMessage(message: AnyObject) -> JSQMessage {
        let messageTimeString = message["createdAt"]! as! String!
        let text = message["message"]! as! String!
        let messageTime = Util.convertUTCTimestampToDate(messageTimeString)
        let isBot = message["isBot"]! as! Bool!
        var userId = ""
        var username = ""
        
        if (!isBot) {
            userId = message["author"]!!["_id"]! as! String!
            username = message["author"]!!["name"]! as! String!
        } else {
            username = "meet-bot"
        }
        
        print("JSQPoopMEssage: \(userId) - \(username)")
        return JSQMessage(senderId: userId, senderDisplayName: username, date: messageTime, text: text)
    }
    
    
    func setUpSocket() {
        self.socket = SocketIOClient(socketURL: NSURL(string: "https://one-mile.herokuapp.com")!)

        // adding handlers:
        self.socket!.on(self.meetId!) { data, ack in
            let message = data[0]
            print("message received socket: \(message)")
            self.handleSocketMessage(message)
        }
        
        self.socket!.on("serverReady") { data, ack in
            print("SERVER READY!!!! \(data[0])")
        }
        
        self.socket?.onAny {print("Got event: \($0.event), with items: \($0.items!)")}
        
        self.socket!.connect()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadMessagesView() {
        self.collectionView?.reloadData()
    }
    
    func reloadChatView() {
        self.reloadMessagesView()
        self.scrollToBottomAnimated(true)
    }
    
    func fetchMessages() {
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        let url = "https://one-mile.herokuapp.com/meet_chat_messages?meetId=\(self.meetId!)&start=\(self.start)&count=\(self.count)&accessToken=\(accessToken)"
        
        print("getChatMessagesForMeet url: \(url)")
        
        Alamofire.request(.GET, url) .responseJSON { response in
            
            if let JSON = response.result.value {
                
                if (JSON["error"] != nil) {
                    // handle this!
                }
                
                // should be obtained in decreasing order of timestamp:
                let chatMessages = JSON["messages"] as? NSMutableArray
                
                // if nothing, pass.
                if (chatMessages == nil || chatMessages!.count == 0) {
                    return
                }
                
                for message in (chatMessages! as NSArray as! [AnyObject]) {
                    // now create a JSQMessage object and append to the messages list:
                    self.messages.append(self.getJSQMessageForChatMessage(message))
                }
                
                self.reloadChatView()
                
                // set up socket once all of the message are fetched and set:
                self.setUpSocket()
            }
        }
    }
}


//MARK - Setup
extension MeetThreadViewController {
    
    func setup() {
        self.senderId = Util.CURRENT_USER_ID
        self.senderDisplayName = ""
        self.showLoadEarlierMessagesHeader = true
        
        // don't display avatar images:
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
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
        
        let label = message.senderDisplayName + " (" + Util.getChatTimestamp(message.date) + ")"
        
        return NSAttributedString(string: label)
    }
    
    // height for bubble top label
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
        
        //return kJSQMessagesCollectionViewCellLabelHeightDefault
        return 20
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
    
//    // display avatar image:
//    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
//        return nil
//    }
    
    // load earlier messages:
    override func collectionView(collectionView: JSQMessagesCollectionView, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        // load 10 earlier messages:
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        let url = "https://one-mile.herokuapp.com/meet_chat_messages?meetId=\(self.meetId!)&start=\(self.count)&count=\(self.count + 10)&accessToken=\(accessToken)"
        let oldBottomOffset = self.collectionView.contentSize.height - self.collectionView.contentOffset.y
        self.showLoadEarlierMessagesHeader = false
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        Alamofire.request(.GET, url) .responseJSON { response in
            if let JSON = response.result.value {

                if (JSON["error"] != nil) {
                    // handle this!
                }
                
                // should be obtained in decreasing order of timestamp:
                let chatMessages = JSON["messages"] as? NSMutableArray
                
                // if nothing, pass.
                if (chatMessages == nil || chatMessages!.count == 0) {
                    CATransaction.commit()
                    return
                }
                
                for message in (chatMessages! as NSArray as! [AnyObject]) {
                    // now create a JSQMessage object and append to the messages list:
                    self.messages.insert(self.getJSQMessageForChatMessage(message), atIndex: 0)
                }
                
                // reload the messages:
                self.reloadMessagesView()
                
                // scroll back to current position:
                self.finishReceivingMessageAnimated(false)
                self.collectionView.layoutIfNeeded()
                self.collectionView.contentOffset = CGPointMake(0, self.collectionView.contentSize.height - oldBottomOffset)
                CATransaction.commit()
                self.showLoadEarlierMessagesHeader = true
                
                // update start and count:
                self.start = self.count;
                self.count += self.messages.count
            }
        }
    }
    
    
    func sendMesage(message: String) {
        API.chat(message, meetId: self.meetId!)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        print("senderId: \(senderId)")
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages += [message]
        self.finishSendingMessage()
        
        // making a call to the server:
        self.sendMesage(text)

    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
    }
    
    

}






























