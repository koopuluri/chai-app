//
//  MeetsViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 1/27/16.
//  Copyright (c) 2016 Poop. All rights reserved.
//

import UIKit
import Alamofire
import MapKit
import SwiftyButton

import FBSDKLoginKit
import FBSDKCoreKit


class MeetsViewController: UITableViewController, CLLocationManagerDelegate {
    
    // to have access to parent pageViewController for page shift on button press
    var parentPageViewController: MainController?
    
    var meets: NSMutableArray?
    
    var todayMeets: NSMutableArray?
    var tomorrowMeets: NSMutableArray?
    
    var start = 0
    var count = 10
    
    @IBOutlet weak var createMeetButton: SwiftyButton!
    
    var currentLocation: CLLocationCoordinate2D?
    
    // location manager used to grab user's current location
    var locationManager = CLLocationManager()
    
    // used for transitions triggered by clicking on a user meet in the UpcomingCell (first Cell of this TableView)
    var userMeetId: String?
    
    // keeps track of loading of user meets:
    var userMeetsLoading = true
    var userMeets: NSMutableArray?
    
    @IBAction func create(sender: AnyObject) {
        
    }
    
    @IBAction func chat(sender: UIBarButtonItem) {
        let poop = self.navigationController?.parentViewController as? MainController
        poop!.programmaticallyMoveToPage(2, direction: UIPageViewControllerNavigationDirection.Forward)
    }
    
    @IBAction func settings(sender: UIBarButtonItem) {
        let poop = self.navigationController?.parentViewController as? MainController
        poop!.programmaticallyMoveToPage(0, direction: UIPageViewControllerNavigationDirection.Reverse)
    }
    
    func startRefresh() {
        self.tableView.setContentOffset(CGPointMake(0, self.tableView.contentOffset.y-(self.refreshControl?.frame.size.height)!), animated: true);
        self.refreshControl?.beginRefreshing()
        self.refreshControl?.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    
    // grab user current location:
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (self.currentLocation == nil) {
            self.currentLocation = manager.location!.coordinate
            
            // need to start refresh():
            print("found current location, now fetching meets!")
            fetchMeets()
        } else {
            // do nothing: currentLocationis already set.
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // making it so that the first row isn't behind the navbar:
        tableView.contentInset = UIEdgeInsetsMake(44,0,0,0);
        
        // navigation bar coloring:
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem?.tintColor = Util.getMainColor()
        self.navigationItem.rightBarButtonItem?.tintColor = Util.getMainColor()
        
        createMeetButton.buttonColor = Util.getMainColor()
        createMeetButton.shadowHeight = 0
        createMeetButton.cornerRadius = 5
        createMeetButton.highlightedColor = UIColor.greenColor()
        
        
        // setting the location manager stuff:
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            print("locationManager stuff set in viewdidLoad()")
        }
        
        self.todayMeets = NSMutableArray()
        self.tomorrowMeets = NSMutableArray()
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        startRefresh()
    }
    
    
    // ==========================================================================
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.hidden = false
    }
    
    
    // if user's current location set, goes and fetches meets in the area:
    func fetchMeets() {
        if (self.currentLocation != nil) {
            // Pulling meets from the server:
            let lat: String = "\(self.currentLocation!.latitude)"
            let long: String = "\(self.currentLocation!.longitude)"
            let url = "https://one-mile.herokuapp.com/meets_by_location?long=\(long)&lat=\(lat)&start=\(start)&count=\(count)&accessToken=poop"
            
            // reset today and tomorrow lists:
            self.todayMeets = NSMutableArray()
            self.tomorrowMeets = NSMutableArray()
            
            print("reloadMeetsFromServer: \(url)")
            Alamofire.request(.GET, url) .responseJSON { response in
                
                if let JSON = response.result.value {
                    let meets = JSON["meets"] as? NSMutableArray
                    if (meets != nil) {
                        for meet in (meets! as NSArray as! [AnyObject]) {
                            
                            let meetTimeString = meet["startTime"]! as! String!
                            print("meettimeString: \(meetTimeString)")
                            
                            let meetTime = Util.convertUTCTimestampToDate(meetTimeString)
                            
                            // if today, add to today's list, else tomorrow's:
                            let isToday = NSCalendar.currentCalendar().isDateInToday(meetTime)
                            if (isToday) {
                                self.todayMeets!.addObject(meet)
                                print("updated today meets: \(self.todayMeets!.count)")
                            } else {
                                self.tomorrowMeets!.addObject(meet)
                                print("updated tomorrow's meets: \(self.tomorrowMeets!.count)")
                            }
                        }
                    }
                    
                    print("reloading data with the following: \(self.todayMeets!.count) ; \(self.tomorrowMeets!.count)")
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    
    // fetches all of the users meets (joined / hosting) that are upcoming:
    func fetchUserUpcomingMeets() {
        let url = "https://one-mile.herokuapp.com/user_upcoming_meets?accessToken=poop"
        
        self.userMeetsLoading = true
        
        Alamofire.request(.GET, url) .responseJSON { response in
            if let JSON = response.result.value {
                self.userMeets = JSON["userMeets"] as? NSMutableArray
                //print("obtained userMeets! \(self.userMeets!.count)")
                self.userMeetsLoading = false
                
                // reloading the UpcomingMeets cell:
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
            }
        }
    }
    
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        fetchMeets()
        fetchUserUpcomingMeets()
    }
    
    @IBAction func unwindMeets(segue: UIStoryboardSegue) {}
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        if (segue.identifier == "UserMeetSegue") {
            if let meetChatNavController = segue.destinationViewController as? MeetChatNavController {
                
                let meetChatController = meetChatNavController.viewControllers.first as! MeetChatPageViewController
                
                print("seguing to meetChatController view UserMeets:: \(userMeetId)")
                meetChatController.meetId = userMeetId!
                meetChatController.from = "Meets"
                meetChatController.mode = "Meet"
            }
            
        } else {
            
            if let meetChatNavController = segue.destinationViewController as? MeetChatNavController {
                
                if let index = self.tableView.indexPathForSelectedRow?.row {
                    if let section = self.tableView.indexPathForSelectedRow?.section {
                        
                        var meetId: String?
                        if (section == 1) {
                            meetId = self.todayMeets![index]["_id"]! as! String!  // getting the meetId for the selected meet.
                        }
                        else if (section == 2){
                            meetId = self.tomorrowMeets![index]["_id"] as! String!
                        } else {
                            // woah there
                        }
                        let meetChatController = meetChatNavController.viewControllers.first as! MeetChatPageViewController
                        
                        print("seguing to meetChatController: \(meetId)")
                        meetChatController.meetId = meetId
                        meetChatController.from = "Meets"
                        meetChatController.mode = "Meet"
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 3
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "My upcoming meets"
        } else if (section == 1){
            return "Today's meets"
        } else {
            return "Tomorrow's meets"
        }
    }
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if (indexPath.section == 1 || indexPath.section == 2) {
            return 118.0
        } else {
            return 100.0
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if (section == 0) {
            return 1
        } else if (section == 1) {
            if (self.todayMeets != nil) {
                return self.todayMeets!.count
            } else {
                return 0
            }
        } else {
            if (self.tomorrowMeets != nil) {
                return self.tomorrowMeets!.count
            } else {
                return 0
            }
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("UpcomingCell") as! UpcomingCell
            
            // setting reference to self so that cell can initiate transitions to other controllers via ref.
            cell.parentTableViewController = self
            
            if (self.userMeetsLoading) {
                cell.startLoading()
            } else {
                // stoppin gthe loading:
                cell.stopLoading()
                
                // giving cell all of the upcoming meets:
                cell.meets = self.userMeets
                cell.reloadData()
            }

            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MeetCell", forIndexPath: indexPath)
    
        var meet: AnyObject!
        if (indexPath.section == 1) {
            meet = todayMeets![indexPath.row]
        } else if (indexPath.section == 2) {
            print("cell fort tomorrow: \(indexPath.row)")
            meet = tomorrowMeets![indexPath.row]
        }
        
        if let titleLabel = cell.viewWithTag(100) as? UILabel {
            titleLabel.text = (meet["title"]! as! String!)
        }
        
        if let hostLabel = cell.viewWithTag(101) as? UILabel {
            //hostLabel.text = (meet["createdBy"]!!["firstName"]! as! String!)
            hostLabel.text = "by: Karthik Uppuluri"
        }
        
        if let timeLabel = cell.viewWithTag(102) as? UILabel {
            let meetTimeString = meet["startTime"]! as! String!
            let meetTime = Util.convertUTCTimestampToDate(meetTimeString)
            timeLabel.text = Util.getUpcomingMeetTimestamp(meetTime)
            timeLabel.textColor = Util.getMainColor()
        }
        
        if let durationLabel = cell.viewWithTag(105) as? UILabel {
            let duration = meet["duration"]! as! Int
            print("obtained duration: \(duration)")
            durationLabel.text = Util.getDurationText(duration)
            durationLabel.textColor = Util.getMainColor()
        }
        
        // now for the views that hold time and duration:
        if let timeView = cell.viewWithTag(1) as? UIView! {
            timeView.layer.borderWidth = 0.4
            timeView.layer.borderColor = UIColor.lightGrayColor().CGColor
            timeView.layer.cornerRadius = 5.0
            timeView.backgroundColor = UIColor.whiteColor()
        }
        
        if let durationView = cell.viewWithTag(2) as? UIView! {
            durationView.layer.borderWidth = 0.4
            durationView.layer.borderColor = UIColor.lightGrayColor().CGColor
            durationView.layer.cornerRadius = 5.0
            durationView.backgroundColor = UIColor.whiteColor()
        }
        
        
        if let avatarImage = cell.viewWithTag(104) as? UIImageView {
            let picUrl = "https://scontent.xx.fbcdn.net/hprofile-xpf1/v/t1.0-1/p50x50/12509882_565775596928323_668499748259808876_n.jpg?oh=4733ef1dc8bc40849533f84e82e8a5a3&oe=57BA0EA0"
            Util.setAvatarImage(picUrl, avatarImage: avatarImage)
        }
        
        if let countLabel = cell.viewWithTag(103) as? UILabel {
            let count = (meet["count"]! as! Int!)
            let maxCount = meet["maxCount"]! as! Int!
            
            countLabel.text = String(count) + "/" + String(maxCount)
        }
        
        return cell 
    }
}
