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
    var flag = true
    var list = [Model]()
    @IBOutlet weak var favoriteBarButton: UIBarButtonItem!

   
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
    var likeCount = 0
    
    var pageControl: UIPageControl!

    var imageArray = [UIImage]()
    var myScrollView: UIScrollView!
    var fullSize :CGSize! = UIScreen.main.bounds.size
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.myScrollView = UIScrollView()
        
        // 設置尺寸 也就是可見視圖範圍
        self.myScrollView.frame = CGRect(x: 75, y: 0, width: self.fullSize.width-150, height: 120)
        
        // 實際視圖範圍
        self.myScrollView.contentSize = CGSize(width: Int(self.fullSize.width-100) * self.imageArray.count, height: 120)
        
        // 是否顯示滑動條
        self.myScrollView.showsHorizontalScrollIndicator = false
        self.myScrollView.showsVerticalScrollIndicator = false
        
        // 滑動超過範圍時是否使用彈回效果
        self.myScrollView.bounces = true
        
        // 設置委任對象
        self.myScrollView.delegate = self
        
        // 以一頁為單位滑動
        self.myScrollView.isPagingEnabled = true
        
        // 加入到畫面中
        self.view.addSubview(self.myScrollView)
        
        
        // 建立 UIPageControl 設置位置及尺寸
        self.pageControl = UIPageControl(frame: CGRect(x: 0, y: 0, width: self.fullSize.width * 0.85, height: 50))
        self.pageControl.center = CGPoint(x: self.fullSize.width * 0.5, y: self.fullSize.height * 0.15)
        
        // 有幾頁 就是有幾個點點
        self.pageControl.numberOfPages = self.imageArray.count
        
        // 起始預設的頁數
        self.pageControl.currentPage = 0
        
        // 目前所在頁數的點點顏色
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        
        // 其餘頁數的點點顏色
        self.pageControl.pageIndicatorTintColor = UIColor.white
        
        // 增加一個值改變時的事件
        self.pageControl.addTarget(self, action: #selector(DetailTableViewController.pageChanged), for: .valueChanged)
        
        // 加入到基底的視圖中 (不是加到 UIScrollView 裡)
        // 因為比較後面加入 所以會蓋在 UIScrollView 上面
        self.view.addSubview(self.pageControl)
        
        
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
        databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
            //.observe(DataEventType.value, with: { (snapshot) in
            if snapshot.childrenCount > 0{
                let detailObject = snapshot.value as? [String: Any]
                
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
                
                let detailImgStorage = detailObject?["imgStorage"] as? NSDictionary
                if self.flag{
                    print("detailImgStorage:\(detailImgStorage?.allValues.count)")
                }
                
                let imgNumber = detailImgStorage?.allValues.count as! Int
                for i in 0..<imgNumber{
                    let imgDict = detailImgStorage?.allValues[i] as! [String : Any]
                    let detailImage = imgDict["imgUrl"] as! String
                    let url = URL(string: detailImage)
                    
                    
                    URLSession.shared.dataTask(with: url!, completionHandler: { data, response, error in
                        if error != nil{
                            print("error")
                        }
                        if self.flag {
                            print("detail:\(data)")
                        }
                        
                      
                        self.imageArray.append(UIImage(data: data!)!)
                       
                        
                        
                        
                        DispatchQueue.main.sync{
                            if self.imageArray.count == imgNumber  {
                                // 建立 UIScrollView
                               
                                // 實際視圖範圍
                                self.myScrollView.contentSize = CGSize(width: Int(self.fullSize.width-100) * self.imageArray.count, height: 120)
                                
                                    // 有幾頁 就是有幾個點點
                                self.pageControl.numberOfPages = self.imageArray.count
                                
                                for i in 0..<self.imageArray.count{
                                    
                                    let imageView = UIImageView()
                                    imageView.image = self.imageArray[i]
                                    let xPosition = self.myScrollView.frame.width * CGFloat(i)
                                    
                                    imageView.frame = CGRect.init(x: xPosition, y: 0, width: self.myScrollView.frame.width, height: self.myScrollView.frame.height)
                                    
                                    self.myScrollView.contentSize.width = self.myScrollView.frame.width * CGFloat(i + 1)
                                    self.myScrollView.addSubview(imageView)
                                }
                                
                            }
                            
                            

                            
                            
                        }
                    }).resume()
                    
                    
                    
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
                //self.myScrollView.contentMode = .scaleAspectFit
                
                self.likeCountLabel.text = "讚:\(self.likeCount)"
                
                
                self.tableView.reloadData()
            }
        })
        
        //likes裡是空的就顯示dislike圖片
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
        
        //MARK: - Favorite Image
        let favoriteRef = Database.database().reference().child("currentUser").child(currentUid!).child(id).child("favorite")
        favoriteRef.observe(DataEventType.value, with: {(snapshot) in
            if let likeOrNot = snapshot.value as? NSNull{
                print(likeOrNot)
                self.favoriteBarButton.image = UIImage(named: "favorite(50X50)")
            }else{
                self.favoriteBarButton.image = UIImage(named: "filledheart")
            }
        })
        //MARK: - 在圖片上增加增加likeTapped()的動作
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped(_:)))
        tap.numberOfTapsRequired = 1
        likeImageView.addGestureRecognizer(tap)
        likeImageView.isUserInteractionEnabled = true
}
    //MARK: - 點擊圖片後跑的動作
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
    
    //MARK: - 讚數總數變化並存入firebase
    func addSubtractLike(addLike: Bool) {
        if addLike == true{
            likeCount = likeCount + 1
            self.likeCountLabel.text = "讚:\(self.likeCount)"
        }else{
            likeCount = likeCount - 1
            self.likeCountLabel.text = "讚:\(self.likeCount)"
        }
        let likeTotalRef = Database.database().reference().child("location").child(uid).child(id)
        likeTotalRef.child("likeCount").setValue(likeCount)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func addFavorite(_ sender: Any) {
        
        let currentUser = Auth.auth().currentUser?.uid
        
        let favoriteRef = Database.database().reference().child("currentUser").child(currentUser!).child(id).child("favorite")
        favoriteRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let likeOrNot = snapshot.value as? NSNull{
                print(likeOrNot)
                self.favoriteBarButton.image = UIImage(named: "favorite(50X50)")
                let rentalData: DatabaseReference! = Database.database().reference().child("Favorite").child(currentUser!)
                let favorites = ["userId": currentUser, "id" : self.id, "uid": self.uid]
                rentalData.child(self.id).setValue(favorites)
                favoriteRef.setValue(true)
            }else{
                self.favoriteBarButton.image = UIImage(named: "filledheart")
                let ref = Database.database().reference()
                ref.child("Favorite").child(currentUser!).child(self.id).setValue(nil)
                favoriteRef.setValue(nil)
            }
        })
    }
    //MARK: - Share Press
    @IBAction func sharePress(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems: [], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    // 滑動結束時
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 左右滑動到新頁時 更新 UIPageControl 顯示的頁數
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = page
    }
 
    
    // 點擊點點換頁
    func pageChanged(_ sender: UIPageControl) {
        // 依照目前圓點在的頁數算出位置
        var frame = myScrollView.frame
        frame.origin.x = frame.size.width * CGFloat(sender.currentPage)
        frame.origin.y = 0
        
        // 再將 UIScrollView 滑動到該點
        myScrollView.scrollRectToVisible(frame, animated:true)
    }

    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "chat" {
            let destinationController = segue.destination as! ChatViewController
            destinationController.id = id
            destinationController.uid = uid
        }
        
        //MARK: - Add New Segue
        if segue.identifier == "maps" {
            let destinationController = segue.destination as! DetailGoogleMapViewController
            destinationController.address = self.addressLabel.text!
        }
        if segue.identifier == "edit" {
            let destination = segue.destination as! EditRentalTableViewController
            destination.id = id
            destination.uid = uid
            
            destination.imageArray = imageArray
        }
    }
    
    
}
