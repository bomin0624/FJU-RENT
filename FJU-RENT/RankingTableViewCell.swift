//
//  RankingTableViewCell.swift
//  FJU-RENT
//
//  Created by Bomin on 2017/10/21.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit

class RankingTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var moneyLabel: UILabel!
    @IBOutlet weak var rentImage: UIImageView!
    @IBOutlet weak var rank: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
