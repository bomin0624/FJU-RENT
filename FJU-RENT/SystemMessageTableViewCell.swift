//
//  SystemMessageTableViewCell.swift
//  FJU-RENT
//
//  Created by Bomin on 2017/8/28.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit


class SystemMessageTableViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
