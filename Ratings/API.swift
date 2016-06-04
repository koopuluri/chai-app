//
//  API.swift
//  Chai
//
//  Created by Karthik Uppuluri on 6/3/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import Foundation
import MapKit
import Alamofire

class API {
    
    static var accessToken = "poop"
    
    static var BASE_URL = "https://one-mile.herokuapp.com/"
    
    static func openedChat(meetId: String) {
        let url = BASE_URL + "opened_chat"
        Alamofire.request(.POST, url,
            parameters: [
               "meetId": meetId,
               "accessToken": accessToken
        ])
        .responseJSON { response in
            if let JSON = response.result.value {
                if (JSON["error"] != nil) {
                    print("could not update lastChatOpened!")
                } else {
                    print("opened CHAT!")
                }
            }
        }
    }
    
    static func getMeetsAtLocation(loc: CLLocationCoordinate2D, callback: ([Meet]) -> Void) {
        
    }
    
    static func getUpcomingMeets(callback: ([UpcomingMeet]) -> Void) {
        
    }
    
    static func getUserChats(start: Int, count: Int, callback: ([ChatInfo]) -> Void) {
        let url = "https://one-mile.herokuapp.com/user_chats?start=\(start)&count=\(count)&accessToken=\(accessToken)"
        
        Alamofire.request(.GET, url) .responseJSON { response in
            
            if let JSON = response.result.value {
                
                if (JSON["error"] != nil) {
                    // handle error!
                }

                // converting:
                let results = JSON["results"] as? NSMutableArray
                var infos: [ChatInfo] = []
                for result in (results! as NSArray as! [AnyObject]) {

                    let title = result["meet"]!!["title"]! as! String!
                    let chatTimeString = result["meet"]!!["lastChatMessage"]!!["timestamp"]! as! String!
                    let lastOpenedTimeString = result["lastOpenedChat"]! as! String
                    
                    var authorNameString = ""
                    var authorName = result["meet"]!!["lastChatMessage"]!!["authorName"]
                    if (authorName! != nil ) {
                        print("authorName: \(authorName)")
                        authorNameString = authorName! as! String!
                    }
                    
                    
                    var contentString = ""
                    let content = result["meet"]!!["lastChatMessage"]!!["content"]!
                    if (content != nil) {
                        contentString = content as! String!
                    }
                    
                    let meetId = result["meet"]!!["_id"]! as! String!
                    
                    print("obtained user chats!")
                    let chatInfo = ChatInfo(
                        meetId: meetId,
                        lastMessageTime: Util.convertUTCTimestampToDate(chatTimeString),
                        lastOpenedTime: Util.convertUTCTimestampToDate(lastOpenedTimeString),
                        meetTitle: title,
                        authorName: authorNameString,
                        lastMessageContent: contentString
                    )
                    
                    infos.append(chatInfo)
                }
                
                // TODO: server fails to sort currently. Remove this client side sort!
                let sortedArray = infos.sort { $0.lastMessageTime.compare($1.lastMessageTime) == .OrderedDescending }
                callback(sortedArray)
            }
        }
    }
    
}
