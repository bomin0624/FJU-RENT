//
//  DetailTableViewController.swift
//  FJU-RENT
//
//  Created by Gelzone on 2017/8/26.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit

class DetailTableViewController: UITableViewController {

    @IBOutlet weak var detailImg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var rentLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var pingsLabel: UILabel!
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var transView: UITextView!
    @IBOutlet weak var detailView: UITextView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var edit: UIBarButtonItem!
    @IBOutlet weak var depositLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    
    var id = ""
    var uid = ""
    //var uniqueString = ""
    //var imgUrl = ""
    //var likeCount
    var likeCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        if let user = user{
            let userId = user.uid
            if userId == uid {
                self.edit.isEnabled = true
            }else {
                self.edit.image = nil
                self.edit.isEnabled = false
            }
        }
        let databaseRef = Database.database().reference().child("location").child(uid).child(id)
        databaseRef.observe(DataEventType.value, with: { (snapshot) in
            if snapshot.childrenCount > 0{
                let detailObject = snapshot.value as? [String: Any]
                //replace
 //               let detailImage = detailObject?["img"] as! String
                let detailImgStorage = detailObject?["imgStorage"] as? NSDictionary
                let imgDict = detailImgStorage?.allValues[0] as! [String : Any]
                let detailImage = imgDict["imgUrl"] as! String
                
                let detailTitle = detailObject?["title"] as! String?
                let detailArea = detailObject?["area"] as! String?
                let detailAddress = detailObject?["address"] as! String?
                let detailRent = detailObject?["rent"] as! String?
                let detailUser = detailObject?["user"] as! String?
                let detailPhone = detailObject?["phone"] as! String?
                let detailPings = detailObject?["pings"] as! String?
                let detailFloor = detailObject?["floor"] as! String?
                let detailType = detailObject?["type"] as! String?
                let detailTrans = detailObject?["trans"] as! String?
                let detailDetail = detailObject?["detail"] as! String?
                let detailDeposit = detailObject?["deposit"] as! String?                
                var rentLikeCount = detailObject?["likeCount"] as! Int?
                if rentLikeCount == nil{
                    rentLikeCount = 0
                }
                self.likeCount = rentLikeCount!
                
                
                self.titleLabel.text = detailTitle
                self.areaLabel.text = detailArea
                self.addressLabel.text = detailAddress
                self.rentLabel.text = detailRent
                self.userLabel.text = detailUser
                self.phoneLabel.text = detailPhone
                self.pingsLabel.text = detailPings
                self.floorLabel.text = detailFloor
                self.typeLabel.text = detailType
                self.transView.text = detailTrans
                self.detailView.text = detailDetail
                self.depositLabel.text = detailDeposit
                self.detailImg.contentMode = .scaleAspectFit
                self.likeCountLabel.text = "\(rentLikeCount)"
                
                let url = URL(string: detailImage)
                print("detail:\(detailTitle):\(detailImage)")
                URLSession.shared.dataTask(with: url!, completionHandler: { data, response, error in
                    if error != nil{
                        print("")
                    }
                    print("detail:\(data)")
                    DispatchQueue.main.sync{
                        //self.detailImg.image = UIImage(data: data!)
                        if data == nil {
                            self.detailImg.image = #imageLiteral(resourceName: "favorite(50X50)")
                        } else {
                            self.detailImg.image = UIImage(data: data!)
                        }
                    }
                }).resume()
//                顯示讚數
                self.likeCountLabel.text = "讚:\(self.likeCount)"
                self.tableView.reloadData()
            }
        })
//        likes裡是空的就顯示dislike圖片
        let currentUid = Auth.auth().currentUser?.uid
            let likeRef = Database.database().reference().child("currentUser").child(currentUid!).child(id).child("likes")
            likeRef.observe(DataEventType.value, with: { (snapshot) in
                if let likeOrNot = snapshot.value as? NSNull{
                    print(likeOrNot)
                    self.likeImageView.image = UIImage(named: "dislike")
                }else{
                    self.likeImageView.image = UIImage(named: "like")
                }
            })
//        在圖片上增加增加likeTapped()的動作
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped(_:)))
        tap.numberOfTapsRequired = 1
        likeImageView.addGestureRecognizer(tap)
        likeImageView.isUserInteractionEnabled = true
}
//    點擊圖片後跑的動作
    func likeTapped(_ sender: UITapGestureRecognizer){
        let currentUid = Auth.auth().currentUser?.uid
            let likeRef = Database.database().reference().child("currentUser").child(currentUid!).child(id).child("likes")
            likeRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let likeOrNot = snapshot.value as? NSNull{
                    print(likeOrNot)
                    self.likeImageView.image = UIImage(named: "dislike")
                    self.addSubtractLike(addLike: true)
                    likeRef.setValue(true)
                }else{
                    self.likeImageView.image = UIImage(named: "like")
                    self.addSubtractLike(addLike: false)
                    likeRef.setValue(nil)
                }
            })
    }
//    讚數總數變化並存入firebase
    func addSubtractLike(addLike: Bool) {
        if addLike == true{
            likeCount = likeCount + 1
        }else{
            likeCount = likeCount - 1
        }
        let likeTotalRef = Database.database().reference().child("location").child(uid).child(id)
        likeTotalRef.child("likeCount").setValue(likeCount)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addFavorite(_ sender: Any) {
        
        let currentUser = Auth.auth().currentUser?.uid
        
        let rentalData: DatabaseReference! = Database.database().reference().child("Favorite").child(currentUser!)
        
        // detaRef.child("Favorite").child(favoriteUserId).child(favoriteId)
        /*   let landlord = ["userId": currentUser, "id": id, "title": self.titleLabel.text! as! String, "phone": self.phoneLabel.text! as! String, "rent": self.rentLabel!.text! as! String, "pings": self.pingsLabel!.text! as! String, "type": self.typeLabel!.text! as! String, "area": self.areaLabel!.text! as! String, "address": self.addressLabel.text! as! String, "user": self.userLabel!.text! as! String, "floor": self.floorLabel!.text!, "trans": self.transView.text! as! String, "detail": self.detailView.text! as! String, "img": imagePath,"uid": uid, "imgStorage": uniqueString]*/
        let favorites = ["userId": currentUser, "id" : id, "uid": uid]
        
        rentalData.child(id).setValue(favorites)
    }
//分享功能
    @IBAction func sharePress(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems:["來自[FJU-RENT]"], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "chat" {
            let destinationController = segue.destination as! ChatViewController
            destinationController.id = id
            destinationController.uid = uid
        }
        //add new segue
        if segue.identifier == "maps" {
            let destinationController = segue.destination as! DetailGoogleMapViewController
            destinationController.address = self.addressLabel.text!
            //destinationController.rentTitle = self.titleLabel.text!
        }
        if segue.identifier == "edit" {
            let destination = segue.destination as! EditRentalTableViewController
            destination.id = id
            destination.uid = uid
           // destination.imgString = uniqueString
           // destination.imgUrl = imgUrl
        }
    }
    
    
}
