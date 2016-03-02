//
//  ThreadItem.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 2/8/16.
//  Copyright (c) 2016 Poop. All rights reserved.
//


// This represents the item to be displayed in a cell in ChatsViewController:
// - lastMessageContent (Str)
// - timestamp
// - 
// - 
// -
import UIKit

class ThreadItem: NSObject {
    var lastMessageContent: String
    var timestamp: String
    var lastMessageAuthor: String // make this into a User Object!
    var isSeenByCurrentUser: Bool
    var meetTitle: String
    
    // need to add the following:
//    var meetId: String
//    var threadId: String
    
    init(
        meetTitle: String,
        isSeenByCurrentUser: Bool,
        lastMessageAuthor: String,
        timestamp: String,
        lastMessageContent: String
        ) {
            self.meetTitle = meetTitle
            self.isSeenByCurrentUser = isSeenByCurrentUser
            self.lastMessageAuthor = lastMessageAuthor
            self.timestamp = timestamp
            self.lastMessageContent = lastMessageContent
    }
}
