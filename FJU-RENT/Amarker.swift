//
//  Amarker.swift
//  FJU-RENT
//
//  Created by Bomin on 2017/10/29.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import Foundation
import UIKit

class Amarker: NSObject {
    
    var id: String?
    var uid: String?
    //var position:String?
    var latitude:Double?
    var longitude:Double?
    var title:String?
    var snippet:String?
    var imgPath:String?
    
    init(id: String?,uid: String?,latitude:Double?,longitude:Double?, title: String?, snippet: String?, imgPath: String?){
        self.id = id
        self.uid = uid
        self.latitude = latitude
        self.longitude = longitude
        self.title = title
        self.snippet = snippet
        self.imgPath = imgPath
        
        
    }
}
