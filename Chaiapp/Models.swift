//
//  Models.swift
//  Chai

//  Created by Karthik Uppuluri on 6/3/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import Foundation
import MapKit


class Peep {
    var _id: String?
    var name: String?
    var email: String?
    var pictureUrl: String?
    var description: String?
    
    init(_id: String) {
        self._id = _id
    }
    
    init() {
        
    }
}

class Meet {
    var _id: String
    var startTime: NSDate
    var loc: CLLocationCoordinate2D?
    var locAddress: String?
    var locName: String?
    var title: String?
    var description: String?
    var count: Int?
    var maxCount: Int?
    var duration: Int?
    var createdBy: Peep?
    
    init(_id: String, title: String, startTime: NSDate, duration: Int, count: Int, maxCount: Int, createdBy: Peep) {
        self._id = _id
        self.title = title
        self.startTime = startTime
        self.duration = duration
        self.count = count
        self.maxCount = maxCount
        
        self.createdBy = createdBy
    }
    
    init(_id: String, title: String, description: String, startTime: NSDate, duration: Int, count: Int, maxCount: Int, loc: CLLocationCoordinate2D, locName: String, locAddress: String, createdBy: Peep) {
        self._id = _id
        self.startTime = startTime
        self.duration = duration
        self.loc = loc
        self.locAddress = locAddress
        self.locName = locName
        self.title = title
        self.description = description
        self.count = count
        self.maxCount = maxCount
        self.createdBy = createdBy
    }
}

class UpcomingMeet {
    var _id: String
    var time: NSDate
    var title: String
    
    init(_id: String, time: NSDate, title: String) {
        self._id = _id
        self.time = time
        self.title = title
    }
}

class ChatInfo {
    var meetId: String
    var lastMessageTime: NSDate
    var lastOpenedTime: NSDate
    var isSeen: Bool
    var meetTitle: String
    var authorName: String
    var lastMessageContent: String
    
    init(meetId: String, lastMessageTime: NSDate, lastOpenedTime: NSDate, meetTitle: String, authorName: String, lastMessageContent: String) {
        self.lastMessageTime = lastMessageTime
        self.lastOpenedTime = lastOpenedTime
        self.meetTitle = meetTitle
        self.authorName = authorName
        self.lastMessageContent = lastMessageContent
        self.meetId = meetId
        
        // now calculating isSeen:
        if (self.lastOpenedTime.compare(self.lastMessageTime) == NSComparisonResult.OrderedAscending) {
            isSeen = false
        } else {
            isSeen = true
        }
    }
}


class ChatMessage {
    var _id: String
    var time: NSDate
    var message: String
    var authorName: String
    var authorId: String
    
    init(_id: String, time: NSDate, message: String, authorName: String, authorId: String) {
        self._id = _id
        self.time = time
        self.message = message
        self.authorId = authorId
        self.authorName = authorName
    }
}


class User {
    var _id: String
    var name: String
    var description: String
    
    init(_id: String, name: String, desc: String) {
        self._id = _id
        self.name = name
        self.description = desc
    }
}

