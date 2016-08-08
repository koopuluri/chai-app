//
//  SignupProfileController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 4/16/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKLoginKit

// displays the user name and profile picture.
// asks to input description if they want.
class SignupProfileController: UIViewController {
    

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionInput: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var name: String?
    var pictureUrl: String?
    
    @IBAction func submitDescription(sender: UIButton) {
        // submit the description change to backend:
        // process change async, and jump to next 
        // view immediately:
        
        let url = ""
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        Alamofire.request(.POST, url,
            parameters: [
                "accessToken": accessToken
            ]
            ) .responseJSON { response in
                if let JSON = response.result.value {
                    if (JSON["error"]! != nil) {
                        
                        // need to explicitly end refreshing in this method because setTheMeet() not called in this conditional brach:
                        
                        // display a UIAlertView with message:
                        let alert = UIAlertController(title: ":(", message: (JSON["error"]! as! String!), preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    } else {
                        let isSignup = JSON["isSignup"]! as! Bool!
                        print("isSignup: \(isSignup)")
                        
                        if (isSignup!) {
                            // transition to the profile page to get description input...
                            self.performSegueWithIdentifier("SignupProfile", sender: nil)
                        } else {
                            // go straight to the main view controller...
                            self.performSegueWithIdentifier("SignupProfile", sender: nil)
                        }
                    }
                }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make call to server to get user info:
        let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
        
        let url = "https://one-mile.herokuapp.com/user_info?accessToken=\(accessToken)"
        print("about to fire request:")
        print(url)
        Alamofire.request(.GET, url) .responseJSON { response in
            
            if let JSON = response.result.value {
                self.name = JSON["name"]! as! String!
                self.pictureUrl = JSON["pictureUrl"]! as! String!
                
                print("pictureUrl: \(self.pictureUrl)")
                
                self.nameLabel.text = self.name
                
                if let data = NSData(contentsOfURL: NSURL(string: self.pictureUrl!)!) {
                    self.profileImageView.image = UIImage(data:data)
                }
            }
        }
    }
}


