//
//  MeetViewInfoCell.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 4/12/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit

class MeetViewInfoCell: UITableViewCell {

    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var hostName: UITextField!
    @IBOutlet weak var title: UITextField!
    @IBOutlet weak var timestamp: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
