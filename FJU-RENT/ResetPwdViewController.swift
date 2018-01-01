//
//  ResetPwdViewController.swift
//  FJU-RENT
//
//  Created by Gelzone on 2017/7/15.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ResetPwdViewController: UIViewController{
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func resetPress(_ sender: Any){
        if self.emailField.text == "" {
            let alertController = UIAlertController(title: "輸入錯誤", message: "請輸入完整的電子信箱", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            Auth.auth().sendPasswordReset(withEmail: self.emailField.text!, completion: { (error) in
                
                var title = ""
                var message = ""
                
                if error != nil {
                    title = "Error!"
                    message = (error?.localizedDescription)!
                } else {
                    title = "密碼修改郵件已發送至信箱裡"
                    message = "請登入郵箱,通過郵箱修改"
                    self.emailField.text = ""
                }
                
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            })
        }
    }    }

