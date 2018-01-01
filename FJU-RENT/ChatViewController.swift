//
//  ChatViewController.swift
//  FJU-RENT
//
//  Created by iPhoneApp research center on 2017/9/4.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase


enum Status {
    case repeatReport
    case ok
    
}

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate{
    
    @IBOutlet weak var bottomConstant: NSLayoutConstraint!
    let managerId = "HcGcR1aIlSa8wbZ2w0JTgay4Try1"
    
    var posts = [Post]()
    var id = ""
    var uid = ""
    var postId = ""
    
    var reports = [Reports]()
    var reportStatus = Status.ok
    
    @IBOutlet weak var viewBottomConstant: NSLayoutConstraint!
   
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var messageTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ref = Database.database().reference()
        // print("id:\(id)")
        messageTableView.delegate = self
        messageTableView.dataSource = self
        //   messageField.delegate = self
        //observePost()
        
        ref.child("Posts").child(id).observe(.childAdded, with: { (snapshot) in
            
            //self.posts.removeAll()
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let post = Post()
                post.bodyText = dictionary["bodyText"] as? String
                post.username = dictionary["username"] as? String
                post.timeStamp = dictionary["time"] as? NSNumber
                //edit
                post.postId = dictionary["postId"] as? String
                post.uid = dictionary["uid"] as? String
                
                self.posts.append(post)
                
                self.messageTableView.reloadData()
            }
          
        })

        self.messageTableView.rowHeight = UITableViewAutomaticDimension
        self.messageTableView.estimatedRowHeight = 144 //調整cell高度
        
        
        
        //set exist reports
        ref.child("Reports").observe(DataEventType.value, with: { (snapshot) in
            
            self.reports.removeAll()
            
            for child in snapshot.children.allObjects as! [DataSnapshot]{
                
                if snapshot.childrenCount > 0{
                    let childObject = child.value as! NSDictionary
                    let reports = childObject.allValues as! [[String:Any]]
                    
                    for report in reports{
                       
                        
                        let existPostId = report["postId"] as! String
                        let existReporter = report["reporter"] as! String
                        let existId = report["id"] as! String
                        let existUid = report["uid"] as! String
                        let existReportId = report["reportId"] as! String
                        let existReportReason = report["reportReason"] as! String
                        let data = Reports(id : existId, uid : existUid, postId : existPostId, reporter : existReporter, reportId : existReportId, reportReason: existReportReason, uidName: "", reporterName: "", uidNameType: "")
                        
                        self.reports.append(data)
                        
                    }
                    
                }
            }
            
        })
       
        
        
   
        //MARK: - 鍵盤伸縮
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(Notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(Notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
 
    }
    //MARK: - 鍵盤伸縮
    func keyboardWillShow(Notification:NSNotification){
        if let info = Notification.userInfo{
            let rect: CGRect = info["UIKeyboardFrameEndUserInfoKey"] as!CGRect
        self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
               self.viewBottomConstant.constant = rect.height

            })
        
        }
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleSingleTap))
        self.view.addGestureRecognizer(tapRecognizer)
        
        
        
        
        
    }
    func handleSingleTap(recognizer: UITapGestureRecognizer){
    self.view.endEditing(true)
    
    
    }
    func keyboardWillHide(Notification:NSNotification){
        if let info = Notification.userInfo{
            let rect: CGRect = info["UIKeyboardFrameEndUserInfoKey"] as!CGRect
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
                self.viewBottomConstant.constant = 0
                
            })
            
        }
    }
    

    //MARK: - 發佈訊息
    @IBAction func sendMessage(_ sender: Any) {
        
        if (messageField.text?.characters.count)! >= 5{
            var username = ""
            let poster = Auth.auth().currentUser?.displayName as! String
            let currentUser = Auth.auth().currentUser?.uid
            let ref = Database.database().reference()
            let timeStamp = Int(NSDate().timeIntervalSince1970)
            if uid == currentUser{
                username = "(原PO)\(poster)"
            }else{
                username = (Auth.auth().currentUser?.displayName)!
                
            }
            
            print(poster)
            print("uid:\(uid)")
            print("current:\(currentUser)")
            let key = ref.childByAutoId().key
            let bodyData :[String : Any] = ["uid" : currentUser!,
                                            "bodyText": messageField.text!,
                                            "username":username,
                                            "time": timeStamp,
                                            "postId":key]
            ref.child("Posts").child(id).child(key).setValue(bodyData)
            messageField.text = ""
           
            
        }else {
            
            let alertController = UIAlertController(title: "輸入字數過少", message: "請輸入至少五個字", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
            
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChatTableViewCell
        let timeStamp = posts[indexPath.row].timeStamp
        let timeInterval: TimeInterval = TimeInterval(timeStamp!)
        let date = Date(timeIntervalSince1970: timeInterval)
        let dformatter = DateFormatter()
        
        //MARK: - 轉換時間
        dformatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        cell.timeLabel.text = "\(dformatter.string(from: date))"
        cell.textBody.text = posts[indexPath.row].bodyText
        print(posts[indexPath.row].bodyText)
        let postId = posts[indexPath.row].postId
        if postId == self.postId {
            cell.textBody.backgroundColor = UIColor.gray
            cell.textBody.textColor = UIColor.black
        }
        cell.nameLabel.text = posts[indexPath.row].username
        
       
        
        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //MARK: - 缺少 不可以重複舉報
        let reportAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "report", handler: { (action, indexPath) -> Void in
            
            
            
            let ref = Database.database().reference()
            let id = self.id
            let uid = self.uid
            let currentUser = Auth.auth().currentUser?.uid
            let postId = self.posts[indexPath.row].postId
            let postUid = self.posts[indexPath.row].uid
            print("租屋代碼：\(id)")
            print("屋主：\(uid)")
            print("使用者：\(currentUser)")
            print("訊息ID：\(postId)")
            print("留言者：\(postUid)")
            print("正在舉報中。。")
            
            //MARK： - 不可以舉報自己
            guard  currentUser != postUid else {
                let alertController = UIAlertController(title: "舉報失敗", message: "自己舉報自己，是在鬧哪樣！！", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                
                tableView.reloadData()
                return
            }
            
            //MARK： - 不可以重複舉報
           
            for report in self.reports{
                let existPostId = report.postId
                let existReporter = report.reporter
                if existPostId == postId && existReporter == currentUser {
                    print("已經舉報過了")
                    self.reportStatus = .repeatReport
                }
            }
            guard  self.reportStatus != .repeatReport else {
                let alertController = UIAlertController(title: "舉報失敗", message: "已經舉報過了！！", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.reportStatus = .ok
                self.present(alertController, animated: true, completion: nil)
                
                tableView.reloadData()
                return
            }
            
            //MARK: - 舉報原因
            let optionMenu = UIAlertController(title: nil, message: "為何舉報該評論?", preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            optionMenu.addAction(cancelAction)
            
            // MARK: - Add Report Reason:1
            let reportReasonOneActionHandler = { (action:UIAlertAction!) -> Void in
                
                let reportReason = "惡意攻擊或辱罵屋主及他人"
                let key = ref.childByAutoId().key
                let bodyData :[String : Any] = ["uid" : uid,
                                                "id": id,
                                                "reporter":currentUser,
                                                "postId": postId,
                                                "reportId" : key,
                                                "reportReason" : reportReason
                ]
                ref.child("Reports").child(postUid!).child(key).setValue(bodyData)
                
                let alertController = UIAlertController(title: "舉報成功", message: "我們會盡快通知留言人，感謝您的反饋！！", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
            // MARK: - Add Report Reason:2
            let reportReasonOneAction = UIAlertAction(title: "惡意攻擊或辱罵屋主及他人", style: .default, handler: reportReasonOneActionHandler)
            optionMenu.addAction(reportReasonOneAction)
            
            let reportReasonTwoActionHandler = { (action:UIAlertAction!) -> Void in
                
                let reportReason = "廣告及垃圾信息"
                let key = ref.childByAutoId().key
                let bodyData :[String : Any] = ["uid" : uid,
                                                "id": id,
                                                "reporter":currentUser,
                                                "postId": postId,
                                                "reportId" : key,
                                                "reportReason" : reportReason
                ]
                ref.child("Reports").child(postUid!).child(key).setValue(bodyData)
                
                let alertController = UIAlertController(title: "舉報成功", message: "我們會盡快通知留言人，感謝您的反饋！！", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            }

            let reportReasonTwoAction = UIAlertAction(title: "廣告及垃圾信息", style: .default, handler: reportReasonTwoActionHandler)
            optionMenu.addAction(reportReasonTwoAction)
            
            // MARK: - Add Report Reason:3
            let reportReasonThreeActionHandler = { (action:UIAlertAction!) -> Void in
                
                let reportReason = "色情、淫穢內容"
                let key = ref.childByAutoId().key
                let bodyData :[String : Any] = ["uid" : uid,
                                                "id": id,
                                                "reporter":currentUser,
                                                "postId": postId,
                                                "reportId" : key,
                                                "reportReason" : reportReason
                ]
                ref.child("Reports").child(postUid!).child(key).setValue(bodyData)
                
                let alertController = UIAlertController(title: "舉報成功", message: "我們會盡快通知留言人，感謝您的反饋！！", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
            
            let reportReasonThreeAction = UIAlertAction(title: "色情、淫穢內容", style: .default, handler: reportReasonThreeActionHandler)
            optionMenu.addAction(reportReasonThreeAction)
            
            // MARK: - Add report reason:4
            let reportReasonFourActionHandler = { (action:UIAlertAction!) -> Void in
                
                let reportReason = "激進時政、敏感信息"
                let key = ref.childByAutoId().key
                let bodyData :[String : Any] = ["uid" : uid,
                                                "id": id,
                                                "reporter":currentUser,
                                                "postId": postId,
                                                "reportId" : key,
                                                "reportReason" : reportReason
                ]
                ref.child("Reports").child(postUid!).child(key).setValue(bodyData)
                
                let alertController = UIAlertController(title: "舉報成功", message: "我們會盡快通知留言人，感謝您的反饋！！", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
            
            let reportReasonFourAction = UIAlertAction(title: "激進時政、敏感信息", style: .default, handler: reportReasonFourActionHandler)
            optionMenu.addAction(reportReasonFourAction)
            
            
            // MARK: - Display the Menu
            self.present(optionMenu, animated: true, completion: nil)
            
            
            
            tableView.reloadData()
        })
        
        // MARK: - Delete Button
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete",handler: { (action, indexPath) -> Void in
            
            let detaRef = Database.database().reference()
            let id = self.id
            let uid = self.uid
            let currentUser = Auth.auth().currentUser?.uid
            let postId = self.posts[indexPath.row].postId
            let postUid = self.posts[indexPath.row].uid
            print("租屋代碼：\(id)")
            print("屋主：\(uid)")
            print("使用者：\(currentUser)")
            print("訊息ID：\(postId)")
            print("留言者：\(postUid)")
            
            //只有管理者、屋主和留言者可以刪除自己的評論
            guard currentUser == self.managerId || currentUser == uid || currentUser == postUid else {
                let alertController = UIAlertController(title: "刪除失敗", message: "你不能刪除別人刊登的信息！！", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "我知道了", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            
            //MARK: - Delete data in cloud drive
            detaRef.child("Posts").child(id).child(postId!).setValue(nil)
            //delete in reports
            for report in self.reports{
                let existPostId = report.postId
                let existReporter = report.reporter as! String
                let existReportId = report.reportId as! String
                if existPostId == postId  {
                    print("該條評論已經被刪除")
                    detaRef.child("ReportId").child(existReporter).child(existReportId).setValue(nil)

                }
            }
            print("刪除成功！")
            
            // Delete the row from the data source
            
            tableView.beginUpdates()
            self.posts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        })
        
        //set background color
        reportAction.backgroundColor = UIColor(red: 48.0/255.0, green: 173.0/255.0, blue: 99.0/255.0, alpha: 1.0)
        deleteAction.backgroundColor = UIColor(red: 202.0/255.0, green: 202.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        
        return [deleteAction, reportAction]
    }

}
