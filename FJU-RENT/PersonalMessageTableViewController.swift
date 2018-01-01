//
//  PersonalMessageTableViewController.swift
//  FJU-RENT
//
//  Created by WZH on 2017/9/19.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase

class PersonalMessageTableViewController: UITableViewController {


    let managerId = "HcGcR1aIlSa8wbZ2w0JTgay4Try1"
    
    var ref: DatabaseReference!
    var refHandle : DatabaseHandle!
  
    var reports = [Reports]()
    
    var name = ""
    var nameType = ""
    var reporter = ""
    
    func setName(name:String){
        self.name = name
    }
    func setNameType(nameType:String){
        self.nameType = nameType
    }
    func setReporterName(name:String){
        self.reporter = name
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

   

        
        ref = Database.database().reference()
        let currentUser = Auth.auth().currentUser?.uid
        if currentUser == managerId{
            
            print("管理員")
            
            ref.child("Reports").observe(DataEventType.value, with: { (snapshot) in

                for child in snapshot.children.allObjects as! [DataSnapshot]{
                    
                    //print(child)
                    
                    if snapshot.childrenCount > 0{
                        let childObject = child.value as! NSDictionary
                        let reports = childObject.allValues as! [[String:Any]]
                        
                        for report in reports{
                            
                            //print(report)
                            
                            let existPostId = report["postId"] as! String
                            let existReporter = report["reporter"] as! String
                            let existId = report["id"] as! String
                            let existUid = report["uid"] as! String
                            let existReportId = report["reportId"] as! String
                            let existReportReason = report["reportReason"] as! String
                            
                            
                            let data = Reports(id : existId, uid : existUid, postId : existPostId, reporter : existReporter, reportId : existReportId, reportReason: existReportReason, uidName: self.name, reporterName: self.reporter, uidNameType: self.nameType)
                                
                            self.reports.append(data)

                            
                            
                            self.tableView.reloadData()
                            
                        }
                        
                        
                    }
                  
                }
                
              
                for report in self.reports{
                    let reporter = report.reporter as! String
                    self.ref.child("Members").child(reporter).observeSingleEvent(of:.value,with: {(snapshot) in
                        
                        let dataDict = snapshot.value as! [String: Any]
                        let user  = dataDict["email"] as! String
                        let name  = dataDict["name"] as! String
                        let type  = dataDict["type"] as? String
                        
                        report.reporterName = name
                        
                        self.tableView.reloadData()
                        
                        
                        
                    })
                    
               
                    
                }
                for report in self.reports{
                    let uid = report.uid as! String
                    self.ref.child("Members").child(uid).observeSingleEvent(of:.value,with: {(snapshot) in
                        
                        let dataDict = snapshot.value as! [String: Any]
                        let user  = dataDict["email"] as! String
                        let name  = dataDict["name"] as! String
                        let type  = dataDict["type"] as? String
                        var nameType : String?
                        
                        if type == "T"{
                            nameType = "租客"
                        }else if type == "L"{
                            nameType = "房東"
                        }else {
                            nameType = "FaceBook用戶"
                        }
                        
                        report.uidName = name
                        report.uidNameType = nameType
                        
                        self.tableView.reloadData()
                        
                    })
                    

                }
                
            })
            
            
            
            
            

            

            
        } else {
            
            //一般用戶
            refHandle = ref?.child("Reports").child(currentUser!).observe(.childAdded, with: { (snapshot) in
                
                let id = snapshot.childSnapshot(forPath: "id").value as? String
                let postId = snapshot.childSnapshot(forPath: "postId").value as? String
                let reportId = snapshot.childSnapshot(forPath: "reportId").value as? String
                let reportReason = snapshot.childSnapshot(forPath: "reportReason").value as? String
                let reporter = snapshot.childSnapshot(forPath: "reporter").value as? String
                let uid = snapshot.childSnapshot(forPath: "uid").value as? String
                
                let data = Reports(id : id, uid : uid, postId : postId, reporter : reporter, reportId : reportId, reportReason: reportReason, uidName: "", reporterName: "", uidNameType: "")
                
                self.reports.append(data)
                self.tableView.reloadData()
                
                
                
                
            })
            
            ref = Database.database().reference()
            let userID:String = (Auth.auth().currentUser?.uid)!
            ref.child("Members").child(userID).observeSingleEvent(of:.value,with: {(snapshot) in
                
                let dataDict = snapshot.value as! [String: Any]
                let user  = dataDict["email"] as! String
                let name  = dataDict["name"] as! String
                let type  = dataDict["type"] as? String
                var nameType : String?
                
                if type == "T"{
                    nameType = "租客"
                }else if type == "L"{
                    nameType = "房東"
                }else {
                    nameType = "FaceBook用戶"
                }
                self.setName(name: name)
                self.setNameType(nameType: nameType!)
                self.tableView.reloadData()
                
            })
            
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PersonalMessageTableViewCell
        
        
        let currentUser = Auth.auth().currentUser?.uid
        if currentUser == managerId{
            
            let reportReason = reports[indexPath.row].reportReason as! String
            let nameType = reports[indexPath.row].uidNameType as! String
            let name = reports[indexPath.row].uidName as! String
            let reporter = reports[indexPath.row].reporterName as! String
            //let nameType = nameTypeList.count
            //[indexPath.row] as! String
            //let name = nameList.count
            //[indexPath.row] as String!
            //let reporter = reporterList.count
            //[indexPath.row] as String!
            
            cell.reportReasonTextView?.text = "\(nameType):\(name)的所發表的言論被\(reporter)舉報為：\(reportReason)"
        }else{
       
        
        //Configure the cell...
        let reportReason = reports[indexPath.row].reportReason as! String
        cell.reportReasonTextView?.text = "尊敬的\(nameType):\(name)您好！\n您所發表的言論被舉報為：\(reportReason)，請及時刪除，否則我們將予以凍結賬戶的處理！\nFJU RENT團隊"
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chat" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! ChatViewController
                destinationController.id = reports[indexPath.row].id!
                
                destinationController.uid = reports[indexPath.row].uid!
                destinationController.postId = reports[indexPath.row].postId!
             
                
            }
        }
    }
  

}
