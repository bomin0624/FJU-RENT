//
//  foodmodel.swift
//  FJU-RENT
//
//  Created by iPhoneApp research center on 2017/11/19.
//  Copyright © 2017年 Bomin. All rights reserved.
//



class foodmodel{
    var name:String?
    var foodimageurl:String?
    var detail: String?
    var location: String?
    
    
    init(name: String?, foodimageurl: String?,detail:String?,location:String?){
        self.foodimageurl = foodimageurl
        self.name = name
        self.detail = detail
        self.location = location
    }
}
