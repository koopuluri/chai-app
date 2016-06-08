//
//  UserModalViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 5/22/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit
import Alamofire

class UserModalViewController: UIViewController, UIGestureRecognizerDelegate {
    
    
    var userId: String?
    var meetId: String?
    var canRemoveFromMeet = true
    
    var onRemoval: (() -> Void)?
    
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
    
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        print("gestureRecognized")
        return true
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
        
        canRemoveFromMeet = Util.CURRENT_USER_ID != self.userId!
        if (!canRemoveFromMeet) {
            
            // don't give option to remove user:
            self.removeUserButton.hidden = true
        }
        
        fetchAndSetUser()
        
        view.backgroundColor = UIColor.clearColor()
        
        let exitTap = UITapGestureRecognizer(target: self, action: Selector("dismiss"))
        exitTap.delegate = self
        view.addGestureRecognizer(exitTap)
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // fetches user information and sets it in the view
    func fetchAndSetUser() {
        
        // start the spinner:
        self.loadingSpinner.startAnimating()
        
        func onUserReceived(user: Peep) {
            // setting the respective views:
            self.nameLabel.hidden = false
            self.nameLabel.text = user.name
            
            self.userDescriptionLabel.hidden = false
            self.userDescriptionLabel.text = user.description
            
            self.avatarImage.hidden = false
            Util.setAvatarImage(user.pictureUrl!, avatarImage: self.avatarImage)
            
            self.loadingSpinner.hidden = true
        }
        
        API.getUserInfo(onUserReceived)
    }
    
    
    @IBAction func removeUserFromMeet(sender: UIButton) {
        print("Remove user from meet!")
        self.onRemoval!()
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
