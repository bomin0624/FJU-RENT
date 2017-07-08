//
//  LoginViewController.swift
//  FJU-RENT
//
//  Created by Bomin on 2017/7/5.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func loginPressed(_ sender: Any) {
        guard emailField.text != "" , pwField.text != "" else {return}
    Auth.auth().signIn(withEmail: emailField.text!, password: pwField.text!) { (user, error) in
        if let error = error {
            print(error.localizedDescription)
        }
        if let user = user {
            let vc = UIStoryboard(name : "Main", bundle: nil).instantiateViewController(withIdentifier: "usersVC")
            self.present(vc, animated: true,completion: nil)
        }
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
