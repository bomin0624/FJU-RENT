//
//  SearchSelectViewController.swift
//  FJU-RENT
//
//  Created by Bomin on 2017/8/28.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase



class SearchSelectViewController: UIViewController , UITableViewDelegate , UITableViewDataSource ,ExpandableHeaderViewDelegate{
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    var sections = [ Section(genre: "類型", detail: ["不限","套房", "雅房","家庭式"], expanded: false, subtitle: "請選擇類型"), Section(genre: "地區", detail: ["不限","新莊區", "泰山區", "林口區", "板橋區","樹林區","三重區","龜山區"], expanded: false, subtitle: "請選擇地區"), Section(genre: "租金範圍", detail: ["不限", "5000以下", "5000-7000","7000-9000","9000以上"], expanded: false, subtitle: "請選擇租金範圍") ]
    
    //add new dictionary for storing all search detail
    
    var detailDict = [Int: String]()
    
    var selectIndexPath : IndexPath!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // search bar 顏色跟 placeholder define
        searchBar.placeholder = "搜尋租屋..."
        //searchController.searchBar.tintColor = UIColor.white //cancel的顏色
        searchBar.barTintColor = UIColor(red: 198.0/255.0, green: 226.0/255.0, blue: 255.0/255.0, alpha: 1.0) //搜尋列背景顏色
        
        
        
        selectIndexPath = IndexPath(row: -1, section: -1)
        
        let nib = UINib(nibName: "ExpandableHeaderView", bundle: nil)
        
        tableView.register( nib, forHeaderFooterViewReuseIdentifier: "expandableHeaderView")
        
        // Do any additional setup after loading the view.
    }
    
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].detail.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 58
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (sections[indexPath.section].expanded){
            return 44
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "expandableHeaderView") as! ExpandableHeaderView
        
        headerView.customInit(title: sections[section].genre, subtitle: sections[section].subtitle, section: section, delegate: self)
        
        return headerView
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell")
        cell?.textLabel?.text = sections[indexPath.section].detail[indexPath.row]
        cell?.accessoryType = (indexPath == selectIndexPath) ? .checkmark:.none
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectIndexPath = indexPath
        self.sections[indexPath.section].subtitle = tableView.cellForRow(at: indexPath)?.textLabel?.text
        
        sections[indexPath.section].expanded = !sections[indexPath.section].expanded
        tableView.beginUpdates()
        tableView.reloadSections([indexPath.section], with:.automatic)
        
        //MARK: - add new search detail
        
        detailDict.updateValue(sections[indexPath.section].detail[indexPath.row], forKey:indexPath.section )
        
        
        tableView.endUpdates()
        
    }
    func toggleSection(header: ExpandableHeaderView, section: Int){
        
        sections[section].expanded = !sections[section].expanded
        tableView.beginUpdates()
        tableView.reloadSections([section], with:.automatic)
        tableView.endUpdates()
        
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchResult" {
            
            let destinationController = segue.destination as! RentSearchTableViewController
            
            //send search text
            destinationController.searchText = searchBar.text!
            
            //send condition
            destinationController.detailDict = detailDict
            
        }
        
    }
}

