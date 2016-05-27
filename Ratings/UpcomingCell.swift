//
//  UpcomingCell.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 5/11/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit
import Alamofire

class UpcomingCell: UITableViewCell {
    
    var parentTableViewController: MeetsViewController?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var meets: NSMutableArray?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func reloadData() {
        self.collectionView.reloadData()
    }
    
    func startLoading() {
        spinner.hidden = false
        spinner.startAnimating()
    }
    
    func stopLoading() {
        spinner.hidden = true
        spinner.stopAnimating()
    }
}


extension UpcomingCell : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if ((self.meets) != nil) {
            print("UpcomingCell number of meets: \(self.meets!.count)")
            return self.meets!.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("collectionView click: \(indexPath)")
        
        self.parentTableViewController!.userMeetId = meets![indexPath.row]["meet"]!!["_id"]! as! String!
        print("UpcomingCell meet selected: \(self.parentTableViewController!.userMeetId)")
        
        self.parentTableViewController?.performSegueWithIdentifier("UserMeetSegue", sender: self.parentTableViewController)
        
    }
    

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("upcomingCell", forIndexPath: indexPath) as! UICollectionViewCell
        
        cell.backgroundColor = UIColor.orangeColor()
        cell.layer.cornerRadius = 5.0
        
        let meet = self.meets![indexPath.row]
        
        // setting values for the cell (currently dummy, change later):
        if let titleLabel = cell.viewWithTag(100) as? UILabel {
            print("setting upcoming meet title: \(meet["meet"]!!["title"]! as! String!)")
            titleLabel.text = meet["meet"]!!["title"]! as! String!
        }
        
        if let timeLabel = cell.viewWithTag(101) as? UILabel {
            
            let meetTime = Util.convertUTCTimestampToDate(meet["startTime"]! as! String!)
            
            // now getting just the time from this:
            let allUnits = NSCalendarUnit(rawValue: UInt.max)
            let comps = NSCalendar.currentCalendar().components(allUnits, fromDate: meetTime)
            timeLabel.text = String(comps.hour) + ":" + String(comps.minute)
        }
        
        return cell
    }
}

extension UpcomingCell : UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        let itemsPerRow:CGFloat = 3
//        let hardCodedPadding:CGFloat = 5
//        let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding
//        let itemHeight = collectionView.bounds.height - (2 * hardCodedPadding)
        return CGSize(width: 101, height: 70)
    }
    
}

