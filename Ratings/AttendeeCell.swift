//
//  AttendeeCell.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 5/19/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit

class AttendeeCell: UITableViewCell  {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var attendeesForRow: NSMutableArray?
    
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    var parentController: MeetController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func reloadDate() {
        self.collectionView.reloadData()
    }
    
    func setDataSource() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
}

extension AttendeeCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        print("AttendeeCell delegate collecitonView thing: \(self.attendeesForRow)")
        if (self.attendeesForRow != nil) {
            print("AttendeeCell: going to render 1!!! \(self.attendeesForRow!.count)")
            return self.attendeesForRow!.count
        } else {
            return 0
        }
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
        self.parentController!.performSegueWithIdentifier("UserModalSegue", sender: nil)
    }
}


// collection view layout: centering the users in a row:
// TODO: get this right across multiple screen sizes!!
extension AttendeeCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        let cellCount = CGFloat((attendeesForRow?.count)!)
        if cellCount > 0 {
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let cellWidth = flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing
            let totalCellWidth = cellWidth * cellCount
            let contentWidth = collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right
            
            if (totalCellWidth < contentWidth) {
                let padding = (contentWidth - totalCellWidth) / 2.0
                return UIEdgeInsetsMake(0, padding, 0, padding)
            }
        }
        
        return UIEdgeInsetsZero    }
    
    //    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    //                let itemsPerRow:CGFloat = 4
    //                //let hardCodedPadding:CGFloat = 5
    //                  let itemWidth = (collectionView.bounds.width / itemsPerRow) - 30
    ////                let itemWidth = (collectionView.bounds.width / itemsPerRow) - hardCodedPadding
    //                let itemHeight = collectionView.bounds.height
    //        return CGSize(width: itemWidth, height: itemHeight)
    //    }
}