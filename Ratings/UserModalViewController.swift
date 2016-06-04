//
//  UserModalViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 5/22/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit
import Alamofire

class UserModalViewController: UIViewController {
    
    
    var userId = "57129ebcedd2393b22395684"
    var canRemoveFromMeet = true
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var removeUserButton: UIButton!
    @IBOutlet weak var modalView: UIView!
    
    
    // pops off this modal view
    @IBAction func exit(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    
    @IBOutlet weak var userDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make everything hidden until information is fetched:
        avatarImage.hidden = true
        nameLabel.hidden = true
        userDescriptionLabel.hidden = true
        
        // style the modal view:
        modalView.layer.borderWidth = 1.0
        modalView.layer.cornerRadius = 5.0
        
        self.view.backgroundColor = UIColor.clearColor()
        self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        
        if (!canRemoveFromMeet) {
            
            // don't give option to remove user:
            self.removeUserButton.hidden = true
        }
        
        fetchAndSetUser()
    }
    
    // fetches user information and sets it in the view
    func fetchAndSetUser() {
        
        // start the spinner:
        self.loadingSpinner.startAnimating()
        
        let url = "https://one-mile.herokuapp.com/user_info?userId=\(self.userId)&accessToken=doesntmatterigtnow"
        
        Alamofire.request(.GET, url) .responseJSON { response in
            
            if let JSON = response.result.value {
                let picUrl = JSON["pictureUrl"]! as! String!
                let description = JSON["description"]! as! String!
                let name = JSON["name"]! as! String!
                
                print("get User info results:")
                print(picUrl)
                print(description)
                print(name)
                
                // setting the respective views:
                self.nameLabel.hidden = false
                self.nameLabel.text = name
                
                self.userDescriptionLabel.hidden = false
                self.userDescriptionLabel.text = description
                
                self.avatarImage.hidden = false
                Util.setAvatarImage(picUrl, avatarImage: self.avatarImage)
            }
            
            self.loadingSpinner.hidden = true
        }
    }
    
    
    @IBAction func removeUserFromMeet(sender: UIButton) {
        print("Remove user from meet!")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
