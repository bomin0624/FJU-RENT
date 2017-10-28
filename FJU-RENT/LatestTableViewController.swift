//
//  LatestTableViewController.swift
//  FJU-RENT
//
//  Created by iPhoneApp research center on 2017/10/21.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase

class LatestTableViewController: UITableViewController {
    var list = [Model]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                        if rentLikeCount == nil{
                            rentLikeCount = 0
                        }
                        let  rentList = Model(title: rentTitle, money: rentMoney , pings: rentPings ,imgPath: rentImg , id: rentId , uid: rentUid , uniString: rentUniString, address: rentAddress, genre: rentType, area: rentArea, likeCount: rentLikeCount!)
                        
                        self.list.insert(rentList, at: 0)
                        
                    }
                    
                    self.tableView.reloadData()
                    
                    
                }
            })
            
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "rentalCell", for: indexPath) as! DisplayTableViewCell
        let rentList: Model
        rentList = list[indexPath.row]
        cell.headField.text = rentList.title
        cell.moneyField.text = rentList.money
        cell.pingField.text = rentList.pings
        //cell.displayView.contentMode = .scaleAspectFit
        if let imgUrl = rentList.imgPath {
            let url = URL(string: imgUrl)
            URLSession.shared.dataTask(with: url!, completionHandler: { data, response, error in
                if error != nil{
                    print("")
                }
                
                DispatchQueue.main.sync {
                    if data == nil {
                        cell.displayView.image = #imageLiteral(resourceName: "favorite(50X50)")
                    } else {
                        cell.displayView.image = UIImage(data: data!)
                    }
                    
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
