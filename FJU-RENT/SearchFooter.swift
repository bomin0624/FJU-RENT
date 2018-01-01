//
//  SearchFooter.swift
//  FJU-RENT
//
//  Created by WZH on 2017/9/16.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit

class SearchFooter: UIView {
    
    let label: UILabel = UILabel()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    func configureView() {
        self.backgroundColor = UIColor(red: 110/255, green: 177/255, blue: 255/255, alpha: 1)
        self.alpha = 0.0
        
        // Configure label
        label.textAlignment = .center
        label.textColor = UIColor.white
        addSubview(label)
    }
    
    override func draw(_ rect: CGRect) {
        label.frame = self.bounds
    }
    
    //MARK: - Animation
    fileprivate func hideFooter() {
        UIView.animate(withDuration: 0.7) {[unowned self] in
            self.alpha = 0.0
        }
    }
    
    fileprivate func showFooter() {
        UIView.animate(withDuration: 0.7) {[unowned self] in
            self.alpha = 1.0
        }
    }
}

extension SearchFooter {
    //MARK: - Public API
    
    public func setNotFiltering() {
        label.text = ""
        hideFooter()
    }
    
    public func setIsFilteringToShow(filteredItemCount: Int, of totalItemCount: Int) {
        if (filteredItemCount == totalItemCount) {
            setNotFiltering()
        } else if (filteredItemCount == 0) {
            label.text = "沒有符合的項目"
            showFooter()
        } else {
            label.text = "找到\(filteredItemCount)筆資料,總共\(totalItemCount)筆資料"
            showFooter()
        }
    }   
    
}
