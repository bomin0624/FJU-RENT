//
//  SystemMessageDetailViewController.swift
//  FJU-RENT
//
//  Created by Bomin on 2017/8/28.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase

class SystemMessageDetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var messageView: UITextView!
    
    var systemMessageTitle = ""
    var systemMessage = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = systemMessageTitle
        messageView.text = systemMessage
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
