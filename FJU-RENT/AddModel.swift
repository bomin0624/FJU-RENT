//
//  AddModel.swift
//  FJU-RENT
//
//  Created by Gelzone on 2017/8/23.
//  Copyright © 2017年 Bomin. All rights reserved.
//

class Model {
    
    var title: String?
    var money: String?
    var pings: String?
    var imgPath: String?
    var id: String?
    var uid: String?
    var uniString: String?
    
    //add
    var address: String?
    //var money: String?
    //var name: String? = title
    //var rentImageUrl: String? = imgPath
    var genre: String? //type
    var area: String?
    var likeCount = Int()
    var timeStamp = Int()
    //add
    init(title: String?, money: String?, pings: String?, imgPath: String?, id: String?, uid: String?, uniString: String?,address: String?, genre :String? , area: String?, likeCount: Int, timeStamp: Int){
        self.title = title
        self.money = money
        self.pings = pings
        self.imgPath = imgPath
        self.id = id
        self.uid = uid
        self.uniString = uniString
        self.timeStamp = timeStamp
        //add
        self.address = address
        self.area = area
        self.genre = genre
        self.likeCount = likeCount
    }
}
