

//
//  CreateMeetTableViewController.swift
//  Ratings
//

//  Created by Karthik Uppuluri on 2/1/16.
//  Copyright (c) 2016 Poop. All rights reserved.
//

import UIKit

class CreateMeetTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
        print("cancel")
    }
    
    var meet: Meetup?
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var descriptionTextField: UITextView!
    
    @IBOutlet weak var timeDatePicker: UIDatePicker!
    
    @IBOutlet weak var maxCountPicker: UIPickerView!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("createMeetController.prepareForSegue():")
        print("dis what we got: title: \(self.titleTextField.text), description: \(self.descriptionTextField.text)")
        
        if let locationController = segue.destinationViewController as? LocationSelectionViewController {
            locationController.meetDescription = self.descriptionTextField.text!
            locationController.meetTitle = self.titleTextField.text!
            print("locationController stuff set!")
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.maxCountPicker.delegate = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    // PickerView stuffs:
    
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 500
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (row == 0) {
            return "No Limit"
        } else {
            return String(row)
        }
    }
}






