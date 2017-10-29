//
//  HomeViewController.swift
//  FJU-RENT
//
//  Created by Bomin on 2017/10/29.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var searchLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(searchTapped(_:)))
        tap.numberOfTapsRequired = 1
        searchLabel.addGestureRecognizer(tap)
        searchLabel.isUserInteractionEnabled = true
    }
    func searchTapped(_ sender: UITapGestureRecognizer){
        let vc = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "search") as! SearchSelectViewController
        self.navigationController?.pushViewController(vc, animated: true)
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
