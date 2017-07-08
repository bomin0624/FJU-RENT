//
//  SignupViewController.swift
//  FJU-RENT
//
//  Created by Bomin on 2017/7/5.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignupViewController: UIViewController {

@IBOutlet weak var nameField: UITextField!
@IBOutlet weak var emailField: UITextField!
@IBOutlet weak var password: UITextField!
@IBOutlet weak var comPwField: UITextField!
@IBOutlet weak var nextBtn: UIButton!
    var userStorage: StorageReference!
    var ref :DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        guard nameField.text != "", emailField.text != "", password.text != "", comPwField.text != "" else { return}
        if password.text == comPwField.text {
            Auth.auth().createUser(withEmail: emailField.text!, password: password.text!, completion: { (user, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                if let user = user {
                    
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.displayName = self.nameField.text!
                    changeRequest?.commitChanges(completion: nil)
                    
                    let userInfo :[String : Any] = ["uid" : user.uid,"full name" : self.nameField.text!]
                    
                   self.ref.child("users").child(user.uid).setValue(userInfo)
                   
                    let vc = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "usersVC")
                    
                    self.present(vc, animated: true,completion: nil)
                    
                }
            
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
