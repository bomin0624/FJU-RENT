//
//  SystemMessageTableViewController.swift
//  FJU-RENT
//
//  Created by Bomin on 2017/8/28.
//  Copyright © 2017年 Bomin. All rights reserved.
//


import UIKit
import Firebase

class SystemMessageTableViewController: UITableViewController,UIViewControllerPreviewingDelegate {
    
    @IBOutlet var tableWiew: UITableView!
    
    var ref: DatabaseReference!
    var refHandle : DatabaseHandle!
    var systemMessageTitle = [String]()
    var systemMessage = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(traitCollection.forceTouchCapability == .available){
            registerForPreviewing(with: self as! UIViewControllerPreviewingDelegate, sourceView: view)
        }
        
        ref = Database.database().reference()
        
        refHandle = ref?.child("systemMessage").observe(.childAdded, with: { (snapshot) in
        
            let title = snapshot.childSnapshot(forPath: "title").value as? String
            let message = snapshot.childSnapshot(forPath: "message").value as? String
            if let actualTitle = title  {
                if let actualMessage = message {
                
                    self.systemMessageTitle.append(actualTitle)
                    self.systemMessage.append(actualMessage)

                    self.tableView.reloadData()
                }
            }
            
            
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return systemMessageTitle.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SystemMessageTableViewCell
        
        cell.titleLabel.text = systemMessageTitle[indexPath.row]
        
        
        cell.messageLabel.text = systemMessage[indexPath.row]
        
        return cell
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "systemMessageDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! SystemMessageDetailViewController
                destinationController.systemMessageTitle = systemMessageTitle[indexPath.row]
                destinationController.systemMessage = systemMessage[indexPath.row]
                
            }
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
        
        guard let SystemMessageDetailViewController = storyboard?.instantiateViewController(withIdentifier: "SystemMessageDetailViewController") as? SystemMessageDetailViewController else {
            return nil
        }
        
        let selectedSystemMessage = systemMessage[indexPath.row]
        let selectedSystemMessage2 = systemMessageTitle[indexPath.row]
        SystemMessageDetailViewController.systemMessage = selectedSystemMessage
        SystemMessageDetailViewController.systemMessageTitle = selectedSystemMessage2
        SystemMessageDetailViewController.preferredContentSize = CGSize(width: 0.0, height: 450.0)
        
        previewingContext.sourceRect = cell.frame
        
        return SystemMessageDetailViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
}
