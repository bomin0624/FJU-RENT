//
//  ExpandableHeaderView.swift
//  FJU-RENT
//
//  Created by Bomin on 2017/9/9.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit


protocol ExpandableHeaderViewDelegate {
    
    func toggleSection(header: ExpandableHeaderView, section: Int)
}

class ExpandableHeaderView: UITableViewHeaderFooterView {
    
    var delegate: ExpandableHeaderViewDelegate?
    var section : Int!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
   

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderView)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderView)))
    }
    
    func selectHeaderView(gesture: UITapGestureRecognizer){
        
        let cell = gesture.view as! ExpandableHeaderView
        delegate?.toggleSection(header: self, section: cell.section)
        
    }
    
    func customInit(title: String,subtitle:String,section:Int,delegate:ExpandableHeaderViewDelegate) {
        self.titleLabel.text = title
        self.subLabel.text = subtitle
        self.section = section
        self.delegate = delegate
    }
    
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.titleLabel?.textColor = UIColor.white
        self.subLabel?.textColor = UIColor.white
        self.subLabel?.alpha = 0.7
        self.contentView.backgroundColor = UIColor.lightGray
        

}
}
