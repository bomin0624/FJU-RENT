//
//  EditRentalTableViewController.swift
//  FJU-RENT
//
//  Created by Gelzone on 2017/9/9.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class EditRentalTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    

    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var areaMessageField: UILabel!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var rentField: UITextField!
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var pingsField: UITextField!
    @IBOutlet weak var floorField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var transView: UITextView!
    @IBOutlet weak var detailDesView: UITextView!
    @IBOutlet var selectView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var depositField: UITextField!
    
    var flag = false
    let list = ["請選擇", "新莊區", "三重區", "泰山區", "樹林區", "林口區", "板橋區", "龜山區"]
    var uid = ""
    var id = ""
    
    var imageArray = [UIImage]()
        //= [UIImage]()
    var pageControl: UIPageControl!
    var myScrollView: UIScrollView!
    var fullSize :CGSize! = UIScreen.main.bounds.size
    
    //set variable to upload image
    //var uploadImageUrl = ""
    //var uniqueString = ""
    var imgList = [Img]()
    //set variable to delete image
    //var imgKeyList = [String]()
    var imgNameList = [String]()
    
    var likeCount = 0
    
    //set image status
    enum Status {
        case noImge //未上傳圖片
        case upLoading //正在上傳圖片
        case ok //上傳完成
    }
    //init image status
    var imgeStatus = Status.noImge
    
    
    //set variable to upload imge
    var uploadImageUrl = ""
    var uniqueString = ""
    
    //Mark: - set upload imge url
    func setUploadImageUrl(url: String) {
        uploadImageUrl = url
    }
    //Mark: - set unique string to image
    func setUniqueString(str: String) {
        uniqueString = str
    }
    
    override func viewDidLoad() {
        
        
        
        super.viewDidLoad()
        
        //imageArray = [#imageLiteral(resourceName: "pic4"),#imageLiteral(resourceName: "pic2"),#imageLiteral(resourceName: "pic5"),#imageLiteral(resourceName: "pic3"),#imageLiteral(resourceName: "pic1"), #imageLiteral(resourceName: "pic6")]
        let imageNumber = imageArray.count
        for i in 0..<imageNumber{
        //for image in imageArray{
            
            let image = imageArray[i]
            //image status
            self.imgeStatus = .upLoading
            
            //creat autoId to be a image name
            let uniqueString = NSUUID().uuidString
            let user = Auth.auth().currentUser
            if let user = user{
                let uid = user.uid
                let imgStorage = Storage.storage().reference().child("addRental").child(uid).child("\(uniqueString).png")
                if let uploadData = UIImagePNGRepresentation(image) {
                    imgStorage.putData(uploadData, metadata: nil, completion: { (data, error) in
                        if error != nil {
                            print("Error: \(error!.localizedDescription)")
                            return
                        }
                        //圖片已經上傳至storage..
                        //fetch url
                        if let uploadImageUrl = data?.downloadURL()?.absoluteString {
                            self.setUniqueString(str: uniqueString)
                            self.setUploadImageUrl(url: uploadImageUrl)
                            
                            //add in img list
                            let img = Img()
                            img.uniqueString = self.uniqueString
                            img.uploadImageUrl = self.uploadImageUrl
                            self.imgList.append(img)
                            //imge status
                            if i == imageNumber-1{
                            self.imgeStatus = .ok
                            print("OK!")
                            }
                        }
                    })
                }
            }
        }
        // 建立 UIScrollView
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
        
        for i in 0..<self.imageArray.count{
            
            let imageView = UIImageView()
            imageView.image = self.imageArray[i]
            let xPosition = self.myScrollView.frame.width * CGFloat(i)
            
            imageView.frame = CGRect.init(x: xPosition, y: 0, width: self.myScrollView.frame.width, height: self.myScrollView.frame.height)
            
            self.myScrollView.contentSize.width = self.myScrollView.frame.width * CGFloat(i + 1)
            self.myScrollView.addSubview(imageView)
        }
        

        
        let databaseRef = Database.database().reference().child("location").child(uid).child(id)
        databaseRef.observe(DataEventType.value, with: { (snapshot) in
            if snapshot.childrenCount > 0{
                let editObject = snapshot.value as? [String: Any]
               /*
                let editImgStorage = editObject?["imgStorage"] as? NSDictionary
                //add imgkey
                let imgKey = editImgStorage?.allKeys[0] as! String //需要修改的圖片的隨機碼，目前只能改掉第一張
                self.imgKeyList.append(imgKey)
 
                let imgDict = editImgStorage?.allValues[0] as! [String : Any]
                let editImageName = imgDict["imgName"] as! String
                let editImage = imgDict["imgUrl"] as! String
                //self.setUniqueString(str: editImageName)
                //self.setUploadImageUrl(url: editImage)
                */
                let editTitle = editObject?["title"] as! String?
                let editArea = editObject?["area"] as! String?
                let editAddress = editObject?["address"] as! String?
                let editRent = editObject?["rent"] as! String?
                let editUser = editObject?["user"] as! String?
                let editPhone = editObject?["phone"] as! String?
                let editPings = editObject?["pings"] as! String?
                let editFloor = editObject?["floor"] as! String?
                let editType = editObject?["type"] as! String?
                let editTrans = editObject?["trans"] as! String?
                let editDetail = editObject?["detail"] as! String?
                let editDeposit = editObject?["deposit"] as! String?
                
                self.titleField.text = editTitle
                self.areaMessageField.text = editArea
                self.addressField.text = editAddress
                self.rentField.text = editRent
                self.userField.text = editUser
                self.phoneField.text = editPhone
                self.pingsField.text = editPings
                self.floorField.text = editFloor
                self.typeField.text = editType
                self.transView.text = editTrans
                self.detailDesView.text = editDetail
                self.depositField.text = editDeposit

            }
 
        })
 
    }
  
    func showPickerView(){
        self.view.addSubview(self.selectView)
        self.tableView?.isScrollEnabled = false
        self.selectView.frame.origin.y = self.view.frame.height
        self.selectView.bounds = CGRect(x: 0, y: self.selectView.bounds.origin.y, width: UIScreen.main.bounds.width, height: self.selectView.bounds.height)
        self.selectView.frame.origin.x = 0
        selectView.layer.cornerRadius = 10
        UIView.animate(withDuration: 0.5){
            self.selectView.frame.origin.y = self.view.frame.height-self.selectView.frame.height
            self.view.layoutIfNeeded()
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        areaMessageField.text = list[row]
        if areaMessageField.text == list[0]{
            areaMessageField.text = ""
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2{
            self.showPickerView()
        }
    }
    @IBAction func doneClick(_ sender: Any) {
        self.selectView.removeFromSuperview()
        self.tableView?.isScrollEnabled = true
    }


    private func AlertController(){
        let alertController = UIAlertController(title: "修改成功", message: "", preferredStyle: .alert)
        
        let OkAction = UIAlertAction(title: "我知道了", style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            let vc = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "bomin")
            self.present(vc, animated: true,completion: nil)
        })
        alertController.addAction(OkAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addPress(_ sender: Any) {
        guard titleField.text != "", phoneField.text != "", rentField.text != "", pingsField.text != "", typeField.text != "", addressField.text != "", userField.text != "", floorField.text != "", areaMessageField.text != ""  else {
            
            let alertController = UIAlertController(title: "修改失敗", message: "請輸入完整的資訊", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
            return
        }
    
        guard imgeStatus != .upLoading else {
            let alertController = UIAlertController(title: "刊登失敗", message: "圖片正在上傳", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
            return
        }
        //upload
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
            //upload data in textfield
            let rentalData: DatabaseReference! = Database.database().reference().child("location").child(uid)
            
            //let key = rentalData.childByAutoId().key
            let key = id
            let landlord = ["id": key, "title": self.titleField.text! as String, "phone": self.phoneField.text! as String, "rent": self.rentField.text! as String, "pings": self.pingsField.text! as String, "type": self.typeField.text! as String, "area": self.areaMessageField.text! as String, "address": self.addressField.text! as String, "user": self.userField.text! as String, "floor": self.floorField.text! as String, "trans": self.transView.text as String, "detail": self.detailDesView.text as String, "uid": uid, "depospit": self.depositField.text! as String]
            //rentalData.child(key).setValue(landlord)
            rentalData.child(key).updateChildValues(landlord)
            
            
            //delete orgin in database
            //let rentalData: DatabaseReference! = Database.database().reference().child("location").child(uid).child(id).child("imgStorage")
            //for imgKey in imgKeyList{
            //    rentalData.child(imgKey).setValue(nil)
            //}
            //upload imge:簡易的修改，存在bug
            
            rentalData.child(key).child("imgStorage").setValue(nil)
                
            if imgeStatus == .ok{
                for img in imgList{
                    let uniqueString = img.uniqueString
                    let uploadImageUrl = img.uploadImageUrl
                    let imgKey = rentalData.childByAutoId().key
                    //for imgKey in imgKeyList{
                    rentalData.child(key).child("imgStorage").child(imgKey).child("imgName").setValue(uniqueString)
                    rentalData.child(key).child("imgStorage").child(imgKey).child("imgUrl").setValue(uploadImageUrl)
                    //}
                    
                }
            }
            
            
            
        }

        self.AlertController()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        
        
        
        if segue.identifier == "modify" {
            let destination = segue.destination as! CollectionImageViewController
            destination.id = id
            destination.uid = uid
            
            destination.imageArray = imageArray
            
        }
        
        
        
        
    }
    
}
