//
//  MeetChatPageViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 4/2/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit
import Alamofire

class MeetChatPageViewController: UIPageViewController {
    //let meetId = "56e1b6f5fa3f0c01f45568cd"
    
    let dummyUserId = "56dbb2013cd9a60ed58b1ae3" // currently DUMMY_USER2!
    
    @IBOutlet weak var titleButton: UIButton!
    var meetId: String?
    var from: String?
    var mode: String?
    
    var meetController: UIViewController?
    var chatController: UIViewController?
    
    let switchSegment = UISegmentedControl(items: ["info", "chat"])
    
    var pageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        var startController: UIViewController?
        if (self.mode == "Meet") {
            startController = orderedViewControllers[0]
        } else {
            startController = orderedViewControllers[1]
            
            // and need to set the switchSegment here, because it's already known that the current user
            // is a part of this meet:
            self.setSwitchSegment(1)
        }
        
        self.setViewControllers([startController!],
                                direction: .Forward,
                                animated: true,
                                completion: nil)
        
    }
    
    // called when the navigation title button is clicked.
    // only navigates to settings if the user is a member / is host of meet.
    @IBAction func settings() {
        let meetController = self.meetController! as! PissController
        if (meetController.isCurrentUserAttendee || meetController.isCurrentUserHost) {
            // segue to the MeetSettings:
            performSegueWithIdentifier("MeetSettingsSegue", sender: nil)
        }
    }
    
    func setNavTitle(title: String?) {
        self.titleButton.setTitle(title, forState: UIControlState.Normal)
    }
    
    // adds user to meet.
    // updates UI to reflect addition / displays error UIAlertView in fail case:
    func joinMeet() {
        print("joining meet!")
        
        // making POST request to server to join meets:
        let url = "https://one-mile.herokuapp.com/join_meet"
        print("joinMeet() url: \(url)")
        
        // start the loading spinner on the right nav button:
        let spinnerView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        let spinnerBarButtonItem = UIBarButtonItem(customView: spinnerView)
        self.navigationItem.rightBarButtonItem = spinnerBarButtonItem
        
        // making request to join current user to meet w/ id=self.meetId:
        Alamofire.request(.POST, url, parameters: ["meetId": self.meetId!, "userId": self.dummyUserId]) .responseJSON { response in
            
            if let JSON = response.result.value {
                if (JSON["error"]! != nil) {
                    
                    // need to explicitly end refreshing in this method because setTheMeet() not called in this conditional brach:
                    
                    // display a UIAlertView with message:
                    let alert = UIAlertController(title: ":(", message: (JSON["error"]! as! String!), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    // replace loading spinner with the join button:
                    let joinButton = UIBarButtonItem(title: "join", style: UIBarButtonItemStyle.Plain, target: self.parentViewController, action: #selector(self.joinMeet))
                    
                    self.navigationItem.rightBarButtonItem = joinButton;
                    
                } else {
                    let meetController = self.meetController! as! PissController
                    meetController.meet = JSON["meet"]
                    print(JSON["meet"])
                    
                    // TODO: setting the following bools w/ values returned from the Server would be much safer. Current code
                    // is making an assumption.
                    print("received meet: \(meetController.meet!["_id"]! as! String!)")
        
                    meetController.isCurrentUserAttendee = true;
                    meetController.isCurrentUserHost = false;
                    meetController.setTheMeet()
                    
                    // setting the color of navbar to reflect that user is now a part of
                    // the meet:
                    self.navigationController!.navigationBar.barTintColor = UIColor.greenColor()
                    
                    // replace the current loading spinner w/ SwitchSegment to toggle
                    // between Meet Information and ChatView:
                    self.setSwitchSegment(0)
                }
            }
        }
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        
        if (self.mode == "Meet") {
            self.meetController = self.newMeetController(self.meetId)
            
            return [
                self.meetController!,
            ]
        } else {
            self.meetController = self.newMeetController(self.meetId)
            self.chatController = self.newChatController(self.meetId)
            return [
                self.meetController!,
                self.chatController!
            ]
        }
    }()
    
    private func newMeetController(meetId: String?) -> UIViewController {
        let meetController = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewControllerWithIdentifier("PissController") as! PissController;
        
        print("about to initialize the meetController from MeetChatPageViewController: \(self.meetId)")
        meetController.meetId = meetId;
        return meetController
    }
    
    // only called when the user has just successfuly "joined" a meet.
    // ==> add a chatView page, and set the switchSegment on the navbar (and it remains on the "Meet info" page)
    func pushChatView() {
        orderedViewControllers.append(self.newChatController(self.meetId))
        setSwitchSegment(0)
    }
    
    // this is called to set the switcher in the navigation bar (should only be called
    // if the current user is a part of this meet (either hosting or has joined).
    func setSwitchSegment(index: Int?) {
        switchSegment.selectedSegmentIndex = index!
        let switchBarButton = UIBarButtonItem(customView: switchSegment)
        self.navigationItem.rightBarButtonItem = switchBarButton
    }
    
    private func newChatController(meetId: String?) -> UIViewController {
        let threadController = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewControllerWithIdentifier("ThreadViewController") as! MeetThreadViewController;
        return threadController;
    }
}


// MARK: UIPageViewControllerDataSource

extension MeetChatPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(pageViewController: UIPageViewController,
                                     willTransitionToViewControllers pendingViewControllers:[UIViewController]) {
        if (NSStringFromClass(pendingViewControllers[0].classForCoder) == "Ratings.MeetThreadViewController") {
            self.pageIndex = 1
        } else {
            self.pageIndex = 0
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController,
                                    didFinishAnimating finished: Bool,
                                    previousViewControllers: [UIViewController],
                                    transitionCompleted completed: Bool) {
        if (finished && completed && previousViewControllers.count > 0) {
            switchSegment.selectedSegmentIndex = self.pageIndex
        }
    }
}

extension MeetChatPageViewController: UIPageViewControllerDataSource {
    
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        
        return orderedViewControllers[previousIndex]
    }
    
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        
        guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
}