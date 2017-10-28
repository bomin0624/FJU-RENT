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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        let currentUser = Auth.auth().currentUser?.uid
        print("currentUser:\(currentUser)")
        if currentUser == managerId{ //管理員
            print("管理員")
            ref.child("Reports").observe(DataEventType.value, with: { (snapshot) in
                
                
                //.observeSingleEvent(of: .value, with: { (snapshot) in
                
                //self.reports.removeAll()
                
                for child in snapshot.children.allObjects as! [DataSnapshot]{
                    
                    print(child)
                    
                    if snapshot.childrenCount > 0{
                        let childObject = child.value as! NSDictionary
                        let reports = childObject.allValues as! [[String:Any]]
                        
                        for report in reports{
                            
                            print(report)
                            
                            let existPostId = report["postId"] as! String
                            let existReporter = report["reporter"] as! String
                            let existId = report["id"] as! String
                            let existUid = report["uid"] as! String
                            let existReportId = report["reportId"] as! String
                            let existReportReason = report["reportReason"] as! String
                            let data = Reports(id : existId, uid : existUid, postId : existPostId, reporter : existReporter, reportId : existReportId, reportReason: existReportReason)
                            
                            self.reports.append(data)
                            
                            //reload the table view
                            self.tableView.reloadData()
                            
                        }
                        
                    }
                }
                
            })
            
        } else { //一般用戶
            refHandle = ref?.child("Reports").child(currentUser!).observe(.childAdded, with: { (snapshot) in
                
                // take the value from the snap shop and add it to the postData array
                
                let id = snapshot.childSnapshot(forPath: "id").value as? String
                let postId = snapshot.childSnapshot(forPath: "postId").value as? String
                let reportId = snapshot.childSnapshot(forPath: "reportId").value as? String
                let reportReason = snapshot.childSnapshot(forPath: "reportReason").value as? String
                let reporter = snapshot.childSnapshot(forPath: "reporter").value as? String
                let uid = snapshot.childSnapshot(forPath: "uid").value as? String
                
                let data = Reports(id : id, uid : uid, postId : postId, reporter : reporter, reportId : reportId, reportReason: reportReason)
                
                self.reports.append(data)
                
                
                
                //reload the table view
                self.tableView.reloadData()
                
                
                
                
            })
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return reports.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PersonalMessageTableViewCell
        
        //Configure the cell...
        let reportReason = reports[indexPath.row].reportReason as! String
        cell.reportReasonTextView?.text = "尊敬的用戶您好！\n您所發表的言論被舉報為：\(reportReason)，請及時刪除，否則我們將予以凍結賬戶的處理！"
        
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
