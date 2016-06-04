//
//  MeetChatPageViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 4/2/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyButton

class MeetChatPageViewController: UIPageViewController {
    //let meetId = "56e1b6f5fa3f0c01f45568cd"
    
    @IBOutlet weak var joinButton: SwiftyButton!
    let dummyUserId = "56dbb2013cd9a60ed58b1ae3" // currently DUMMY_USER2!
    
    @IBOutlet weak var joinSpinner: UIActivityIndicatorView!
    var meetId: String?
    var from: String?
    var mode: String?
    
    var isMember = false
    
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var titleSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var titleView: UIView!
    
    var meetController: UIViewController?
    var chatController: UIViewController?
    
    let switchSegment = UISegmentedControl(items: ["info", "chat"])
    
    var pageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // making it so that the first row isn't behind the navbar:
        self.edgesForExtendedLayout = UIRectEdge.None
        
        dataSource = self
        delegate = self
        
        switchSegment.tintColor = UIColor.whiteColor()
        
        // styling the joinButton:
        joinButton.buttonColor = Util.getMainColor()
        joinButton.shadowHeight = 0
        joinButton.cornerRadius = 5
        joinButton.highlightedColor = UIColor.greenColor()
        joinButton.setTitle("join", forState: UIControlState.Normal)
        joinButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        fetchAndSetUserMeetInfo()
    }
    
    // adding another page for ChatView:
    func addChatView() {
        self.chatController = self.newChatController(self.meetId)
        self.orderedViewControllers.append(self.chatController!)
    }
    
    @IBAction func transitionMeetSettings(sender: UIButton) {
        if (self.isMember) {
            performSegueWithIdentifier("MeetSettingsSegue", sender: self)
        }
    }
    
    func setNavStyleForMember() {
        // set the color of the navbar:
        self.navigationController!.navigationBar.barTintColor = Util.getMainColor()
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
        
        self.titleButton.enabled = true
        self.titleButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    func setNavStyleForNonMember() {
        // user is not part of meet: ==> set joinButton, and reg. background color
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem?.tintColor = Util.getMainColor()

        self.titleButton.enabled = false
        self.titleButton.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
    }
    
    // gets following info about user-meet:
    // - {isHost?, isAttendee?, meetTitle}
    // once info is retrieved, determines navBar color, rightBarButtonItem, etc.
    // on start - puts loading
    func fetchAndSetUserMeetInfo() {
        if ((self.meetId) != nil) {
            let url = "https://one-mile.herokuapp.com/user_meet_info?meetId=\(self.meetId!)&userId=\(self.dummyUserId)"
            
            print("fetchMeetInfoUrl: \(url)")
            
            startTitleLoading()
            Alamofire.request(.GET, url) .responseJSON { response in
                if let JSON = response.result.value {
                    // TODO: handle the error case!!

                    var isAttendee = (JSON["isAttending"]! as! Bool!)
                    var isHost = (JSON["isHost"]! as! Bool!)
                    let meetTitle = (JSON["title"] as! String!)
                    
                    print("isAttendee: \(isAttendee)")
                    print("isHost: \(isHost)")
                    
                    // setting navbar:
                    if (isHost || isAttendee) {
                        
                        self.isMember = true
                        
                        // adding the chat view as another page:
                        self.addChatView()
                        
                        // setting the correct view
                        var startController: UIViewController?
                        if (self.mode == "Meet") {
                            startController = self.orderedViewControllers[0]
                            self.setSwitchSegment(0)
                        } else {
                            startController = self.orderedViewControllers[1]
                            self.setSwitchSegment(1)
                        }
                        self.setViewControllers([startController!],
                            direction: .Forward,
                            animated: true,
                            completion: nil)
                        
                        self.setNavStyleForMember()

                    } else {
                        self.isMember = false
                        
                        // startView controller is the meetController:
                        let startController = self.orderedViewControllers[0]
                        self.setViewControllers([startController],
                            direction: .Forward,
                            animated: true,
                            completion: nil)
                        
                        self.setNavStyleForNonMember()
                    }
                    
                    // set the title to the meetTitle
                    self.setTitleViewText(meetTitle)
                }
            }
        } else {
            print("meetId is null!")
        }
    }
    
    // starts loading spinner in navbar (in titleLabel)
    func startTitleLoading() {
        self.titleSpinner.hidden = false
        self.titleSpinner.startAnimating()
    }
    
    // stops spinner in navbar (in titleLabel)
    func setTitleViewText(title: String?) {
        self.titleSpinner.hidden = true
        self.titleButton.setTitle(title, forState: UIControlState.Normal)
    }
    
    func startJoinSpinner() {
        self.joinSpinner.hidden = false
        self.joinSpinner.startAnimating()
    }
    
    func stopJoinSpinner() {
        self.joinSpinner.hidden = true
    }
    
    @IBAction func joinMeet(sender: SwiftyButton) {
        print("joining meet!")
        
        // making POST request to server to join meets:
        let url = "https://one-mile.herokuapp.com/join_meet"
        print("joinMeet() url: \(url)")
        
        // starting the join process:
        self.joinButton.hidden = true
        startJoinSpinner()
        
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
                    self.joinButton.hidden = false
                    
                } else {
                    let meetController = self.meetController! as! MeetController
                    meetController.meet = JSON["meet"]
                    print(JSON["meet"])
                    
                    // TODO: setting the following bools w/ values returned from the Server would be much safer. Current code
                    // is making an assumption.
                    print("received meet: \(meetController.meet!["_id"]! as! String!)")
                    
                    // setting the color of navbar to reflect that user is now a part of
                    // the meet:
                    self.navigationController!.navigationBar.barTintColor = UIColor.greenColor()
                    
                    self.addChatView()
                    
                    // replace the current loading spinner w/ SwitchSegment to toggle
                    // between Meet Information and ChatView:
                    self.setSwitchSegment(0)
                }
            }
            
            self.stopJoinSpinner()
        }
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        self.meetController = self.newMeetController(self.meetId)
        
        return [
            self.meetController!
        ]
    }()
    
    private func newMeetController(meetId: String?) -> UIViewController {
        let meetController = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewControllerWithIdentifier("MeetController") as! MeetController;
        
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
        threadController.meetId = self.meetId
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