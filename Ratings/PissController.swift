//
//  PissController.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 4/13/16.
//  Copyright © 2016 Poop. All rights reserved.
//
// Loading code from: http://stackoverflow.com/a/28893660
//

import UIKit
import Alamofire

class PissController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var meetId: String?
    
    @IBOutlet weak var meetDescriptionLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var hostNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var joinSettingsButton: UIBarButtonItem!

    // parent view name from which user reached current one.
    // used to navigate to that view on back.
    var from: String?
    
    var meet: AnyObject?
    
    let dummyUserId = "56dbb2013cd9a60ed58b1ae3" // currently DUMMY_USER2!
    
    var isCurrentUserHost = false
    var isCurrentUserAttendee = false
    
    // when true, loading spinner shown while making call to server to join the user to this meet:
    var isJoining = false

    @IBOutlet weak var attendeesTableView: UITableView!

    // If self.meet is set when this is called, it will update the UI to 
    // show the meet's information.
    func setTheMeet() {
        let parent = self.parentViewController! as! MeetChatPageViewController
        
        if (self.meet != nil) {
            print("WOAH WE GOT THE MEEEET! \(self.meetId)")
            let title = self.meet!["title"]! as! String!

            self.titleLabel.text = title
            parent.setNavTitle(title)
            
            self.meetDescriptionLabel.text = self.meet!["description"]! as! String!
            self.timestampLabel.text = self.meet!["time"]! as! String!
            self.hostNameLabel.text = self.meet!["createdBy"]!!["firstName"]! as! String!
            
//            self.attendingCountLabel.text = String(self.meet!["count"]! as! Int!) + "/" + String(self.meet!["maxCount"]! as! Int!)
            
            // setting the join button text:
            if isCurrentUserAttendee || isCurrentUserHost{
                self.joinSettingsButton.title = "settings"
                
                // setting the color:
                if isCurrentUserHost {
                    self.parentViewController!.navigationController!.navigationBar.barTintColor = UIColor.orangeColor()
                } else {
                    self.parentViewController!.navigationController!.navigationBar.barTintColor = UIColor.greenColor()
                }
                
                // since we know know that this user is part of this meet, we push onto the 
                // pageViewer a ChatView:
                // this also sets the navBar item to be a switchBar (to toggle b/w meet info and chat)

                parent.pushChatView()
            } else {
                // setting the join meet button and its functionality:
                
                let joinButton = UIBarButtonItem(title: "join", style: UIBarButtonItemStyle.Plain, target: self.parentViewController, action: #selector(PissController.joinMeet))
                
                self.parentViewController!.navigationItem.rightBarButtonItem = joinButton
            }
        } else {
            print("meet is null right now")
        }
    }

    
    func refresh() {
        if (self.isJoining) {
            joinMeet()
        } else {
            fetchMeet()
        }
    }
    
    @IBAction func joinMeet() {
        print("joining meet!")
        
        // making POST request to server to join meets:
        let url = "https://one-mile.herokuapp.com/join_meet"
        print("joinMeet() url: \(url)")
        
        // start the loading spinner before server call:
        self.startLoading()
        
        // making request to join current user to meet w/ id=self.meetId:
        Alamofire.request(.POST, url, parameters: ["meetId": self.meetId!, "userId": self.dummyUserId]) .responseJSON { response in
            
            // setting isJoining to false (must be true right now, or we wouldn't be here);
            self.isJoining = false
            print("handling the returned thing from Request");
            
            if let JSON = response.result.value {
                
                if (JSON["error"]! != nil) {
                    
                    // need to explicitly end refreshing in this method because setTheMeet() not called in this conditional brach:

                    // display a UIAlertView with message:
                    let alert = UIAlertController(title: ":(", message: (JSON["error"]! as! String!), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    self.meet = JSON["meet"]
                    print(JSON["meet"])
                    
                    // TODO: setting the following bools w/ values returned from the Server would be much safer. Current code
                    // is making an assumption.
                    print("received meet: \(self.meet!["_id"]! as! String!)")
                    self.isCurrentUserAttendee = true;
                    self.isCurrentUserHost = false;
                    self.setTheMeet()
                }
                
                // stop the spinner
                self.stopLoading()
            }
        }
    }

    
    func fetchMeet() {
        // Pulling meet from server
        let url = "https://one-mile.herokuapp.com/get_meet?id=\(self.meetId!)&userId=\(self.dummyUserId)"
        
        print("about to fetchMeet()!")
        self.startLoading()
        Alamofire.request(.GET, url) .responseJSON { response in
            if let JSON = response.result.value {
                // TODO: handle the error case!!
                print("Got meet")
                print(JSON)
                self.meet = JSON["meet"]
                self.isCurrentUserAttendee = (JSON["isAttending"]! as! Bool!)
                self.isCurrentUserHost = (JSON["isHost"]! as! Bool!)
                self.setTheMeet()
                self.stopLoading()
            }
        }
    }
    
    // contains the loading spinner jazz for this view:
    var loadingFrame = UIView()
    
    func startLoading() {
        let msg = "loading"
        let indicator = true
        let strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 50))
        strLabel.text = msg
        strLabel.textColor = UIColor.whiteColor()
        loadingFrame = UIView(frame: CGRect(x: view.frame.midX - 90, y: view.frame.midY - 25 , width: 180, height: 50))
        loadingFrame.layer.cornerRadius = 15
        loadingFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
        
        if indicator {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.startAnimating()
            loadingFrame.addSubview(activityIndicator)
        }
        loadingFrame.addSubview(strLabel)
        view.addSubview(loadingFrame)
    }
    
    func stopLoading() {
        // removes the loading frame from the parent view:
        
        self.loadingFrame.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attendeesTableView.delegate = self
        attendeesTableView.dataSource = self
        attendeesTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     */
    
    @IBAction func unwindMeet(sender: UIBarButtonItem) {
        if (from == "All Meets") {
            print("going to All Meets!")
            self.performSegueWithIdentifier("unwindMeets", sender: self)
        } else if (from == "Your Meets"){
            print("going to Your Meets!")
            self.performSegueWithIdentifier("unwindYourMeets", sender: self)
        }
    }
    

    /*
    // MARK: - TableView stuff for the attendee TableView:
    */
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.textLabel?.text = "A person " + String(indexPath.row)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

}
