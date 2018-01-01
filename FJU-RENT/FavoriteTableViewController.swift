//
//  FavoriteTableViewController.swift
//  FJU-RENT
//
//  Created by iPhoneApp research center on 2017/9/9.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase

class FavoriteTableViewController: UITableViewController,UIViewControllerPreviewingDelegate {
    var flag = false
    
    var list = [Model]()
    var favoriteId :String = ""
    var favoriteUid:String = ""
    
    var favoriteList = [Favorite]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: - 3d touch
        if(traitCollection.forceTouchCapability == .available){
            registerForPreviewing(with: self as! UIViewControllerPreviewingDelegate, sourceView: view)
        }
        self.loadFavorite()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "下拉以重新整理...")
        self.refreshControl?.addTarget(self, action: #selector(refreshData(_:)), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl!)
    }

    func refreshData(_ refreshControl: UIRefreshControl){
        self.favoriteList.removeAll()
        self.list.removeAll()
        self.loadFavorite()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }

    func loadFavorite(){
        if flag{
           print("load..")
        }
        
        let user = Auth.auth().currentUser
        if let user = user{
            let uid = user.uid
            
            let databaseRef = Database.database().reference()
            databaseRef.child("Favorite").child(uid).observe(DataEventType.value, with: { (snapshot) in
                
                
                self.favoriteList.removeAll()
                self.list.removeAll()
                
               
                //MARK: - Clean The Map If No List
                if snapshot.childrenCount == 0{
                    let alertController = UIAlertController(title: "暫無收藏項目", message: "", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    self.tableView.separatorColor = UIColor.white
                    self.tableView.reloadData()
                    
                }
                if snapshot.childrenCount > 0{
                    
                    for favorites in snapshot.children.allObjects as! [DataSnapshot]{
                        let favoriteObject = favorites.value as? [String: Any]
                        let favorite = Favorite()
                        
                        favorite.favoriteId = favoriteObject?["id"] as! String  //房號
                        favorite.favoriteUid = favoriteObject?["uid"] as! String //原ＰＯ
                        
                        
                        self.favoriteList.append(favorite)
                        
                        
                        
                    }
                    for favorite in self.favoriteList{
                        
                        let favoriteId = favorite.favoriteId!
                        let favoriteUid = favorite.favoriteUid!
                        
                        databaseRef.child("location").child(favoriteUid).child(favoriteId).observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            
                            let rentObject = snapshot.value as? [String: Any]
                            if self.flag{
                                print(rentObject)
                            }
                            let rentTitle = rentObject?["title"] as! String
                            let rentMoney = rentObject?["rent"] as! String
                            let rentPings = rentObject?["pings"] as! String
                            let rentId = rentObject?["id"] as! String
                            let rentUid = rentObject?["uid"] as! String
                            let rentImgStorage = rentObject?["imgStorage"] as? NSDictionary
                            let imgDict = rentImgStorage?.allValues[0] as! [String : Any]
                            let rentUniString = imgDict["imgName"] as! String
                            let rentImg = imgDict["imgUrl"] as! String
                            
                            //add
                            let rentArea = rentObject?["area"] as! String?
                            let rentAddress = rentObject?["address"] as! String?
                            let rentType = rentObject?["type"] as! String?
                            
                            var rentLikeCount = rentObject?["likeCount"] as! Int?
                            let timeStamp = rentObject?["timeStamp"] as! Int?
                            
                            let latitude = rentObject?["latitude"] as! Double?
                            let longitude = rentObject?["longitude"] as! Double?

                            if rentLikeCount == nil{
                                rentLikeCount = 0
                            }
                            let rentList = Model(title: rentTitle, money: rentMoney , pings: rentPings ,imgPath: rentImg , id: rentId , uid: rentUid , uniString: rentUniString, address: rentAddress, genre: rentType, area: rentArea, likeCount: rentLikeCount!, timeStamp: timeStamp!, latitude: latitude!, longitude: longitude!)
                            
                            self.list.append(rentList)
                            
                            self.tableView.separatorColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
                            self.tableView.reloadData()
                            
                            
                            
                            
                            
                        }) { (error) in
                            print(error.localizedDescription)
                        }
                        
                        
                    }
                    
                    
                    
                }
                
            })
            
            
        }
        if flag{
            print(list)
        }
        
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.delete){
            let rentList: Model
            rentList = list[indexPath.row]
            let user = Auth.auth().currentUser
            if let user = user{
                let uid = user.uid
                let ref = Database.database().reference()
                ref.child("Favorite").child(uid).child(rentList.id!).setValue(nil)
                ref.child("currentUser").child(uid).child(rentList.id!).child("favorite").setValue(nil)
            }
            self.tableView.beginUpdates()
            self.list.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.endUpdates()
        }
    }
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
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
        if segue.identifier == "maps" {
                let destinationController = segue.destination as! MutiMarkerViewController
                destinationController.rentList = list

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
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
}
