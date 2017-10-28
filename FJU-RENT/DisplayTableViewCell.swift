//
//  DisplayTableViewCell.swift
//  FJU-RENT
//
//  Created by Gelzone on 2017/8/23.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class DisplayTableViewCell: UITableViewCell {
    
    @IBOutlet weak var displayView: UIImageView!
    @IBOutlet weak var headField: UILabel!
    @IBOutlet weak var moneyField: UILabel!
    @IBOutlet weak var pingField: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
