//
//  ViewPhoto.swift
//  FJU-RENT
//
//  Created by WZH on 2017/12/11.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit

class ViewPhoto: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?
    var imageArray : [UIImage]?
    var index : Int?
    
    var id = ""
    var uid = ""
    
    @IBAction func deleteButton(_ sender: Any) {
        let alert = UIAlertController(title: "Delete Image", message: "Are you sure you want to delete this image?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(alertAction)in
            
            if self.index! > 0{
                self.imageView.image = self.imageArray?[self.index!-1]
                self.imageArray?.remove(at: self.index!)
                self.index! = self.index!-1
                print(self.index)
            }else if (self.imageArray?.count)! > 1{
                self.imageArray?.remove(at: 0)
                self.imageView.image = self.imageArray?[0]
                
                
                print(self.index)
            }else{
                
                let alertController = UIAlertController(title: "刪除失敗", message: "請至少保留一張圖片", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(alertAction)in
            //Do not delete photo
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        if let navController = self.navigationController {
            navController.popToRootViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        print(self.index!)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        
        
        
        if segue.identifier == "back" {
            let destination = segue.destination as! CollectionImageViewController
            
            destination.id = id
            destination.uid = uid

            destination.imageArray = imageArray
            
        }
        
        
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
