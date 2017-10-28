//
//  AddRentalController.swift
//  FJU-RENT
//
//  Created by Gelzone on 2017/8/23.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class AddRentalController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var rentField: UITextField!
    @IBOutlet weak var pingsField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var areaMessageField: UILabel!
    @IBOutlet var selectView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var uploadImgView: UIImageView!
    let list = ["請選擇","新莊","三重","泰山"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.addSubview(selectView)
        selectView.translatesAutoresizingMaskIntoConstraints = false
        selectView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        selectView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        selectView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        let a = selectView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 180)
        a.identifier = "bottom"
        a.isActive = true
        
        selectView.layer.cornerRadius = 10
        super.viewWillAppear(animated)
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
    }
    
    @IBAction func doneClick(_ sender: Any) {
        let title = list[pickerView.selectedRow(inComponent: 0)]
        selectButton.setTitle(title, for: .normal)
        displayPickerView(false)
    }
    @IBAction func selectClick(_ sender: Any){
        displayPickerView(true)
    }
    func displayPickerView(_ show: Bool){
        for c in view.constraints{
            if c.identifier == "bottom"{
                c.constant = (show) ? -10 :180
                break
            }
        }
        UIView.animate(withDuration: 0.5){
            self.view.layoutIfNeeded()
        }
        
    }
    @IBAction func uploadImg(_ sender: Any) {
        guard titleField.text != "", phoneField.text != "", rentField.text != "", pingsField.text != "", typeField.text != "", pickerView.selectedRow(inComponent: 0) != 0 else{
            let alertController = UIAlertController(title: "請先填寫資料再上傳圖片", message: "", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
            return
        }
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
        
        var selectedImageFromPicker: UIImage?
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            selectedImageFromPicker = pickedImage
            self.uploadImgView.contentMode = .scaleAspectFit
            self.uploadImgView.image = pickedImage
        }
        let uniqueString = NSUUID().uuidString
        
        if let selectedImage = selectedImageFromPicker {
            let user = Auth.auth().currentUser
            if let user = user{
                let uid = user.uid
            
                let imgStorage = Storage.storage().reference().child(uid).child("\(uniqueString).png")
                if let uploadData = UIImagePNGRepresentation(selectedImage) {
                    imgStorage.putData(uploadData, metadata: nil, completion: { (data, error) in
                        if error != nil {
                            print("Error: \(error!.localizedDescription)")
                            return
                        }
                        if let uploadImageUrl = data?.downloadURL()?.absoluteString {
                            let rentalData: DatabaseReference! = Database.database().reference().child(uid)
                            let key = rentalData.childByAutoId().key
                            let landlord = ["id": key, "title": self.titleField.text! as String, "phone": self.phoneField.text! as String, "rent": self.rentField.text! as String, "pings": self.pingsField.text! as String, "type": self.typeField.text! as String, "area": self.areaMessageField.text! as String, "img": uploadImageUrl
                            ]
                            rentalData.child(key).setValue(landlord)
                        }
                    })
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    private func AlertController(){
        let alertController = UIAlertController(title: "刊登成功", message: "", preferredStyle: .alert)
        
        let OkAction = UIAlertAction(title: "我知道了", style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            let vc = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "rentalView")
            self.present(vc, animated: true,completion: nil)
        })
        alertController.addAction(OkAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func addPress(_ sender: Any){
        guard titleField.text != "", phoneField.text != "", rentField.text != "", pingsField.text != "", typeField.text != "", pickerView.selectedRow(inComponent: 0) != 0 else{
            let alertController = UIAlertController(title: "刊登失敗", message: "請輸入正確的資訊", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
            return
        }
        self.AlertController()
    }
}


