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
    @IBOutlet weak var uploadImgView: UIImageView!
    @IBOutlet weak var transView: UITextView!
    @IBOutlet weak var detailDesView: UITextView!
    @IBOutlet weak var depositField: UITextField!
    
    let list = ["請選擇", "新莊區", "三重區", "泰山區", "樹林區", "林口區", "板橋區", "龜山區"]
    
    //set variable to upload imge
    var uploadImageUrl = ""
    var uniqueString = ""
    var imgList = [Img]()
    
    //set imge status
    enum Status {
        case noImge //未上傳圖片
        case upLoading //正在上傳圖片
        case ok //上傳完成
    }
    //init imge status
    var imgeStatus = Status.noImge
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //Mark:-set upload imge url
    func setUploadImageUrl(url: String) {
        uploadImageUrl = url
    }
    //Mark:-set unique string to imge
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
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        let imageFromCameraAction = UIAlertAction(title: "相機", style: .default) { (Void) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (Void) in
            
            imagePickerAlertController.dismiss(animated: true, completion: nil)
        }
        imagePickerAlertController.addAction(imageFromLibAction)
        imagePickerAlertController.addAction(imageFromCameraAction)
        imagePickerAlertController.addAction(cancelAction)
        
        present(imagePickerAlertController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //imge status
        imgeStatus = .upLoading
        
        var selectedImageFromPicker: UIImage?
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            selectedImageFromPicker = pickedImage
            self.uploadImgView.contentMode = .scaleAspectFit
            self.uploadImgView.image = pickedImage
        }
        //creat autoId to be a imge name
        let uniqueString = NSUUID().uuidString
        
        if let selectedImage = selectedImageFromPicker {
            let user = Auth.auth().currentUser
            if let user = user{
                let uid = user.uid
                //upload img to storage
                let imgStorage = Storage.storage().reference().child("addRental").child(uid).child("\(uniqueString).png")
                if let uploadData = UIImagePNGRepresentation(selectedImage) {
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
                            self.imgeStatus = .ok
                            print("OK!")
                        }
                    })
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    private func AlertController(){
        
        //Mark：-標題：刊登成功，確認鍵：我知道了
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
        //upload
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
            //upload data in textfield
            let rentalData: DatabaseReference! = Database.database().reference().child("location").child(uid)
            let key = rentalData.childByAutoId().key
            let landlord = ["id": key, "title": self.titleField.text! as String, "phone": self.phoneField.text! as String, "rent": self.rentField.text! as String, "pings": self.pingsField.text! as String, "type": self.typeField.text! as String, "area": self.areaMessageField.text! as String, "address": self.addressField.text! as String, "user": self.userField.text! as String, "floor": self.floorField.text! as String, "trans": self.transView.text as String, "detail": self.detailDesView.text as String, "uid": uid, "likeCount": 0, "deposit": self.depositField.text! as String] as [String : Any]
            
                rentalData.child(key).setValue(landlord)
            
            //upload imge
            if imgeStatus == .ok{
                for img in imgList{
                    let uniqueString = img.uniqueString
                    let uploadImageUrl = img.uploadImageUrl
                    let imgKey = rentalData.childByAutoId().key
                    rentalData.child(key).child("imgStorage").child(imgKey).child("imgName").setValue(uniqueString)
                    rentalData.child(key).child("imgStorage").child(imgKey).child("imgUrl").setValue(uploadImageUrl)
                }
            }
            
         
            
        }
        self.AlertController()
    }
}

