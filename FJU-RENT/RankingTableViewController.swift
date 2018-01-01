//
//  RankingTableViewController.swift
//  FJU-RENT
//
//  Created by Bomin on 2017/10/21.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase

class RankingTableViewController: UITableViewController,UIViewControllerPreviewingDelegate {
    
    var list = [Model]()
    var rankingList = [Int]()
    var keyList = [String]()

    override func viewDidLoad() {
       
        //MARK: - 3d touch
        if(traitCollection.forceTouchCapability == .available){
            registerForPreviewing(with: self as! UIViewControllerPreviewingDelegate, sourceView: view)
        }
        
        super.viewDidLoad()
        self.LoadFromDatabase()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "下拉以重新整理...")
        self.refreshControl?.addTarget(self, action: #selector(refreshData(_:)), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl!)
    }
    
    
    
    
    func LoadFromDatabase(){
        
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
                                
                                
                                self.list.append(rentList) //存取陣列
                                self.list = self.list.sorted(by: { $0.likeCount > $1.likeCount })
                            }
                            //print(self.rankingList)
                            
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
    
    func refreshData(_ refreshControl: UIRefreshControl){
        self.keyList.removeAll()
        self.rankingList.removeAll()
        self.list.removeAll()
        self.LoadFromDatabase()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RankingTableViewCell
        
        let rent: Model
        rent = list[indexPath.row]
        cell.nameLabel?.text = rent.title
        cell.addressLabel?.text = rent.address
        cell.moneyLabel?.text = rent.money
        cell.rank.text = "\(indexPath.row+1)"
        
        
        
        
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
    
    //MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "rankdetail" {
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
    
        if list.count > 10 {
            return 10
        }else {
            return list.count
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
