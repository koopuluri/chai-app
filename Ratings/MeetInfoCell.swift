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
    
    @IBOutlet weak var timeOuterView: UIView!

    @IBOutlet weak var durationOuterView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup() {
        // set this outer view to be transparent:
//        self.durationAndTimeOuterView.alpha = 0.0
//        self.durationAndTimeOuterView.layer.zPosition = 0
        
        self.timeOuterView.backgroundColor = UIColor.whiteColor()
        self.timeOuterView.layer.cornerRadius = 5.0
        self.timeOuterView.layer.zPosition = 1
        
        self.timeLabel.textColor = Util.getMainColor()
        self.durationLabel.textColor = Util.getMainColor()
        
        self.durationOuterView.backgroundColor = UIColor.whiteColor()
        self.durationOuterView.layer.cornerRadius = 5.0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state:
        
    }
}
