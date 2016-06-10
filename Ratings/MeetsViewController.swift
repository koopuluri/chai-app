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
    
    var todayMeets: [Meet] = []
    var tomorrowMeets: [Meet] = []
    
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
    var userMeets: [UpcomingMeet] = []
    
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
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
    }
    
    
    // ==========================================================================
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        startRefresh()
    }
    
    
    // if user's current location set, goes and fetches meets in the area:
    func fetchMeets() {
        
        if (self.currentLocation != nil) {
            
            // on receiving meets:
            func onMeetsReceived(todayMeets: [Meet], tomrrowMeets: [Meet]) {
                self.todayMeets = todayMeets
                self.tomorrowMeets = tomrrowMeets
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
            
            // Pulling meets from the server:
            API.getMeetsAtLocation(self.currentLocation!, start: self.start, count: self.count, callback: onMeetsReceived)
        }
    }
    
    
    // fetches all of the users meets (joined / hosting) that are upcoming:
    func fetchUserUpcomingMeets() {
        self.userMeetsLoading = true
        
        func onUpcomingMeetsReceived(meets: [UpcomingMeet]) {
            self.userMeets = meets
            //print("obtained userMeets! \(self.userMeets!.count)")
            self.userMeetsLoading = false
            
            // reloading the UpcomingMeets cell:
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
        }
        
        API.getUpcomingMeets(onUpcomingMeetsReceived)
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
                            meetId = self.todayMeets[index]._id  // getting the meetId for the selected meet.
                        }
                        else if (section == 2){
                            meetId = self.tomorrowMeets[index]._id
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
            return self.todayMeets.count
        } else {
            return self.tomorrowMeets.count
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
        
        var meet: Meet = (indexPath.section == 1) ? todayMeets[indexPath.row] : tomorrowMeets[indexPath.row]
        
        if let titleLabel = cell.viewWithTag(100) as? UILabel {
            titleLabel.text = meet.title
        }
        
        if let hostLabel = cell.viewWithTag(101) as? UILabel {
            hostLabel.text = meet.createdBy?.name
        }
        
        if let timeLabel = cell.viewWithTag(102) as? UILabel {
            let meetTime = meet.startTime
            timeLabel.text = Util.getUpcomingMeetTimestamp(meetTime)
            timeLabel.textColor = Util.getMainColor()
        }
        
        if let durationLabel = cell.viewWithTag(105) as? UILabel {
            let duration = meet.duration!
            print("obtained duration: \(duration)")
            durationLabel.text = "for " + Util.getDurationText(duration)
            durationLabel.textColor = Util.getMainColor()
        }
          
        if let avatarImage = cell.viewWithTag(104) as? UIImageView {
            let picUrl = meet.createdBy?.pictureUrl!
            Util.setAvatarImage(picUrl!, avatarImage: avatarImage)
        }
        
        if let countLabel = cell.viewWithTag(103) as? UILabel {
            let count = meet.count!
            let maxCount = meet.maxCount!
            
            countLabel.text = String(count) + "/" + String(maxCount)
        }
        
        return cell 
    }
}
