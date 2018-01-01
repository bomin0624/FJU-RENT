//
//  FavoriteTableViewController.swift
//  FJU-RENT
//
//  Created by iPhoneApp research center on 2017/9/9.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase

class CompareTableViewController: UITableViewController {
    
    var flag = false
    
    var list = [CompareModel]()
    var favoriteId :String = ""
    var favoriteUid:String = ""
    
    var favoriteList = [Favorite]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFavorite()
        
        
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
                
                
                //clean the map if no list
                if snapshot.childrenCount == 0{
                    
                    self.tableView.reloadData()
                    
                }
                if snapshot.childrenCount > 0{
                    
                    for favorites in snapshot.children.allObjects as! [DataSnapshot]{
                        let favoriteObject = favorites.value as? [String: Any]
                        let favorite = Favorite()
                        
                        favorite.favoriteId = favoriteObject?["id"] as! String  //房號
                        favorite.favoriteUid = favoriteObject?["uid"] as! String //原PO
                        
                        
                        self.favoriteList.append(favorite)
                        
                        
                        
                    }
                    for favorite in self.favoriteList{
                        
                        let favoriteId = favorite.favoriteId!
                        let favoriteUid = favorite.favoriteUid!
                        
                        
                        
                        databaseRef.child("location").child(favoriteUid).child(favoriteId).observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            
                            let rentObject = snapshot.value as? [String: Any]
                            let rentTitle = rentObject?["title"] as! String
                            let rentMoney = rentObject?["rent"] as! String
                            let rentPings = rentObject?["pings"] as! String
                            let rentId = rentObject?["id"] as! String
                            let rentUid = rentObject?["uid"] as! String
                            
                            let likeCount = rentObject?["likeCount"] as! Int
                            
                            let rentFloor = rentObject?["floor"] as! String
                            
                            //add
                            
                            let rentAddress = rentObject?["address"] as! String?
                            let rentType = rentObject?["type"] as! String?
                            let rentList = CompareModel(title: rentTitle,
                                                        money: rentMoney,
                                                        pings: rentPings,
                                                        id: rentId,
                                                        uid: rentUid,
                                                        address: rentAddress,
                                                        likeCount:likeCount,
                                                        genre: rentType,
                                                        floor:rentFloor
                            )
                            
                            self.list.append(rentList)
                            
                            
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "compareCell", for: indexPath) as! CompareTableViewCell
        let rentList: CompareModel
        rentList = list[indexPath.row]
        
        cell.addressLabel.text = rentList.address
        cell.moneyLabel.text = rentList.money
        cell.pingLabel.text = rentList.pings
        cell.titleLabel.text = rentList.title
        cell.typeLabel.text = rentList.genre
        cell.floorLabel.text = rentList.floor
        let likeCount = String(rentList.likeCount)
        cell.likeCount.text = likeCount
        return cell
        
    }
    
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if segue.identifier == "detail" {
            if let indexPath = tableView.indexPathForSelectedRow{
                let rentList: CompareModel
                rentList = list[indexPath.row]
               
                let destinationController = segue.destination as! DetailTableViewController
                destinationController.id = rentList.id!
                destinationController.uid = rentList.uid!
               
            }
            
                      
        }
        
        
    }
    
    
}

    
    

