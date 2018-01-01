//
//  CompareModel.swift
//  FJU-RENT
//
//  Created by iPhoneApp research center on 2017/10/10.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit

class CompareModel: NSObject {
    var title: String?
    var money: String?
    var pings: String?
    var id: String?
    var uid: String?
    var likeCount = Int()
    
    //add
    var address: String?
    
    var genre: String? //type
    var floor : String?
    //add
    init(title: String?, money: String?, pings: String?, id: String?, uid: String?, address: String?,likeCount : Int,  genre :String? , floor: String?){
        self.title = title
        self.money = money
        self.pings = pings
        
        self.id = id
        self.uid = uid
        self.likeCount = likeCount
        //add
        self.address = address
        
        self.genre = genre
        self.floor = floor
    }
    
    
}
