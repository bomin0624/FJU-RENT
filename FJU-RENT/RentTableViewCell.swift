//
//  RentTableViewCell.swift
//  FJU-RENT
//
//  Created by Bomin on 2017/8/18.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit

class RentTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!    
    @IBOutlet weak var rentImage: UIImageView!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    

}
