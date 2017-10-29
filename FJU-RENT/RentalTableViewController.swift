//
//  RentalTableViewController.swift
//  FJU-RENT
//
//  Created by Gelzone on 2017/8/23.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class RentalTableViewController: UITableViewController {
    
    var list = [Model]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        if let user = user{
            let uid = user.uid
            
        let databaseRef = Database.database().reference().child("location").child(uid)
        databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
         
            //.observe(DataEventType.value, with: { (snapshot) in
            if snapshot.childrenCount > 0{
                self.list.removeAll()
                for rents in snapshot.children.allObjects as! [DataSnapshot]{
                    let rentObject = rents.value as? [String: Any]
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
                    let rentLikeCount = rentObject?["likeCount"] as! Int?
                    let timeStamp = rentObject?["timeStamp"] as! Int?

                    
                    //選取所有
                    //for img in rentImgStorage {
                    //    print(img.key)
                    //    print(img.value)
                    //    let imgDict = img.value as! [String:Any]
                    //    let rentUniString = imgDict["imgName"] as! String
                        print(rentUniString)
                    //}
                    
                    
                    //顯示第一張
                    //let rentImgAutoId = rentImgStorage.allKeys[0]
                    //print(rentImgAutoId)
                    //let imgDict = rentImgStorage.allValues[0] as! [String : Any]
                    //let rentUniString = imgDict["imgName"] as! String
                    //let rentImg = imgDict["imgUrl"] as! String
                    //print(rentUniString)
                    
                    let rentList = Model(title: rentTitle, money: rentMoney , pings: rentPings ,imgPath: rentImg , id: rentId , uid: rentUid , uniString: rentUniString, address: rentAddress, genre: rentType, area: rentArea, likeCount: rentLikeCount!, timeStamp: timeStamp!)
                    
                    self.list.append(rentList)
            }
                self.tableView.reloadData()
                
            }
        })
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
        
        
        
        //   print("\(rent.title):\(rent.imgPath)")
        
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
        let alertController = UIAlertController(title: "確認刪除此筆資料嗎?", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "刪除", style: .destructive, handler:{
            (action: UIAlertAction!) -> Void in
            if(editingStyle == UITableViewCellEditingStyle.delete){
                let rentList: Model
                rentList = self.list[indexPath.row]
                let user = Auth.auth().currentUser
                if let user = user{
                    let uid = user.uid
                    let imgStorage = Storage.storage().reference().child("addRental").child(uid).child("\(rentList.uniString!).png")
                    imgStorage.delete(completion: {(error) in
                        if error != nil{
                            print("error")
                        }
                    })
                    let detaRef = Database.database().reference()
                    detaRef.child("location").child(uid).child(rentList.id!).setValue(nil)
                    
                    detaRef.child("Favorite").observe(.childAdded, with: {(snapshot) in
                        
                        for child in snapshot.children.allObjects as! [DataSnapshot]{
                            
                            if snapshot.childrenCount > 0{
                                let childObject = child.value as? [String: Any]
                                let favoriteUid = childObject?["uid"] as! String
                                let favoriteId = childObject?["id"] as! String
                                let favoriteUserId = childObject?["userId"] as! String
                                
                                
                                if favoriteUid == uid && favoriteId == rentList.id!{
                                    detaRef.child("Favorite").child(favoriteUserId).child(favoriteId).setValue(nil)
                                }
                            }
                        }
                        
                    })

                }
                self.tableView.beginUpdates()
                self.list.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.tableView.endUpdates()
            }
        })
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "刪除"
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "detail" {
            if let indexPath = tableView.indexPathForSelectedRow{
                let rentList: Model
                rentList = list[indexPath.row]
                let destinationController = segue.destination as! DetailTableViewController
                destinationController.id = rentList.id!
                destinationController.uid = rentList.uid!
                
                destinationController.likeCount = rentList.likeCount
                //destinationController.uniqueString = rentList.uniString!
                //destinationController.imgUrl = rentList.imgPath!
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
