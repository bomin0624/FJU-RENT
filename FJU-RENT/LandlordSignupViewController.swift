//
//  LandlordSignupViewController.swift
//  FJU-RENT
//
//  Created by Bomin on 2017/7/26.
//  Copyright © 2017年 Bomin. All rights reserved.
//
import UIKit
import Firebase
import FirebaseAuth


class LandlordSignupViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var comPwField: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    
    var userStorage: StorageReference!
    var ref :DatabaseReference!
    var container: ContainerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        guard nameField.text != "", emailField.text != "", password.text != "", comPwField.text != "" else {
            let alertController = UIAlertController(title: "輸入錯誤", message: "請輸入完整的資訊", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            return
        }
        if password.text == comPwField.text {
            Auth.auth().createUser(withEmail: emailField.text!, password: password.text!, completion: { (user, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                if let user = user {
                    let alertController = UIAlertController(title: "信箱認證郵件已發送至信箱裡", message: "請登入郵箱,通過郵箱認證", preferredStyle: .alert)
                    
                    let OkAction = UIAlertAction(title: "我知道了", style: .default, handler:{
                        (action: UIAlertAction!) -> Void in
                        let vc = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "bear")
                        self.present(vc, animated: true,completion: nil)
                    })
                    alertController.addAction(OkAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                    Auth.auth().currentUser?.sendEmailVerification { (error) in
                        
                    }
           
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = self.nameField.text!
                    changeRequest?.commitChanges(completion: nil)
                    
                    let userInfo :[String : Any] = ["uid" : user.uid,"name" : self.nameField.text!,"email" : self.emailField.text!,"type" : "L"]
                    
                    self.ref.child("Members").child(user.uid).setValue(userInfo)
                    
                    let vc = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "bear")
                    
                    self.present(vc, animated: true,completion: nil)
                    

            }
            })
        }
    }
}
