//
//  Meet.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 2/2/16.
//  Copyright (c) 2016 Poop. All rights reserved.
//

import UIKit

class Meetup {
    var title: String
    var maxCount: Int
    var description: String
    var hostName: String
    var time: String
    var count: Int
    var locationX: Double
    var locationY: Double
    
    init(title: String, time: String, count: Int, description: String, hostName: String, maxCount: Int, locationX: Double, locationY: Double) {
        self.title = title
        self.description = description
        self.hostName = hostName
        self.maxCount = maxCount
        self.locationX = locationX
        self.locationY = locationY
        self.time = time
        self.count = count
    }
}
