//
//  Reports.swift
//  FJU-RENT
//
//  Created by WZH on 2017/9/18.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import Foundation
import UIKit

class Reports: NSObject {
    
    var id: String?
    var uid: String?
    var postId: String?
    var reporter: String?
    var reportId: String?
    var reportReason: String?
    var uidName:String?
    var reporterName:String?
    var uidNameType:String?
   
    init( id: String?,uid: String?,postId: String?, reporter: String?, reportId: String?, reportReason: String?,uidName:String?, reporterName:String?,uidNameType:String?){
        self.id = id
        self.uid = uid
        self.postId = postId
        self.reporter = reporter
        self.reportId = reportId
        self.reportReason = reportReason
        
        self.uidName = uidName
        self.reporterName = reporterName
        self.uidNameType = uidNameType
      
    }
}
