//
//  User.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 2/8/16.
//  Copyright (c) 2016 Poop. All rights reserved.
//

import UIKit

// a user.
class User: NSObject {
    var firstName: String
    var userDescription: String
    var lastName: String
    
    init(firstName: String, lastName: String, description: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.userDescription = description
    }
}
