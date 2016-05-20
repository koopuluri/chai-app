//
//  MeetController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 5/19/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit


class MeetController: UITableViewController {
    
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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    override func tableView(tableView: UITableView,
                            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("AttendeeCell", forIndexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView,
                            willDisplayCell cell: UITableViewCell,
                                            forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let tableViewCell = cell as? AttendeeCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
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
        

        
        return cell
    }
}
