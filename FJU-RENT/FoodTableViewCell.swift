//
//  FoodTableViewCell.swift
//  FJU-RENT
//
//  Created by iPhoneApp research center on 2017/11/19.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit

class FoodTableViewCell: UITableViewCell {
    
    @IBOutlet weak var FoodLabel: UILabel!

    @IBOutlet weak var foodimage: UIImageView!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
