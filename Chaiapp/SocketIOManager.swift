//
//  SocketIOManager.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 5/29/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit
import SocketIOClientSwift

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "https://one-mile.herokuapp.com")!)
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    // connect to the chat server for a single meet:
    func connectToChatServer(meetId: String ) {
        socket.emit("connectToChat", meetId)
    }
}


