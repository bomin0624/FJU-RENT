//
//  RentInSpecificAreaTableViewController.swift
//  FJU-RENT
//
//  Created by WZH on 2017/11/19.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit

//Mark：- 商圈找房
class RentInSpecificAreaTableViewController: UITableViewController {

    
   
    var areaNames = ["輔大周邊", "工商城", "好事多「Costco」", "大學新村"]
    var areaLatitude = [25.035479, 25.033162, 25.027233,25.041199]
    var areaLongitude = [121.432421, 121.431505, 121.434707, 121.431344]
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return areaNames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        cell.textLabel?.text = areaNames[indexPath.row]

        return cell
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "searchResult" {
            if let indexPath = tableView.indexPathForSelectedRow{
                
                
                let destinationController = segue.destination as! RentSearchTableViewController
                //destinationController.id = rentList.id!
                //destinationController.uid = rentList.uid!
            
                destinationController.latitude = areaLatitude[indexPath.row]
                destinationController.longitude = areaLongitude[indexPath.row]
                
                
            }
            
            
            
        }
        
    }
 

}
