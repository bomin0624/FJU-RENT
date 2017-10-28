//
//  DetailModel.swift
//  FJU-RENT
//
//  Created by Gelzone on 2017/8/26.
//  Copyright © 2017年 Bomin. All rights reserved.
//

class DetailModel {
    
    var imgPath: String?
    var title: String?
    var area: String?
    var address: String?
    var rent: String?
    var landlord: String?
    var phone: String?
    var pings: String?
    var floor: String?
    var type: String?
    var trans: String?
    var detail: String?
    var id: String?
    
    init(imgPath: String?, title: String?, area: String?, address: String?, rent: String?, landlord: String?, phone: String?, pings: String?, floor: String?, type: String?, trans: String?, detail: String?, id: String?){
        self.imgPath = imgPath
        self.title = title
        self.area = area
        self.address = address
        self.rent = rent
        self.landlord = landlord
        self.phone = phone
        self.pings = pings
        self.floor = floor
        self.type = type
        self.trans = trans
        self.detail = detail
        self.id = id
    }
}
