//
//  SettingsViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 5/15/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKLoginKit

class SettingsViewController: UITableViewController, UITextViewDelegate {
    
    var name: String?
    var desc: String?
    var pictureUrl: String?
    
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
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
    
    @IBAction func logout(sender: UIButton) {
        FBSDKLoginManager().logOut()
        
        // pop this viewController off!
        let signupController = storyboard?.instantiateViewControllerWithIdentifier("SignupController")
        self.presentViewController(signupController!, animated: true, completion: nil)
        //self.parentViewController?.navigationController?.dismissViewControllerAnimated(false, completion: nil)
        //self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // styling the navigation bar:
        self.navigationItem.rightBarButtonItem?.tintColor = Util.getMainColor()
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        tableView.tableFooterView = UIView()
        
        // setup:
        self.editDoneButton.hidden = true
        self.userDescTextView.hidden = true
        self.userDescTextView.delegate = self
        
        // setting the border:
        self.userDescTextView.layer.borderWidth = 1.0
        self.userDescTextView.layer.cornerRadius = 5.0
        
        // loading:
        self.loadingSpinner.tintColor = Util.getMainColor()
        self.loadingSpinner.hidesWhenStopped = true
        
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
            self.userDescTextView.becomeFirstResponder()
            self.userDescTextView.text = userDescLabel.text
            self.editDoneButton.setTitle("done", forState: UIControlState.Normal)
            self.viewMode = false
        } else {
            // now time to bring it back to view mode:
            self.userDescLabel.text = self.userDescTextView.text
            self.userDescLabel.hidden = false
            self.userDescTextView.hidden = true
            self.userDescTextView.resignFirstResponder()
            self.editDoneButton.setTitle("edit", forState: UIControlState.Normal)
            self.viewMode = true
            
            // making call to server to update user desc:
            API.editUserDescription(self.userDescTextView.text)
        }
    }
    
    func hideEverything() {
        self.userDescLabel.hidden = true
        self.avatarImage.hidden = true
        self.userDescTextView.hidden = true
        self.editDoneButton.hidden = true
        self.userName.hidden = true
    }
    
    func showEverything() {
        self.userDescLabel.hidden = false
        self.avatarImage.hidden = false
        self.userDescTextView.hidden = false
        self.editDoneButton.hidden = false
        self.userName.hidden = false
    }
    
    
    // displays user avatar, name and description:
    func fetchUserInfo() {
        loadingSpinner.startAnimating()
        hideEverything()
        func onUserReceived(user: Peep) {
            self.name = user.name
            self.desc = user.description
            self.pictureUrl = user.pictureUrl
            
            self.userDescLabel.text = self.desc
            self.userName.text = self.name
            
            // set the image
            Util.setAvatarImage(self.pictureUrl!, avatarImage: self.avatarImage)
            loadingSpinner.stopAnimating()
            showEverything()
            self.editDoneButton.hidden = false
        }
        
        API.getUserInfo(onUserReceived)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
