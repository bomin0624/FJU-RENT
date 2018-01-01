//
//  FoodDetailViewController.swift
//  FJU-RENT
//
//  Created by iPhoneApp research center on 2017/11/19.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase

class FoodDetailViewController: UIViewController {
    @IBOutlet weak var image: UIImageView!    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var detail: UITextView!
    @IBOutlet weak var location: UILabel!
    
    var foodList:foodmodel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if foodList == nil{
            print("error")
        }else{
            
            self.name.text = foodList!.name
            self.detail.text = foodList!.detail
            self.location.text = foodList!.location
            let url = URL(string: (foodList!.foodimageurl)!)
            URLSession.shared.dataTask(with: url!, completionHandler: { data, response, error in
                if error != nil{
                    print("")
                }
                print("detail:\(data)")
                DispatchQueue.main.sync{
                    if data == nil {
                        self.image.image = #imageLiteral(resourceName: "favorite(50X50)")
                    } else {
                        self.image.image = UIImage(data: data!)
                    }
                }
            }).resume()
        }

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    
    
}
