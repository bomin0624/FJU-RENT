//
//  Section.swift
//  FJU-RENT
//
//  Created by Bomin on 2017/9/9.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import Foundation

struct Section{
    var genre: String!
    var detail : [String]!
    var expanded : Bool!
    var subtitle: String!
    init(genre: String, detail: [String],expanded : Bool,subtitle: String){
        self.genre = genre
        self.detail = detail
        self.expanded = expanded
        self.subtitle = subtitle
    }
}
