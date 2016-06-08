//
//  MeetController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 5/19/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit
import Alamofire
import MapKit
import FBSDKLoginKit

class MeetController: UITableViewController, CLLocationManagerDelegate {
    
    var from: String?
    
    var meetId: String?
    var meet: AnyObject?
    
    var meetLocation: CLLocationCoordinate2D?
    
    // if loading, then spinner is displayed for the attendeeCell:
    var isAttendeesLoading = true
    
    // when true, loading spinner shown while making call to server to join the user to this meet:
    var isJoining = false
    
    // location manager used to grab user's current location
    var locationManager = CLLocationManager()
    
    var currentLocation: CLLocationCoordinate2D?
    
    var attendees: [Peep] = []
    
    var people: [[UIColor]] = [
        [UIColor.redColor(), UIColor.redColor(), UIColor.redColor(), UIColor.redColor()],
        [UIColor.redColor(), UIColor.redColor(), UIColor.redColor(), UIColor.redColor()],
        [UIColor.redColor(), UIColor.redColor(), UIColor.redColor(), UIColor.redColor()],
        [UIColor.redColor(), UIColor.redColor(), UIColor.redColor(), UIColor.redColor()],
        [UIColor.redColor(), UIColor.redColor(), UIColor.redColor(), UIColor.redColor()],
        [UIColor.redColor(), UIColor.redColor(), UIColor.redColor(), UIColor.redColor()],
        [UIColor.redColor(), UIColor.redColor(), UIColor.redColor(), UIColor.redColor()],
        [UIColor.redColor(), UIColor.redColor(), UIColor.redColor(), UIColor.redColor()]
    ]
    
    // grabbing the user's current location information:
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = manager.location!.coordinate
        
        // don't want any more updates!
        self.locationManager.stopUpdatingLocation()
        
        // now update the MapCell:
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "MeetInfo", bundle: nil), forCellReuseIdentifier: "MeetInfoCell")
        
        // some tableView styling:
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.blackColor()
        tableView.allowsSelection = false;
        
        // location stuff:
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl?.tintColor = UIColor.orangeColor()
        self.refreshControl?.backgroundColor = UIColor.whiteColor()
        
        print("MeetController.viewDidLoad().meetId: \(self.meetId)")
        startRefresh()
        fetchAttendees()
    }
    
    // If self.meet is set when this is called, it will update the UI to
    // show the meet's information.
    func setTheMeet() {
        // reloading the MeetInfoCell and the DividerCell
        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
        tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .None)
    }
    
    func refresh() {
        print("MeetController.refresh()")
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Pulling meet from server
        if ((self.meetId) != nil) {
            let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
            let url = "https://one-mile.herokuapp.com/get_meet?id=\(self.meetId!)&accessToken=\(accessToken)"
            
            print("about to fetchMeet() \(url)!")
            Alamofire.request(.GET, url) .responseJSON { response in
                if let JSON = response.result.value {
                    // TODO: handle the error case!!
                    self.meet = JSON["meet"]
                    
                    let lat = JSON["lat"]! as! Float!
                    let long = JSON["long"]! as! Float!
                    
                    self.meetLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
                    self.setTheMeet()
                    self.stopRefresh()
                }
            }
        } else {
            print("meetId is null!")
        }
    }
    
    func _onAttendeesReceived(users: [Peep]) {
        // TODO: testing right now, remove this:
        self.attendees = users
        
        //self.attendees = JSON["attendees"]! as! NSMutableArray!
        self.isAttendeesLoading = false
        
        // reload the attendee section:
        self.tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func fetchAttendees() {
        self.isAttendeesLoading = true
        API.getMeetAttendees(self.meetId!, callback: self._onAttendeesReceived)
    }

    func startRefresh() {
        self.tableView.setContentOffset(CGPointMake(0, self.tableView.contentOffset.y-(self.refreshControl?.frame.size.height)!), animated: true);
        self.refreshControl?.beginRefreshing()
        self.refreshControl?.sendActionsForControlEvents(UIControlEvents.ValueChanged)
    }
    
    func stopRefresh() {
        self.refreshControl?.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        if (section == 3) {
            
            if (self.isAttendeesLoading) {
                return 1
            }
            
            let numAttendeeRows = Int(ceil(Double((attendees.count)) / 3.0))
            print("numAttendeesRows: \(numAttendeeRows)")
            return numAttendeeRows
            
        } else {
            return 1
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 4
    }
    
    override func tableView(tableView: UITableView,
                            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // the Attendee section:
        if (indexPath.section == 3) {
            let index = indexPath.row
            let attendeeCell = tableView.dequeueReusableCellWithIdentifier("AttendeeCell", forIndexPath: indexPath) as! AttendeeCell
            
            if (self.isAttendeesLoading) {
                attendeeCell.loadingSpinner.hidden = false
                attendeeCell.loadingSpinner.startAnimating()
            } else {
                attendeeCell.loadingSpinner.hidden = true
                attendeeCell.loadingSpinner.stopAnimating()
                
                
                let totalCount = index*3 + 3
                var count = 3
                if (totalCount > self.attendees.count) {
                    count = (self.attendees.count) - index*3
                }
                
                let sub = self.attendees[index*3..<count]
                attendeeCell.attendeesForRow = sub
                attendeeCell.meetId = self.meetId
                attendeeCell.setDataSource()
            }
            attendeeCell.parentController = self
            attendeeCell.backgroundColor = UIColor.blackColor()
            return attendeeCell

        } else if (indexPath.section == 2) {
            let cell = tableView.dequeueReusableCellWithIdentifier("DividerCell", forIndexPath: indexPath)
            
            if (self.meet == nil) {
                return cell
            }
            
            if let outerView = cell.viewWithTag(11) as? UIView! {
                outerView.layer.masksToBounds = false
                outerView.layer.cornerRadius = 5.0
                outerView.backgroundColor = Util.getMainColor()
            }
            
            if let countLabel = cell.viewWithTag(10) as? UILabel {
                
                let count = self.meet!["count"] as! Int!
                let maxCount = self.meet!["maxCount"] as! Int!
                countLabel.text = String(count) + "/" + String(maxCount)
            }
            
            return cell
            
        } else if (indexPath.section == 1) {
            // TODO: remove redundancy here!
            let cell = tableView.dequeueReusableCellWithIdentifier("MeetInfoCell", forIndexPath: indexPath) as! MeetInfoCell
            
            if (self.meet == nil) {
                return cell
            }
            
            let title = self.meet!["title"]! as! String!
            let description = self.meet!["description"]! as! String!
            let hostName = (self.meet!["createdBy"]!!["name"]! as! String!)
            let picUrl = self.meet!["createdBy"]!!["pictureUrl"] as! String!
            let duration = self.meet!["duration"]! as! Int!
            let startTimeString = self.meet!["startTime"] as! String!
            
            cell.titleLabel.text = title
            cell.hostLabel.text = hostName
            
            let meetDate = Util.convertUTCTimestampToDate(startTimeString)
            let comps = Util.getComps(meetDate)
            
            cell.dayLabel.text = Util.getDay(meetDate)
            cell.timeLabel.text = Util.getUpcomingMeetTimestamp(meetDate)
            cell.durationLabel.text = Util.getDurationText(duration)
            cell.descriptionLabel.text = description
            
            // setting the height:
            print("pre-labelheight: \(cell.descriptionLabel.frame.height)")
            let newLabelHeight = Util.setHeightForLabel(description, label: cell.descriptionLabel, font: UIFont(name: "Helvetica", size: 14.0)!)
            print("newLabelHeight: \(newLabelHeight) vs. \(cell.descriptionLabel.frame.height)")
            
            let url = NSURL(string: picUrl)
            
            let avatarImage = cell.avatarImage
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
                dispatch_async(dispatch_get_main_queue(), {
                    avatarImage.image = UIImage(data: data!)
                    avatarImage.layer.borderWidth = 0.5
                    avatarImage.layer.masksToBounds = false
                    avatarImage.layer.borderColor = UIColor.lightGrayColor().CGColor
                    avatarImage.layer.cornerRadius = avatarImage.frame.height/2
                    avatarImage.clipsToBounds = true
                });
            }
            
            cell.backgroundColor = UIColor.blackColor()
            cell.setup()
            return cell
        } else {
            let mapCell = tableView.dequeueReusableCellWithIdentifier("MapViewCell", forIndexPath: indexPath) as! MapCell
            
            if (self.meet == nil) {
                return mapCell
            }
            
            if ((self.currentLocation) != nil) {
                // set the cell with the locations of user and meet:
                let locationAddress = self.meet!["locationAddress"]! as! String!
                let locationName = self.meet!["locationName"]! as! String!
                
                mapCell.setMap(
                    self.currentLocation,
                    meetLocation: self.meetLocation!,
                    meetLocationName: locationName,
                    meetLocationAddress: locationAddress
                )
                
            }

            return mapCell
        }
    }
    
    // height?
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return 200.0
        } else if (indexPath.section == 1) {
            return 320.0
        } else if (indexPath.section == 2) {
            return 80.0
        } else {
            return 90.0
        }
    }
}
