//
//  PeopleViewController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 2/10/16.
//  Copyright (c) 2016 Poop. All rights reserved.
//

import UIKit

var aDesc = "I like apples. They're amazing. Sometimes when I walk around campus, I carry 2 apples. One for me, and one to share with any passerbyers. Apples make my life joyous."

var users = [
    User(firstName: "Richard", lastName: "Feynman", description: aDesc),
    User(firstName: "Jenny", lastName: "THE", description: aDesc),
    User(firstName: "Kravnik", lastName: "Pooshta", description: aDesc),
    User(firstName: "Steve", lastName: "Smith", description: aDesc),
    User(firstName: "Jello", lastName: "Beenz", description: aDesc),
    User(firstName: "Penpyl", lastName: "Monroe", description: aDesc),
    User(firstName: "Srinivas", lastName: "Kumar", description: aDesc),
    User(firstName: "Anne", lastName: "Johnson", description: aDesc),
    User(firstName: "Akira", lastName: "Kurosawa", description: aDesc),
    User(firstName: "Steve", lastName: "Smith", description: aDesc),
    User(firstName: "Jello", lastName: "Beenz", description: aDesc),
    User(firstName: "Penpyl", lastName: "Monroe", description: aDesc),
    User(firstName: "Srinivas", lastName: "Kumar", description: aDesc),
    User(firstName: "Anne", lastName: "Johnson", description: aDesc),
    User(firstName: "Akira", lastName: "Kurosawa", description: aDesc)
]


class PeopleViewController: UITableViewController {
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
 
        if let personViewController = segue.destinationViewController as? PersonViewController {
            
            if let index = self.tableView.indexPathForSelectedRow?.row {
                let person = users[index]
                
                // setting the newMEet var for MeetViewController (the first view controller in the MeetNav stack:
                personViewController.person = person
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return users.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PersonCell", forIndexPath: indexPath)
        
        let user = users[indexPath.row] as User
        
        if let initialLabel = cell.viewWithTag(100) as? UILabel {
            initialLabel.text = "\(Array(user.firstName.characters)[0])\(Array(user.lastName.characters)[0])"
            
            // setting the color of the initials:
            let rgbValue = user.firstName.hash
            let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
            let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
            let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
            let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
            
            var textColor = color
        }
        
//        if let avatarImage = cell.viewWithTag(100) as? UIImageView {
//            avatarImage.layer.cornerRadius =  12 // half of height / width
//            avatarImage.layer.masksToBounds = YES;
//            avatarImage.backgroundColor = UIColor.
//        }
//        
        if let nameLabel = cell.viewWithTag(101) as? UILabel {
            nameLabel.text = user.firstName + " " + user.lastName
        }

        return cell 
    }

}
