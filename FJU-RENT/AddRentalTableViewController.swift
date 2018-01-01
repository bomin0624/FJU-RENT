//
//  AddRentalTableViewController.swift
//  FJU-RENT
//
//  Created by Gelzone on 2017/8/26.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class AddRentalTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var areaMessageField: UILabel!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var rentField: UITextField!
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var pingsField: UITextField!
    @IBOutlet weak var floorField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet var selectView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
 
    @IBOutlet weak var transView: UITextView!
    @IBOutlet weak var detailDesView: UITextView!
    @IBOutlet weak var depositField: UITextField!
    
    let list = ["請選擇", "新莊區", "三重區", "泰山區", "樹林區", "林口區", "板橋區", "龜山區"]
    
    var flag = false
    var longitude : Double?
    var latitude : Double?
    var imageArray = [UIImage]()
    
    var pageControl: UIPageControl!
    var myScrollView: UIScrollView!
    var fullSize :CGSize! = UIScreen.main.bounds.size

    
    func setLongitude(longitude:Double){
        if  longitude == longitude{
            self.longitude = longitude
        }
        
        
    }
    
    func setLatitude(latitude:Double){
        if  latitude == latitude{
            self.latitude = latitude
        }
        
    }
    
    //set variable to upload imge
    var uploadImageUrl = ""
    var uniqueString = ""
    var imgList = [Img]()
    
    //set image status
    enum Status {
        case noImge //未上傳圖片
        case upLoading //正在上傳圖片
        case ok //上傳完成
    }
    enum LocationStatus {
        case defaultStatus //default
        case error //正在create
        case ok //上傳完成
    }
    //init imge status
    var imgeStatus = Status.noImge
    var locationStatus = LocationStatus.defaultStatus
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        
    }
    //Mark: - set upload imge url
    func setUploadImageUrl(url: String) {
        uploadImageUrl = url
    }
    //Mark: - set unique string to image
    func setUniqueString(str: String) {
        uniqueString = str
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
    
    @IBAction func uploadImg(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let imagePickerAlertController = UIAlertController(title: "上傳圖片", message: "請選擇要上傳的圖片", preferredStyle: .actionSheet)
        let imageFromLibAction = UIAlertAction(title: "照片圖庫", style: .default) { (Void) in
            /*
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }*/
            //获得控制器
            let viewController : RITLPhotoNavigationViewController = RITLPhotoNavigationViewController()
            
            //设置viewModel属性
            let viewModel = viewController.viewModel
            
            
            // 获得图片
            viewModel.completeUsingImage = {(images) in
                let imageLength = images.count
                //self.imageArray = images
               // for image in images{
                    for i in 0..<imageLength{
                        let image = images[i]
                    
                    self.imageArray.append(image)
                    
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
                                
                                if i == imageLength-1{
                                    self.imgeStatus = .ok
                                    print("OK!")
                                }
                                
                            }
                        })
                    }
                    }
                    
                }
                //print(images)
                //self.myCollectionView.reloadData()
                
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
            
            // 获得资源的data数据
            viewModel.completeUsingData = {(datas) in
                
                //coding for data ex: uploading..
                print("data = \(datas)")
            }
            
            
            
            self.present(viewController, animated: true) {}

        }
        /*let imageFromCameraAction = UIAlertAction(title: "相機", style: .default) { (Void) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }*/
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (Void) in
            
            imagePickerAlertController.dismiss(animated: true, completion: nil)
        }
        imagePickerAlertController.addAction(imageFromLibAction)
        //imagePickerAlertController.addAction(imageFromCameraAction)
        imagePickerAlertController.addAction(cancelAction)
        
        present(imagePickerAlertController, animated: true, completion: nil)
    }

 
    private func AlertController(){
        
        //Mark：- 標題：刊登成功，確認鍵：我知道了
        let alertController = UIAlertController(title: "刊登成功", message: "", preferredStyle: .alert)
        
        let OkAction = UIAlertAction(title: "我知道了", style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            let vc = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "bomin")
            self.present(vc, animated: true,completion: nil)
        })
        alertController.addAction(OkAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
 
    @IBAction func addPress(_ sender: Any){
        
        //例外處理
        guard titleField.text != "", phoneField.text != "", rentField.text != "", pingsField.text != "", typeField.text != "", addressField.text != "", userField.text != "", floorField.text != "", areaMessageField.text != ""  else {
            let alertController = UIAlertController(title: "刊登失敗", message: "請輸入完整的資訊", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
            return
        }
        //, uploadImgView.image != nil
        guard imgeStatus != .noImge else {
            let alertController = UIAlertController(title: "刊登失敗", message: "請至少上傳一張圖片", preferredStyle: .alert)
            
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
        
     
        
        
        
        //if locationStatus == .ok{
        //upload
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
            //upload data in textfield
            let rentalData: DatabaseReference! = Database.database().reference().child("location").child(uid)
            let key = rentalData.childByAutoId().key
            let timeStamp = Int(NSDate().timeIntervalSince1970)
            let landlord = ["id": key, "title": self.titleField.text! as String, "phone": self.phoneField.text! as String, "rent": self.rentField.text! as String, "pings": self.pingsField.text! as String, "type": self.typeField.text! as String, "area": self.areaMessageField.text! as String, "address": self.addressField.text! as String, "user": self.userField.text! as String, "floor": self.floorField.text! as String, "trans": self.transView.text as String, "detail": self.detailDesView.text as String, "uid": uid, "likeCount": 0, "deposit": self.depositField.text! as String, "timeStamp" : timeStamp as Int] as [String : Any]
            
            
            
            let url = "https://maps.googleapis.com/maps/api/geocode/json?&address=\(self.addressField.text!)"
            let lakesURL = URL(string: url.urlEncoded())
            
            let session = URLSession.shared.dataTask(with: lakesURL!) { (data:Data?, response:URLResponse?, error:Error?) in
                
                if let data = data {
                    print(data)
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                        //print(json)
                        
                        //createMarkerObjects
                        //OperationQueue.main.addOperation {
                        //   self.createMarkerObjects(withJson: json!)
                        //}
                        let results = json?["results"] as? [[String:Any]]
                        
                        if (results?.count)! > 0{
                            
                            let result = results![0]
                            let address = result["formatted_address"] as? String
                            let geometry = result["geometry"] as? [String:Any]
                            let locationType = geometry?["location_type"] as? String
                            let location = geometry?["location"] as? [String:Any]
                            let latitude = location?["lat"] as? Double
                            let longitude = location?["lng"] as? Double
                            
                            self.setLatitude(latitude: latitude!)
                            self.setLongitude(longitude: longitude!)
                            
                            rentalData.child(key).setValue(landlord)
                            rentalData.child(key).child("latitude").setValue(self.latitude!)
                            rentalData.child(key).child("longitude").setValue(self.longitude!)
                            if self.imgeStatus == .ok{
                                for img in self.imgList{
                                    let uniqueString = img.uniqueString
                                    let uploadImageUrl = img.uploadImageUrl
                                    let imgKey = rentalData.childByAutoId().key
                                    rentalData.child(key).child("imgStorage").child(imgKey).child("imgName").setValue(uniqueString)
                                    rentalData.child(key).child("imgStorage").child(imgKey).child("imgUrl").setValue(uploadImageUrl)
                                }
                            }
                            self.locationStatus = LocationStatus.ok
                            if self.locationStatus == .error{
                                OperationQueue.main.addOperation {
                                    let alertController = UIAlertController(title: "刊登失敗", message: "網路不穩定或該地址名稱不合法，請重新輸入", preferredStyle: .alert)
                                    
                                    let defaultAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
                                    alertController.addAction(defaultAction)
                                    
                                    self.present(alertController, animated: true, completion: nil)

                                }
                                
                                //return
                                
                            }else if self.locationStatus == .ok{
                                 OperationQueue.main.addOperation {
                                self.AlertController()
                                }
                            }else{
                                print("未檢查locationStatus")
                            }
                            
                        }else{
                            //"網路不穩定或該地址名稱不合法，請重試"
                            self.locationStatus = LocationStatus.error
                            print("網路不穩定或該地址名稱不合法，請重試")
                            if self.locationStatus == .error{
                                 OperationQueue.main.addOperation {
                                let alertController = UIAlertController(title: "刊登失敗", message: "網路不穩定或該地址名稱不合法，請重新輸入", preferredStyle: .alert)
                                
                                let defaultAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
                                alertController.addAction(defaultAction)
                                
                                self.present(alertController, animated: true, completion: nil)
                                }
                                //return
                                
                            }else if self.locationStatus == .ok{
                                 OperationQueue.main.addOperation {
                                self.AlertController()
                                }
                            }else{
                                print("未檢查locationStatus")
                            }
                            
                            
                        }
                        
                    } catch {
                        print(error)
                        //add
                    }
                }
            }
            session.resume()
            

            
            
                        /*
            guard self.latitude != nil && self.longitude != nil else {
                let alertController = UIAlertController(title: "刊登失敗", message: "地址不符規定(不包括樓層)", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                present(alertController, animated: true, completion: nil)
                
                return
            }
 */
            //upload imge
            
            
            
           
            
            }
       // }
       
       
    }
 
    
    
    override func didReceiveMemoryWarning()
    {
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
}

