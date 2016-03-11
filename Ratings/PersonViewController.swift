//
//  PersonViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 2/10/16.
//  Copyright (c) 2016 Poop. All rights reserved.
//

import UIKit
import Alamofire

class PersonViewController: UIViewController {

    var userId: String?
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        nameLabel.hidden = true
        descriptionLabel.hidden = true
        spinner.startAnimating()
        
        let url = "https://one-mile.herokuapp.com/user_info?id=\(self.userId!)"
        print("get person info url: \(url)")
        
        Alamofire.request(.GET, url) .responseJSON { response in
            
            if let JSON = response.result.value {
                if (JSON["error"]! != nil) {
                    
                    self.spinner.hidden = true
                    
                    // display a UIAlertView with message:
                    let alert = UIAlertController(title: ":(", message: (JSON["error"]! as! String!), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    let user = JSON["user"]!
                    let firstName = user!["firstName"]! as! String!
                    let lastName = user!["lastName"]! as! String!
                    let description = user!["description"]! as! String!
                    
                    self.nameLabel.text = firstName + " " + lastName
                    self.descriptionLabel.text = description
                    self.nameLabel.hidden = false
                    self.descriptionLabel.hidden = false
                    
                    self.spinner.hidden = true
                    
                }
            }
        }
    }
}
