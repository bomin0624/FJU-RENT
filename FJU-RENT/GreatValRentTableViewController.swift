//
//  GreatValRentTableViewController.swift
//  FJU-RENT
//
//  Created by Bomin on 2017/10/24.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase

class GreatValRentTableViewController: UITableViewController {
    var list = [Model]()
    var rankingList = [Int]()
    var keyList = [String]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        Database.database().reference().child("location").observeSingleEvent(of: .value, with: { (snapshot) in
            
            
            if snapshot.childrenCount > 0{
                for rents in snapshot.children.allObjects as! [DataSnapshot]{
                    let rentKey = rents.key as! String
                    self.keyList.append(rentKey)
                }
                for key in self.keyList{
                    let databaseRef = Database.database().reference().child("location").child(key)
                    databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if snapshot.childrenCount > 0{
                            
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
                                
                                var rentLikeCount = rentObject?["likeCount"] as! Int?
                                let timeStamp = rentObject?["timeStamp"] as! Int?

                                if rentLikeCount == nil{
                                    rentLikeCount = 0
                                }
                                let latitude = rentObject?["latitude"] as! Double?
                                let longitude = rentObject?["longitude"] as! Double?
                                
                                let rentList = Model(title: rentTitle, money: rentMoney , pings: rentPings ,imgPath: rentImg , id: rentId , uid: rentUid , uniString: rentUniString, address: rentAddress, genre: rentType, area: rentArea, likeCount: rentLikeCount!, timeStamp: timeStamp!, latitude: latitude!, longitude: longitude!)
                                
                               let values = Int(rentMoney)
                                
                                if values! >= 5000 && values! <= 7000 {
                                    self.list.append(rentList) //存取陣列
                                }
                            }
                            
                            let keyLength = self.keyList.count
                            let lastKeyValue = self.keyList[keyLength-1]
                            if key == lastKeyValue {
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    
                                }
                            }
                        }
                    })
                }
            }
            
        })
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HomeTableViewCell
        
        let rent: Model
        rent = list[indexPath.row]
        cell.nameLabel?.text = rent.title
        cell.addressLabel?.text = rent.address
        cell.moneyLabel?.text = rent.money
        
        
        
        if let rentImageUrl = rent.imgPath{
            let url = URL(string: rentImageUrl)
            URLSession.shared.dataTask(with:url!,completionHandler:{(data,response,error) in
                if error != nil{
                    print(error)
                    return
                }
                
                DispatchQueue.main.async {
                    let sortedArray = self.rankingList.sorted(by: >)
                    cell.rentImage.image = UIImage(data:data!)
                }
                
            }).resume()
            
        }
        return cell
    }
    //MARK: - Prepare For Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "homedetail" {
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if list.count > 5{
            return 5
        }else{
            return list.count
        }
    }
    

}
