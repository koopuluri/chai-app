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
    
    var attendeesForRow: ArraySlice<Peep>?
    var meetId: String?
    
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
        
        if (self.attendeesForRow != nil) {
            return self.attendeesForRow!.count
        } else {
            return 0
        }
    }
    
    
    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("attendeeCell",
                                                                         forIndexPath: indexPath)
        
        let user = self.attendeesForRow![indexPath.row]
        // setting default values for the user: TODO: change!!
        if let nameLabel = cell.viewWithTag(100) as? UILabel {
            nameLabel.text = user.name
        }
        
        if let avatarImage = cell.viewWithTag(101) as? UIImageView {

            Util.setAvatarImage(user.pictureUrl!, avatarImage: avatarImage)
        }
        return cell
    }
    
    
    func onRemovalComplete(index: Int) -> (() -> Void) {
        func remove() {
            self.attendeesForRow?.removeAtIndex(index)
            
            // make call to server to remove:
            API.removeUserFromMeet(self.meetId!, attendeeId: self.attendeesForRow![index]._id!, callback: nil)
        }
        
        return remove
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {        
        let userId = attendeesForRow![indexPath.row]._id
        let userModalVC = (self.parentController!.storyboard?.instantiateViewControllerWithIdentifier("UserModal") as! UserModalViewController)
        userModalVC.userId = userId
        userModalVC.onRemoval = self.onRemovalComplete(indexPath.row)
        userModalVC.modalPresentationStyle = .OverCurrentContext
        self.parentController!.presentViewController(userModalVC, animated: true, completion: nil)
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