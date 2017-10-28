//
//  LoginViewController.swift
//  FJU-RENT
//
//  Created by Bomin on 2017/7/5.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        Auth.auth().addStateDidChangeListener(){auth, user in
  
            if let user = user {
                // User is signed in.
                if (user.isEmailVerified||(FBSDKAccessToken.current()) != nil) {
                    let vc = UIStoryboard(name : "Main", bundle: nil).instantiateViewController(withIdentifier: "bomin")
                    self.present(vc, animated: true,completion: nil)
                }
                else {
                print("No user is signed in.")
            }
            }
        }
        }
    @IBAction func loginPressed(_ sender: Any) {
    guard emailField.text != "" , pwField.text != "" else {return}
    Auth.auth().signIn(withEmail: emailField.text!, password: pwField.text!) { (user, error) in
        if let error = error {
            print(error.localizedDescription)
            let optionMenu = UIAlertController(title :nil,message : "帳號或密碼錯誤" ,preferredStyle:.alert)
            let cancelAction = UIAlertAction(title:"我知道了",style :.cancel,handler:nil)
            optionMenu.addAction(cancelAction)
            self.present(optionMenu,animated:true,completion:nil)
            return
        }
        if (user?.isEmailVerified)! {
            let vc = UIStoryboard(name : "Main", bundle: nil).instantiateViewController(withIdentifier: "bomin")
            self.present(vc, animated: true,completion: nil)
        }else{
            let alertController = UIAlertController(title: "信箱未認證", message: "請重新認證", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        }
        
    }
    // facebook login & put data in firebase
    @IBAction func facebookLogin(_ sender: Any) {
        let fbLoginManager = FBSDKLoginManager()
        print("logged in")
        
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            //拿到fb授權
            guard let accessToken = FBSDKAccessToken.current()
                else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                var ref = Database.database().reference()
                // guard for user id
                guard let uid = user?.uid else {
                    return
                }
                //show the email name id
                FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id,name,email"]).start(completionHandler: { (connection, result,error) in
                    if error != nil {
                        print("failed to start graph request:",error)
                        //return
                    }else{
                        //print("找到用戶：\(result)")
                        
                        //let data = result as! [String : Any]
                        let userInfo :[String : Any] = ["uid" : user!.uid,"type" : "F"]
                        ref.child("Members").child(uid).setValue(userInfo) //add type and uid into Members
                        let values: [String:Any] = result as! [String : Any]
                        let email = values["email"] as? String
                        let fullname = values["name"] as? String
                        // create a child reference - uid will let us wrap each users data in a unique user id for later reference
                        let usersReference = ref.child("Members").child(uid)
                        usersReference.updateChildValues(values){ (err, ref) -> Void in
                            // if there's an error in saving to our firebase database
                            if err != nil {
                                print(err)
                                return
                            }
                            // no error, so it means we've saved the user into our firebase database successfully
                            print("Save the user successfully into Firebase database")
                        }
                    }
                })
                // Present the main view
                if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "bomin") {
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                    self.dismiss(animated: true, completion: nil)
                }
            })
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

