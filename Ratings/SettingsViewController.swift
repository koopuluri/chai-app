//
//  SettingsViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 5/15/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit
import Alamofire

class SettingsViewController: UITableViewController, UITextViewDelegate {
    
    var name: String?
    var desc: String?
    var pictureUrl: String?
    
    @IBOutlet weak var editDoneButton: UIButton!
    @IBOutlet weak var userDescTextView: UITextView!
    @IBOutlet weak var userDescLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBAction func toMeets(sender: UIBarButtonItem) {
        let poop = self.navigationController?.parentViewController as? MainController
        poop!.programmaticallyMoveToPage(1, direction: UIPageViewControllerNavigationDirection.Forward)
    }
    
    var viewMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // styling the navigation bar:
        self.navigationItem.rightBarButtonItem?.tintColor = Util.getMainColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        // setup:
        self.editDoneButton.hidden = true
        self.userDescTextView.hidden = true
        self.userDescTextView.delegate = self
        
        // setting the border:
        self.userDescTextView.layer.borderWidth = 1.0
        self.userDescTextView.layer.cornerRadius = 5.0
        
        fetchUserInfo()
    }
    
    // for the description text view:
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let maxtext: Int = 140
        guard let string = textView.text else {return true}
        //If the text is larger than the maxtext, the return is false
        
        // Swift 2.0
        return textView.text.characters.count + (text.characters.count - range.length) <= maxtext
    }

    // either "edit" / "done":
    @IBAction func onPress(sender: UIButton) {
        if (viewMode) {
            // toggle to edit mode:
            self.userDescLabel.hidden = true
            self.userDescTextView.hidden = false
            self.userDescTextView.text = userDescLabel.text
            self.editDoneButton.setTitle("done", forState: UIControlState.Normal)
            self.viewMode = false
        } else {
            // now time to bring it back to view mode:
            self.userDescLabel.text = self.userDescTextView.text
            self.userDescLabel.hidden = false
            self.userDescTextView.hidden = true
            self.editDoneButton.setTitle("edit", forState: UIControlState.Normal)
            self.viewMode = true
            
            // making call to server to update:
            let url = "https://one-mile.herokuapp.com/edit_user_description"
            Alamofire.request(.POST, url,
                parameters: [
                    "description": self.userDescTextView.text
                ])
                .responseJSON { response in
                    if let JSON = response.result.value {
                        if (JSON["error"]! != nil)  {
                            print("well, couldn't update user description... \(JSON["error"]! as! String!)")
                        } else {
                            print("updated user description!")
                        }
                    }
            }
        }
    }
    
    
    // displays user avatar, name and description:
    func fetchUserInfo() {
        let url = "https://one-mile.herokuapp.com/user_info"
        print("fetchUserInfo: \(url)")
        Alamofire.request(.GET, url) .responseJSON { response in
            print("got response! - fetchUserInfo()")
            if let JSON = response.result.value {
                print(JSON)

                self.name = JSON["name"]! as! String!
                self.desc = JSON["description"]! as! String!
                self.pictureUrl = JSON["pictureUrl"]! as! String!
                
                self.userDescLabel.text = self.desc
                self.userName.text = self.name
                
                // set the image
                Util.setAvatarImage(self.pictureUrl!, avatarImage: self.avatarImage)
                
                self.editDoneButton.hidden = false
                
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
