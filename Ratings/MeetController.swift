//
//  MeetController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 5/19/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit
import Alamofire

class MeetController: UITableViewController {
    
    var from: String?
    
    var meetId: String?
    var meet: AnyObject?
    
    let dummyUserId = "56dbb2013cd9a60ed58b1ae3" // currently DUMMY_USER2!
    
    var isCurrentUserHost = false
    var isCurrentUserAttendee = false
    
    // if loading, then spinner is displayed for the attendeeCell:
    var isAttendeesLoading = true
    
    // when true, loading spinner shown while making call to server to join the user to this meet:
    var isJoining = false
    
    var attendees: NSMutableArray?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "MeetInfo", bundle: nil), forCellReuseIdentifier: "MeetInfoCell")
        
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.blackColor()
        tableView.allowsSelection = false;
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl?.tintColor = UIColor.orangeColor()
        self.refreshControl?.backgroundColor = UIColor.whiteColor()
        
        print("MeetController.viewDidLoad().meetId: \(self.meetId)")
        startRefresh()
        fetchAttendees()
        // Do any additional setup after loading the view.
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
            let url = "https://one-mile.herokuapp.com/get_meet?id=\(self.meetId!)&userId=\(self.dummyUserId)"
            
            print("about to fetchMeet()!")
            Alamofire.request(.GET, url) .responseJSON { response in
                if let JSON = response.result.value {
                    // TODO: handle the error case!!
                    self.meet = JSON["meet"]
                    self.isCurrentUserAttendee = (JSON["isAttending"]! as! Bool!)
                    self.isCurrentUserHost = (JSON["isHost"]! as! Bool!)
                    self.setTheMeet()
                    self.stopRefresh()
                }
            }
        } else {
            print("meetId is null!")
        }
    }
    
    func fetchAttendees() {
        let url = "https://one-mile.herokuapp.com/meet_attendees?meetId=\(self.meetId!)&accessToken=poop"
        print("fetchAttendees url: \(url)")
        
        self.isAttendeesLoading = true
        Alamofire.request(.GET, url) .responseJSON { response in
            if let JSON = response.result.value {
                // TODO: handle the error case:
                self.attendees = JSON["attendees"]! as! NSMutableArray!
                self.isAttendeesLoading = false
                
                // reload the attendee section:
                self.tableView.reloadSections(NSIndexSet(index: 3), withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
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
            
            let numAttendeeRows = Int(ceil(Double((attendees?.count)!) / 3.0))
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
        
        var cell: UITableViewCell
        
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
                
                
                // giving it its meets:
                var endIndex = (index + 1)*3
                if (endIndex >= (self.attendees?.count)!) {
                    endIndex = (self.attendees?.count)! - 1
                }
                
                let subArr = self.attendees?.subarrayWithRange(NSMakeRange(index*3, endIndex + 1)) as! NSMutableArray
                attendeeCell.attendeesForRow = subArr
                attendeeCell.setDataSource()
            }
            attendeeCell.parentController = self
            return attendeeCell

        } else if (indexPath.section == 2) {
            cell = tableView.dequeueReusableCellWithIdentifier("DividerCell", forIndexPath: indexPath)
            
            if (self.meet == nil) {
                return cell
            }
            
            if let outerView = cell.viewWithTag(11) as? UIView! {
                outerView.layer.masksToBounds = false
                outerView.layer.cornerRadius = outerView.frame.height/2
            }
            
            if let countLabel = cell.viewWithTag(10) as? UILabel {
                
                let count = self.meet!["count"] as! Int!
                let maxCount = self.meet!["maxCount"] as! Int!
                countLabel.text = String(count) + "/" + String(maxCount)
            }
            
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
            
            let startTime = self.meet!["startTime"] as! String!
            let endTime = self.meet!["endTime"] as! String!
            
            let long = self.meet!["loc"]!![0] as! Int!
            let lat = self.meet!["loc"]!![1] as! Int!
//            
//            print("startTime: \(startTime)")
//            print("endTime: \(endTime)")
//            print("long: \(long)")
//            print("lat: \(lat)")
            
            cell.dayLabel.text = "today"
            cell.titleLabel.text = title
            cell.hostLabel.text = hostName
            
            let meetDate = Util.convertUTCTimestampToDate(startTime)
            let comps = Util.getComps(meetDate)
            
            cell.timeLabel.text = Util.getTimeString(comps.hour, min: comps.minute)
            
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
            cell = tableView.dequeueReusableCellWithIdentifier("MapViewCell", forIndexPath: indexPath)
            
            if (self.meet == nil) {
                return cell
            }
        }
        
        cell.backgroundColor = UIColor.blackColor()
        return cell
    }
    
//    override func tableView(tableView: UITableView,
//                            willDisplayCell cell: UITableViewCell,
//                                            forRowAtIndexPath indexPath: NSIndexPath) {
//        
//        guard let attendeeCell = cell as? AttendeeCell else { return }
//        
//        //tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
//        
//        
//        // setting 3 attendees to this row:
//        let index = indexPath.row
//        attendeeCell.attendeesForRow = self.attendees?.subarrayWithRange(NSMakeRange(index*3, (index+1)*3)) as! NSMutableArray
//        attendeeCell.parentController = self 
//        
//    }
    
    // height?
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 0) {
            return 200.0
        } else if (indexPath.section == 1) {
            return 400.0
        } else if (indexPath.section == 2) {
            return 100.0
        } else {
            return 90.0
        }
    }
}
