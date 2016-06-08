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
    
    var meets: [UpcomingMeet] = []
    
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
        return meets.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("collectionView click: \(indexPath)")
        
        self.parentTableViewController!.userMeetId = meets[indexPath.row]._id
        print("UpcomingCell meet selected: \(self.parentTableViewController!.userMeetId)")
        
        self.parentTableViewController?.performSegueWithIdentifier("UserMeetSegue", sender: self.parentTableViewController)
        
    }
    

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("upcomingCell", forIndexPath: indexPath) as! UICollectionViewCell
        
        cell.backgroundColor = UIColor.orangeColor()
        cell.layer.cornerRadius = 5.0
        cell.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.layer.borderWidth = 0.3
        
        let meet = self.meets[indexPath.row]
        
        // setting values for the cell (currently dummy, change later):
        if let titleLabel = cell.viewWithTag(100) as? UILabel {
            titleLabel.text = meet.title
        }
        
        if let dayLabel = cell.viewWithTag(102) as? UILabel {
            dayLabel.text = NSCalendar.currentCalendar().isDateInToday(meet.time) ? "today" : "tomorrow"
        }
        
        if let dayOuterView = cell.viewWithTag(103) as! UIView! {
            dayOuterView.layer.cornerRadius = 5.0
        }
        
        if let timeLabel = cell.viewWithTag(101) as? UILabel {
            timeLabel.text = Util.getUpcomingMeetTimestamp(meet.time)
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

