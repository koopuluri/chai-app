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
import FBSDKLoginKit

class API {
    
    static var APP: AppDelegate?
    
    static var BASE_URL = "https://one-mile.herokuapp.com/"
    
    static func accessToken() -> String {
        return FBSDKAccessToken.currentAccessToken().tokenString
    }
    
    static func checkAuthError(json: AnyObject) -> Bool {
        if (json["authError"]! != nil) {

                print("AAHA, auth error --> lgoging out")
                // logout of facebook.
                FBSDKLoginManager().logOut()
            
                // take user back to the signup form:
                API.APP!.goToSignup()
                return true
        } else {
            return false
        }
    }
    
    static func amIAttendee(meetId: String, callback: (Bool) -> Void) {
        let url = BASE_URL + "am_i_attendee?meetId=\(meetId)&accessToken=\(accessToken())"
        print("AMI ATTENDEE: \(url)")
        Alamofire.request(.GET, url) .responseJSON { response in
            if let JSON = response.result.value {
                if (API.checkAuthError(JSON)) {return}
                if (JSON["error"]! != nil) {
                    print("error in amiattendee: \(JSON["error"]! as! String!)")
                } else {
                    let isAttendee = JSON["result"]! as! Bool!
                    callback(isAttendee)
                }
            }
        }
    }
    
    static func removeUserFromMeet(meetId: String, attendeeId: String, callback: ((Bool) -> Void)) {
        let url = BASE_URL + "remove_attendee"
        Alamofire.request(.POST, url,
            parameters: [
                "meetId": meetId,
                "attendeeId": attendeeId,
                "accessToken": accessToken()
            ])
            .responseJSON { response in
                if let JSON = response.result.value {
                    if (API.checkAuthError(JSON)) {return}
                    if (JSON["error"]! != nil) {
                        print("could not removeUserFromMeet \(JSON["error"]! as! String!)")
                        callback(false)
                    } else {
                        print("removedUser!")
                        callback(true)
                    }
                }
        }
    }
    
    static func exitMeet(meetId: String, callback: (Bool) -> Void) {
        let url = BASE_URL + "exit_meet"
        Alamofire.request(.POST, url,
            parameters: [
                "meetId": meetId,
                "accessToken": accessToken()
            ])
            .responseJSON { response in
                if let JSON = response.result.value {
                    if (API.checkAuthError(JSON)) {return}
                    if (JSON["error"]! != nil) {
                        print("could not exitMeet: \(JSON["error"]! as! String!)")
                        callback(false)
                    } else {
                        print("exitted meet succesfuly")
                        callback(true)
                    }
                }
        }
    }
    
    static func cancelMeet(meetId: String, callback: (Bool) -> Void) {
        let url = BASE_URL + "cancel_meet"
        Alamofire.request(.POST, url,
            parameters: [
                "meetId": meetId,
                "accessToken": accessToken()
            ])
            .responseJSON { response in
                if let JSON = response.result.value {
                    if (API.checkAuthError(JSON)) {return}
                    if (JSON["error"] != nil) {
                        print("could not cancel meet \(JSON["error"]! as! String!)")
                        callback(false)
                    } else {
                        print("canceled Meet")
                        callback(true)
                    }
                }
        }
    }
    
    static func openedChat(meetId: String) {
        let url = BASE_URL + "opened_chat"
        Alamofire.request(.POST, url,
            parameters: [
               "meetId": meetId,
               "accessToken": accessToken()
        ])
        .responseJSON { response in
            if let JSON = response.result.value {
                if (API.checkAuthError(JSON)) {return}
                
                if (JSON["error"] != nil) {
                    let error = JSON["error"]! as! String!
                    if (error != nil) {
                        print("FUUUUCK")
                        return
                    }
                }
                
                print("opened CHAT! \(JSON["result"]! as! String!)")
            }
        }
    }
    
    static func getMeetAttendees(meetId: String, callback: ([Peep]) -> Void) {
        let url = BASE_URL + "meet_attendees?meetId=\(meetId)&accessToken=\(accessToken())"
        Alamofire.request(.GET, url) .responseJSON { response in
            if let JSON = response.result.value {
                if (API.checkAuthError(JSON)) {return}
                // TODO: handle the error case:
                if (JSON["error"] != nil) {
                    
                }
                
                let attendees = JSON["attendees"] as? NSMutableArray
                
                var users: [Peep] = []
                for user in (attendees! as NSArray as! [AnyObject]) {
                    let _id = user["user"]!!["_id"]! as! String!
                    let username = user["user"]!!["name"]! as! String!
                    let picUrl = user["user"]!!["pictureUrl"]! as! String!
                    
                    let peep = Peep(_id: _id)
                    peep.name = username
                    peep.pictureUrl = picUrl
                    users.append(peep)
                }
                
                callback(users)
            }
        }
        
    }
    
    static func getMeetsAtLocation(loc: CLLocationCoordinate2D, start: Int, count: Int, callback: (todayMeets: [Meet], tomorrowMeets: [Meet]) -> Void) {
        let url = "https://one-mile.herokuapp.com/meets_by_location?long=\(loc.longitude)&lat=\(loc.latitude)&start=\(start)&count=\(count)&accessToken=\(accessToken())"
        
        var todayMeets: [Meet] = []
        var tomorrowMeets: [Meet] = []
        
        print("reloadMeetsFromServer: \(url)")
        Alamofire.request(.GET, url) .responseJSON { response in
            
            if let JSON = response.result.value {
                if (API.checkAuthError(JSON)) {return}
                
                if (JSON["error"] != nil) {
                    // handle...
                }
                
                let meets = JSON["meets"] as? NSMutableArray
                if (meets != nil && meets?.count != 0) {
                    
                    for meet in (meets! as NSArray as! [AnyObject]) {
                        
                        let meetTimeString = meet["startTime"]! as! String!
                        print("meettimeString: \(meetTimeString)")
                        
                        let meetTime = Util.convertUTCTimestampToDate(meetTimeString)
                        let title = meet["title"]! as! String!
                        let _id = meet["_id"]! as! String!
                        let duration = meet["duration"]! as! Int!
                        let count = meet["count"]! as! Int!
                        let maxCount = meet["maxCount"]! as! Int!
                        
                        print("meetTime: \(meetTime)")
                        
                        
                        let hostName = meet["createdBy"]!!["name"]! as! String!
                        let hostPicUrl = meet["createdBy"]!!["pictureUrl"]! as! String!
                        
                        let host = Peep()
                        host.name = hostName
                        host.pictureUrl = hostPicUrl
                        
                        // create the meet obj:
                        
                        let meet = Meet(_id: _id, title: title, startTime: meetTime, duration: duration, count: count, maxCount: maxCount, createdBy: host)
                        
                        // if today, add to today's list, else tomorrow's:
                        let isToday = NSCalendar.currentCalendar().isDateInToday(meetTime)
                        if (isToday) {
                            todayMeets.append(meet)
                        } else {
                            tomorrowMeets.append(meet)
                        }
                    }
                }
            }
            
            // return:
            callback(todayMeets: todayMeets, tomorrowMeets: tomorrowMeets)
        }

    }
    
    static func getUpcomingMeets(callback: ([UpcomingMeet]) -> Void) {
        let url = "https://one-mile.herokuapp.com/user_upcoming_meets?accessToken=\(accessToken())"
        print("API.getUpcomingMeets: \(url)")
        
        Alamofire.request(.GET, url) .responseJSON { response in
            if let JSON = response.result.value {
                if (API.checkAuthError(JSON)) {return}
                if (JSON["error"] != nil) {
                    // handle...
                }
                
                let userMeets = JSON["userMeets"] as? NSMutableArray
                var upcomingMeets: [UpcomingMeet] = []
                if (userMeets != nil  && userMeets?.count != 0) {
                    for result in (userMeets! as NSArray as! [AnyObject]) {
                        // make a Meet obj:
                        
                        let meetId = result["meet"]!!["_id"]! as! String!
                        let title = result["meet"]!!["title"]! as! String!
                        let startTimeString = result["startTime"]! as! String!

                        let startTime = Util.convertUTCTimestampToDate(startTimeString)
                        let meet = UpcomingMeet(_id: meetId, time: startTime, title: title)
                        
                        upcomingMeets.append(meet)
                    }
                }
                
                // return:
                callback(upcomingMeets)
            }
        }
    }
    
    static func getUserChats(start: Int, count: Int, callback: ([ChatInfo]) -> Void) {
        let url = "https://one-mile.herokuapp.com/user_chats?start=\(start)&count=\(count)&accessToken=\(accessToken())"
        print("getUserChats: \(url)")
        Alamofire.request(.GET, url) .responseJSON { response in
            
            if let JSON = response.result.value {
                if (API.checkAuthError(JSON)) {return}
                
                if (JSON["error"] != nil) {
                    // handle error!
                }

                // converting:
                let results = JSON["results"] as? NSMutableArray
                var infos: [ChatInfo] = []
                
                if (results == nil || results!.count == 0) {
                    return callback(infos)
                }
                
                for result in (results! as NSArray as! [AnyObject]) {

                    let title = result["meet"]!!["title"]! as! String!
                    let chatTimeString = result["meet"]!!["lastChatMessage"]!!["timestamp"]! as! String!
                    let lastOpenedTimeString = result["lastOpenedChat"]! as! String!
                    
                    var authorNameString = ""
                    let authorName = result["meet"]!!["lastChatMessage"]!!["authorName"]
                    if (authorName! != nil ) {
                        print("authorName: \(authorName)")
                        authorNameString = authorName! as! String!
                    }
                    
                    var contentString = ""
                    let content = result["meet"]!!["lastChatMessage"]!!["message"]!
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
    
    static func getMeetIsNotifications(meetId: String, callback: (Bool) -> Void) {
        let url = BASE_URL + "meet_is_notif?meetId\(meetId)&accessToken=\(accessToken())"
        Alamofire.request(.GET, url) .responseJSON { response in
            if let JSON = response.result.value {
                if (API.checkAuthError(JSON)) {return}
                if (JSON["error"] != nil) {
                    // do nothing??
                }
                
                callback(JSON["result"]! as! Bool!)
            }
        }
    }
    
    static func setUserNotifications(isNotif: Bool) {
        let url = BASE_URL + "set_user_notif"
        Alamofire.request(.POST, url,
            parameters: [
                "isNotif": isNotif,
                "accessToken": accessToken()
            ])
            .responseJSON { response in
                if let JSON = response.result.value {
                    if (API.checkAuthError(JSON)) {return}
                    if (JSON["error"] != nil) {
                        print("could not update user notif!")
                    } else {
                        print("set user notif succesfully")
                    }
                }
        }
    }
    
    static func setMeetNotifications(meetId: String, isNotif: Bool) {
        let url = BASE_URL + "set_meet_notif"
        Alamofire.request(.POST, url,
            parameters: [
                "meetId": meetId,
                "isNotif": isNotif,
                "accessToken": accessToken()
            ])
            .responseJSON { response in
                if let JSON = response.result.value {
                    if (API.checkAuthError(JSON)) {return}
                    if (JSON["error"] != nil) {
                        print("could not update meet notif!")
                    } else {
                        print("set meet notif succesfully")
                    }
                }
        }
    }
    
    static func getAttendeeInfo(userId: String, callback: (Peep) -> Void) {
        let url = "https://one-mile.herokuapp.com/attendee_info?accessToken=\(accessToken())&userId=\(userId)"
        print("getAttendeeInfo(): \(url)")
        Alamofire.request(.GET, url) .responseJSON { response in
            print("got response! - fetchUserInfo()")
            if let JSON = response.result.value {
                if (API.checkAuthError(JSON)) {return}
                if (JSON["error"]! != nil) {
                    // handle it...
                    print("error in getAttendeeInfo: \(JSON["error"]! as! String!)")
                }
                
                let name = JSON["name"]! as! String!
                let desc = JSON["description"]! as! String!
                let pictureUrl = JSON["pictureUrl"]! as! String!
                
                let user = Peep()
                user.name = name
                user.description = desc
                user.pictureUrl = pictureUrl
                callback(user)
            }
        }
    }
    
    static func getUserInfo(callback: (Peep) -> Void) {
        let url = "https://one-mile.herokuapp.com/user_info?accessToken=\(accessToken())"
        print("getUSerInfo(): \(url)")
        Alamofire.request(.GET, url) .responseJSON { response in
            print("got response! - fetchUserInfo()")
            if let JSON = response.result.value {
                if (API.checkAuthError(JSON)) {return}
                if (JSON["error"]! != nil) {
                    // handle it...
                }
                
                let name = JSON["name"]! as! String!
                let desc = JSON["description"]! as! String!
                let pictureUrl = JSON["pictureUrl"]! as! String!
                
                let user = Peep()
                user.name = name
                user.description = desc
                user.pictureUrl = pictureUrl
                print("user created! - \(user.name)")
                callback(user)
            }
        }
    }
    
    static func editUserDescription(desc: String) {
        let url = "https://one-mile.herokuapp.com/edit_user_description"
        Alamofire.request(.POST, url,
            parameters: [
                "description": desc,
                "accessToken": accessToken()
            ])
            .responseJSON { response in
                if let JSON = response.result.value {
                    if (API.checkAuthError(JSON)) {return}
                    if (JSON["error"]! != nil)  {
                        print("could not update user desc")
                    } else {
                        print("updated user description!")
                    }
                }
        }
    }
    
    
    static func createMeet(title: String, desc: String, maxAttendees: Int, duration: Int, time: NSDate, loc: CLLocationCoordinate2D, locName: String, locAddress: String, success: (String) -> Void, fail: (String) -> Void) {
        
        let url = "https://one-mile.herokuapp.com/create_meet"
        Alamofire.request(.POST, url,
            parameters: [
                "accessToken": accessToken(),
                "title": title,
                "description": desc,
                "maxAttendees": maxAttendees,
                "duration": duration,
                "timestamp": time,
                "loc.lat": loc.latitude,
                "loc.long": loc.longitude,
                "loc.name": locName,
                "loc.address": locAddress
            ])
            .responseJSON { response in
                
                // setting isJoining to false (must be true right now, or we wouldn't be here);
                print("handling the returned thing from Request");
                
                if let JSON = response.result.value {
                    if (API.checkAuthError(JSON)) {return}
                    if (JSON["error"]! != nil) {
                        fail(JSON["error"]! as! String!)
                    } else {
                        let newMeetId = JSON["savedMeetId"]! as! String!
                        success(newMeetId)
                    }
                }
        }
    }
    
    static func chat(message: String, meetId: String) {
        let url = "https://one-mile.herokuapp.com/chat"
        Alamofire.request(.POST, url,
            parameters: [
                "message": message,
                "accessToken": accessToken(),
                "meetId": meetId
            ])
            .responseJSON { response in
                print("chatted. Server response: \(response)")
        }
    }
    
    static func fetchAndSetUserId() {
        let url = BASE_URL + "user_id?accessToken=\(accessToken())"
        print("fetchAndsetUserId: \(url)")
        Alamofire.request(.GET, url) .responseJSON { response in
            if let JSON = response.result.value {
                if (API.checkAuthError(JSON)) {return}
                let userId = JSON["userId"]! as! String!
                print("user id fetched and set: \(userId)")
                Util.CURRENT_USER_ID = userId
            }
        }
    }
}

















