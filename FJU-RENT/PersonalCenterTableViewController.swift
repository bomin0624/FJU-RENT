//
//  PersonalCenterTableViewController.swift
//  FJU-RENT
//
//  Created by Bomin on 2017/8/7.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit

class PersonalCenterTableViewController: UITableViewController {
    
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var character: UILabel!
    @IBOutlet weak var addrent: UITableViewCell!
    @IBOutlet weak var myRent: UITableViewCell!
    @IBOutlet weak var changePwd: UITableViewCell!
    
    var ref : DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        let userID:String = (Auth.auth().currentUser?.uid)!
        ref.child("Members").child(userID).observeSingleEvent(of:.value,with: {(snapshot) in
            
            let dataDict = snapshot.value as! [String: Any]
            let user  = dataDict["email"] as! String
            let name  = dataDict["name"] as! String  // full name 改成 name
            let type  = dataDict["type"] as? String
            self.name.text = name
            self.user.text = user
            print(type as Any)
            if type == "T"{
                self.addrent.isHidden = true
                self.myRent.isHidden = true
                self.character.text = "租客"
            }else if type == "L"{
                self.character.text = "房東"
            }
            if type == "F" {
                self.changePwd.isHidden = true
                self.character.text = "Facebook用戶"
            }
        } )
    }


    @IBAction func logout(_ sender: Any) {
        try! Auth.auth().signOut()
        FBSDKAccessToken.setCurrent(nil)
        let vc = UIStoryboard(name : "Main", bundle: nil).instantiateViewController(withIdentifier: "bear")
        self.present(vc, animated: true,completion: nil)
    }


}
