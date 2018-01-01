//
//  FoodTableViewController.swift
//  FJU-RENT
//
//  Created by iPhoneApp research center on 2017/11/19.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase


class FoodTableViewController: UITableViewController,UIViewControllerPreviewingDelegate {
    
    var ref : DatabaseReference!
    var list = [foodmodel]()
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        //MARK: - 3d touch
        if(traitCollection.forceTouchCapability == .available){
            registerForPreviewing(with: self as! UIViewControllerPreviewingDelegate, sourceView: view)
        }
        
        
        
        
        Database.database().reference().child("Food").observe(.childAdded,with: {(snapshot) in
            
            let name  = snapshot.childSnapshot(forPath: "name").value as? String
            
            let image = snapshot.childSnapshot(forPath: "url").value as? String
            
            let detail = snapshot.childSnapshot(forPath: "detail").value as? String
            
            let location = snapshot.childSnapshot(forPath: "location").value as? String
            
            let foodList = foodmodel(name: name , foodimageurl: image, detail: detail, location: location)
            self.list.append(foodList)
            
            self.tableView.reloadData()
            
            
        })
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FoodTableViewCell
        
        cell.FoodLabel.text = list[indexPath.row].name
        
        if let imageUrl = list[indexPath.row].foodimageurl{
            let url = URL(string: imageUrl)
            URLSession.shared.dataTask(with:url!,completionHandler:{(data,response,error) in
                if error != nil{
                    print(error)
                    return
                }
                
                DispatchQueue.main.async {
                    cell.foodimage.image = UIImage(data:data!)
                }
                
            }).resume()
            
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! FoodDetailViewController
                destinationController.foodList = list[indexPath.row]
            }
        }
    }
    
    
    // MARK: - Peek and Pop 3d touch
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRow(at: location) else {
            return nil
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return nil
        }
        
        guard let FoodDetailTableViewController = storyboard?.instantiateViewController(withIdentifier: "FoodDetailViewController") as? FoodDetailViewController else {
            return nil
        }
        let selectedfood = list[indexPath.row]
        FoodDetailTableViewController.foodList = selectedfood
        
        previewingContext.sourceRect = cell.frame
        
        return FoodDetailTableViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }

    
    
    
}
