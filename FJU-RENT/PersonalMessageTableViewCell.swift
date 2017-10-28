//
//  PersonalMessageTableViewCell.swift
//  FJU-RENT
//
//  Created by WZH on 2017/9/19.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit


class PersonalMessageTableViewCell: UITableViewCell {
    
    @IBOutlet var reportReasonTextView :UITextView!
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
