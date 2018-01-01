//
//  LatestTableViewController.swift
//  FJU-RENT
//
//  Created by iPhoneApp research center on 2017/10/21.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase

class LatestTableViewController: UITableViewController,UIViewControllerPreviewingDelegate {
    var list = [Model]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - 3d touch
        if(traitCollection.forceTouchCapability == .available){
            registerForPreviewing(with: self as! UIViewControllerPreviewingDelegate, sourceView: view)
        }
        self.LoadFromDatbase()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "下拉以重新整理...")
        self.refreshControl?.addTarget(self, action: #selector(refreshData(_:)), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl!)
        
    }
    func LoadFromDatbase(){
        
        let user = Auth.auth().currentUser
        
        if let user = user{
            let uid = user.uid
            Database.database().reference().child("location").observe(.childAdded, with: { (snapshot) in
                
                
                for child in snapshot.children.allObjects as! [DataSnapshot]{
                    if snapshot.childrenCount > 0{
                        let rentObject = child.value as? [String:Any]
                        let rentTitle = rentObject?["title"] as! String
                        let rentMoney = rentObject?["rent"] as! String
                        let rentPings = rentObject?["pings"] as! String
                        let rentId = rentObject?["id"] as! String
                        let rentUid = rentObject?["uid"] as! String
                        let rentImgStorage = rentObject?["imgStorage"] as? NSDictionary
                        let imgDict = rentImgStorage?.allValues[0] as! [String : Any]
                        let rentUniString = imgDict["imgName"] as! String
                        let rentImg = imgDict["imgUrl"] as! String
                        
                        var rentLikeCount = rentObject?["likeCount"] as! Int?
                        //add
                        let rentArea = rentObject?["area"] as! String?
                        let rentAddress = rentObject?["address"] as! String?
                        let rentType = rentObject?["type"] as! String?
                        let timeStamp = rentObject?["timeStamp"] as! Int?
                        if rentLikeCount == nil{
                            rentLikeCount = 0
                        }
                        let latitude = rentObject?["latitude"] as! Double?
                        let longitude = rentObject?["longitude"] as! Double?
                        let  rentList = Model(title: rentTitle, money: rentMoney , pings: rentPings ,imgPath: rentImg , id: rentId , uid: rentUid , uniString: rentUniString, address: rentAddress, genre: rentType, area: rentArea, likeCount: rentLikeCount!, timeStamp: timeStamp!, latitude: latitude!, longitude: longitude!)
                        
                        self.list.append(rentList)
                        self.list = self.list.sorted(by: {$0.timeStamp > $1.timeStamp})
                        
                    }
                    
                    self.tableView.reloadData()
                    
                    
                }
            })
        }
    }
    func refreshData(_ refreshControl: UIRefreshControl){
        self.list.removeAll()
        self.LoadFromDatbase()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "rentalCell", for: indexPath) as! RentTableViewCell
        let rentList: Model
        rentList = list[indexPath.row]
        cell.nameLabel?.text = rentList.title
        cell.addressLabel?.text = rentList.address
        cell.moneyLabel?.text = rentList.money
        
        if let rentImageUrl = rentList.imgPath{
            let url = URL(string: rentImageUrl)
            URLSession.shared.dataTask(with:url!,completionHandler:{(data,response,error) in
                if error != nil{
                    print(error)
                    return
                }
                
                DispatchQueue.main.async {
                    cell.rentImage.image = UIImage(data:data!)
                }
                
            }).resume()
            
        }
        return cell
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "detail" {
           
            if let indexPath = tableView.indexPathForSelectedRow{
                let rentList: Model
                rentList = list[indexPath.row]
                let destinationController = segue.destination as! DetailTableViewController
                destinationController.id = rentList.id!
                destinationController.uid = rentList.uid!
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Peek and Pop 3d touch
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRow(at: location) else {
            return nil
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return nil
        }
        
        guard let DetailTableViewController = storyboard?.instantiateViewController(withIdentifier: "DetailTableViewController") as? DetailTableViewController else {
            return nil
        }
        
        let selectedFilteredRent = list[indexPath.row]
        
        DetailTableViewController.id = selectedFilteredRent.id!
        DetailTableViewController.uid = selectedFilteredRent.uid!
        DetailTableViewController.preferredContentSize = CGSize(width: 0.0, height: 450.0)
        previewingContext.sourceRect = cell.frame
        
        return DetailTableViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit:
        UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
}
