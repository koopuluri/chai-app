//
//  UpcomingCell.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 5/11/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit

class UpcomingCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension UpcomingCell : UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("upcomingCell", forIndexPath: indexPath) as! UICollectionViewCell
        
        cell.backgroundColor = UIColor.orangeColor()
        cell.layer.cornerRadius = 5.0
        
        // setting values for the cell (currently dummy, change later):
        if let titleLabel = cell.viewWithTag(100) as? UILabel {
            titleLabel.text = "Chai pe Charcha"
        }
        
        if let timeLabel = cell.viewWithTag(101) as? UILabel {
            
            // converting the default time to: "today at 4:30pm" / "tomorrow at 3pm" format.
            let diceRoll = Int(arc4random_uniform(6) + 1)
            if (diceRoll <= 3) {
                //timeLabel.text = (meet["startTime"]! as! String!)
                timeLabel.text = "4pm"
            } else {
                timeLabel.text = "3:30pm"
            }
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

