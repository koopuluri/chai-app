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
    
    // when true, loading spinner shown while making call to server to join the user to this meet:
    var isJoining = false
    
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
        // Do any additional setup after loading the view.
    }
    
    // If self.meet is set when this is called, it will update the UI to
    // show the meet's information.
    func setTheMeet() {
        // reloading the MeetInfoCell and the DividerCell
        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
        tableView.reloadSections(NSIndexSet(index: 2), withRowAnimation: .None)
    }
    
    func joinMeet() {
        print("MeetController.joinMeet")
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
                    print("stopRefresh()")
                    self.stopRefresh()
                }
            }
        } else {
            print("meetId is null!")
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
            return people.count
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
        
        if (indexPath.section == 3) {
            cell = tableView.dequeueReusableCellWithIdentifier("AttendeeCell", forIndexPath: indexPath)
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
            
            let startTime = self.meet!["startTime"] as! String!
            let endTime = self.meet!["endTime"] as! String!
            
            let long = self.meet!["loc"]!![0] as! Int!
            let lat = self.meet!["loc"]!![1] as! Int!
            
            print("startTime: \(startTime)")
            print("endTime: \(endTime)")
            print("long: \(long)")
            print("lat: \(lat)")
            
            cell.dayLabel.text = "today"
            cell.timeOuterView.backgroundColor = UIColor.blackColor()
            cell.timeOuterView.layer.borderWidth = 1.0
            cell.timeOuterView.layer.borderColor = UIColor.orangeColor().CGColor
            cell.timeOuterView.layer.cornerRadius = cell.timeOuterView.frame.height / 2
 
            cell.titleLabel.text = title
            cell.hostLabel.text = hostName
            
            
            
            cell.timeLabel.text =
            cell.durationLabel.text = "duration: 1hr"
            
            cell.descriptionLabel.text = description

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
    
    override func tableView(tableView: UITableView,
                            willDisplayCell cell: UITableViewCell,
                                            forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let tableViewCell = cell as? AttendeeCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
    }
    
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


extension MeetController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        return people[collectionView.tag].count
    }
    
    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("attendeeCell",
                                                                         forIndexPath: indexPath)
        
        
        // setting default values for the user: TODO: change!!
        if let nameLabel = cell.viewWithTag(100) as? UILabel {
            nameLabel.text = "Foo Bar"
        }
        
        if let avatarImage = cell.viewWithTag(101) as? UIImageView {
            let picUrl = "https://scontent.xx.fbcdn.net/hprofile-xpf1/v/t1.0-1/p50x50/12509882_565775596928323_668499748259808876_n.jpg?oh=4733ef1dc8bc40849533f84e82e8a5a3&oe=57BA0EA0"
            
            Util.setAvatarImage(picUrl, avatarImage: avatarImage)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("collectionView click: \(indexPath)")
        performSegueWithIdentifier("UserModalSegue", sender: nil)
    }
}

// collection view layout: centering the users in a row:
// TODO: get this right across multiple screen sizes!!
extension MeetController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        let cellWidth = CGFloat(68.0)
        let leftOffset = (collectionView.bounds.width - 4*(cellWidth)) / 3
        let sectionInsets = UIEdgeInsets(top: 0.0, left: leftOffset, bottom: 0.0, right: 0.0)
        return sectionInsets
    }
    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//                let itemsPerRow:CGFloat = 4
//                //let hardCodedPadding:CGFloat = 5
//                  let itemWidth = (collectionView.bounds.width / itemsPerRow) - 30
////                let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding
//                let itemHeight = collectionView.bounds.height
//        return CGSize(width: itemWidth, height: itemHeight)
//    }
}

