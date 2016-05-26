//
//  PoopForm.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 5/25/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit

class PoopForm: UITableViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var startTimeDatePicker: UIDatePicker!
    @IBOutlet weak var daySegment: UISegmentedControl!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var maxAttendeesSegment: UISegmentedControl!
    @IBOutlet weak var durationSegment: UISegmentedControl!
    
    // for the Title text field:
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.utf16.count + string.utf16.count - range.length
        
        if newLength == 0 {
            // show error:
            titleTextField.layer.borderColor = UIColor.redColor().CGColor
            return true
        }
        
        titleTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        return newLength <= 5 // Bool
    }
    
    // for the description text view:
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let maxtext: Int = 140
        //If the text is larger than the maxtext, the return is false
        
        // Swift 2.0
        return textView.text.characters.count + (text.characters.count - range.length) <= maxtext
    }
    
    override func viewDidLoad() {
        
        submitButton.enabled = false
        
        // title text field
        titleTextField.delegate = self
        titleTextField.layer.borderWidth = 1.0
        titleTextField.layer.cornerRadius = 5.0
        titleTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        titleTextField.attributedPlaceholder = NSAttributedString(string: "Meet Title", attributes: [NSForegroundColorAttributeName : UIColor.lightGrayColor()])
        
        // description text view:
        descriptionTextView.layer.borderWidth = 1.0
        descriptionTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        descriptionTextView.layer.cornerRadius = 5.0
        descriptionTextView.backgroundColor = UIColor.whiteColor()
        descriptionTextView.delegate = self
        
        // attendees segment:
        maxAttendeesSegment.setTitle("2", forSegmentAtIndex: 0)
        maxAttendeesSegment.setTitle("3", forSegmentAtIndex: 1)
        maxAttendeesSegment.setTitle("5", forSegmentAtIndex: 2)
        maxAttendeesSegment.setTitle("10", forSegmentAtIndex: 3)
        maxAttendeesSegment.setTitle("20", forSegmentAtIndex: 4)
        maxAttendeesSegment.setTitle("100", forSegmentAtIndex: 5)
        maxAttendeesSegment.tintColor = UIColor.orangeColor()
        
        // location:
        
        // day:
        
        // duration:
        durationSegment.setTitle("30 mins", forSegmentAtIndex: 0)
        durationSegment.setTitle("1 hr", forSegmentAtIndex: 1)
        durationSegment.setTitle("2 hr", forSegmentAtIndex: 2)
        durationSegment.setTitle("3 hr", forSegmentAtIndex: 3)
        
        // tableView:
        tableView.backgroundColor = UIColor.orangeColor()
        
    }
}




























