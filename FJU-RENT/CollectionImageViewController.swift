//
//  CollectionImageViewController.swift
//  FJU-RENT
//
//  Created by WZH on 2017/12/11.
//  Copyright © 2017年 Bomin. All rights reserved.
//

//
//  CollectionImageViewController.swift
//  imageScroll
//
//  Created by WZH on 2017/12/10.
//  Copyright © 2017年 WZH. All rights reserved.
//

import UIKit

class CollectionImageViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    var id = ""
    var uid = ""
    

    var imageArray : [UIImage]?
    
    var orginImageArray : [UIImage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orginImageArray = imageArray
        print("id:\(id)")
        print("uid:\(uid)")
        
        
        let itemSize = UIScreen.main.bounds.width/3 - 2
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        
        myCollectionView.collectionViewLayout = layout
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Number of views
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray!.count
    }
    
    //Populate view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! myCell
        cell.myImageView.image = imageArray?[indexPath.row]
        //UIImage(named: array[indexPath.row] + ".JPG")
        return cell
    }
    
    
    @IBAction func __presentPhotoViewController(_ sender: Any) {
        //获得控制器
        let viewController : RITLPhotoNavigationViewController = RITLPhotoNavigationViewController()
        
        //设置viewModel属性
        let viewModel = viewController.viewModel
        
        // 获得图片
        viewModel.completeUsingImage = {(images) in
            
            //self.imageArray = images
            for image in images{
                self.imageArray?.append(image)
            }
            self.myCollectionView.reloadData()
        }
        
        // 获得资源的data数据
        viewModel.completeUsingData = {(datas) in
            
            //coding for data ex: uploading..
            print("data = \(datas)")
        }
        
        
        
        self.present(viewController, animated: true) {}
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "viewPhoto"){
            if let destination:ViewPhoto = segue.destination as? ViewPhoto{
                if let cell = sender as? UICollectionViewCell{
                    if let indexPath: IndexPath = myCollectionView.indexPath(for: cell){
                        destination.image = imageArray?[indexPath.item]
                        destination.index = indexPath.item
                        
                    }
                    destination.id = id
                    destination.uid = uid
                    
                    destination.imageArray = imageArray
                }
            }
        }
        if segue.identifier == "done" {
            let destination = segue.destination as! EditRentalTableViewController
            destination.id = id
            destination.uid = uid
            
            destination.imageArray = imageArray!
            
        }
        if segue.identifier == "cancel" {
            let destination = segue.destination as! EditRentalTableViewController
            destination.id = id
            destination.uid = uid
            
            destination.imageArray = orginImageArray!
            
        }
    }
    
    
    
}
