//
//  MeetInfoCell.swift
//  Ratings
//
//  Created by Karthik Uppuluri on 5/20/16.
//  Copyright © 2016 Poop. All rights reserved.
//

import UIKit

class MeetInfoCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
  
    @IBOutlet weak var hostLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeOuterView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
