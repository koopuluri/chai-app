//
//  PersonViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 2/10/16.
//  Copyright (c) 2016 Poop. All rights reserved.
//

import UIKit

class PersonViewController: UIViewController {

    var person: User?
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        nameLabel.text = person!.firstName + " " + person!.lastName
        descriptionLabel.text = person!.userDescription
    }
}
