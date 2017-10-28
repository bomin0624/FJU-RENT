//
//  ContainerViewController.swift
//  FJU-RENT
//
//  Created by Bomin on 2017/7/24.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            firstView.isHidden = false
            secondView.isHidden = true
        case 1:
            firstView.isHidden = true
            secondView.isHidden = false
        default:
            break;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstView.isHidden = false
        secondView.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


