//
//  RentSearchTableViewController.swift
//  FJU-RENT
//
//  Created by Bomin on 2017/8/13.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class RentSearchTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate ,UISearchResultsUpdating,UIViewControllerPreviewingDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    
    @IBOutlet var searchTableView: UITableView!
    @IBOutlet weak var sortPicker: UIPickerView!
    @IBOutlet var sortView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchFooter: SearchFooter!
    var searchController = UISearchController(searchResultsController: nil)
    var resultController = UITableViewController()
    
    var list = [Model]()
    var keyList = [String]()
    // replace var rentList = [Rents]()
    
    //receive & listen
    var searchText = ""
   // var condiction = ""
    
    var filteredRent = [Model]()
    
    //replace list into dict
    var detailDict = [Int: String]()
    
    var sortList = ["默認排序","依最新上架排序","依價錢高到低","依價錢低到高"]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //3d touch
        if(traitCollection.forceTouchCapability == .available){
            registerForPreviewing(with: self as! UIViewControllerPreviewingDelegate, sourceView: view)
        }
        
        let searchText = getSearchBarText()

        
        let rentType = getType()
        
        let rentArea = getArea()

        let rentMoney = getMoney()
        
        searchController.searchBar.text = searchText
        
        
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchTableView.tableHeaderView = searchController.searchBar
        
        
        
        
        // search bar 顏色跟 placeholder define
        searchController.searchBar.placeholder = "搜尋租屋..."
        searchController.searchBar.tintColor = UIColor.white //cancel的顏色
        searchController.searchBar.barTintColor = UIColor(red: 198.0/255.0, green: 226.0/255.0, blue: 255.0/255.0, alpha: 1.0) //搜尋列背景顏色
        searchController.searchBar.setValue("取消", forKey:"_cancelButtonText")  //cancel改文字

        
            
        
        Database.database().reference().child("location").observeSingleEvent(of: .value, with: { (snapshot) in
 
            
            if snapshot.childrenCount > 0{
                //self.list.removeAll()
                for rents in snapshot.children.allObjects as! [DataSnapshot]{
  
                    let rentKey = rents.key as! String
                    self.keyList.append(rentKey)
                }
                //print(self.keyList)
                for key in self.keyList{
                    //print("key:\(key)")
                    let databaseRef = Database.database().reference().child("location").child(key)
                    databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        //.observe(DataEventType.value, with: { (snapshot) in
                        if snapshot.childrenCount > 0{
                            //self.list.removeAll()
                            for rents in snapshot.children.allObjects as! [DataSnapshot]{
                                let rentObject = rents.value as? [String: Any]
                                let rentTitle = rentObject?["title"] as! String
                                let rentMoney = rentObject?["rent"] as! String
                                let rentPings = rentObject?["pings"] as! String
                                let rentId = rentObject?["id"] as! String
                                let rentUid = rentObject?["uid"] as! String
                                let rentImgStorage = rentObject?["imgStorage"] as? NSDictionary
                                let imgDict = rentImgStorage?.allValues[0] as! [String : Any]
                                let rentUniString = imgDict["imgName"] as! String
                                let rentImg = imgDict["imgUrl"] as! String
                                
                                //add
                                let rentArea = rentObject?["area"] as! String?
                                let rentAddress = rentObject?["address"] as! String?
                                let rentType = rentObject?["type"] as! String?
                                
                                var rentLikeCount = rentObject?["likeCount"] as! Int?
                                let timeStamp = rentObject?["timeStamp"] as! Int?

                                if rentLikeCount == nil{
                                    rentLikeCount = 0
                                }
                                let rentList = Model(title: rentTitle, money: rentMoney , pings: rentPings ,imgPath: rentImg , id: rentId , uid: rentUid , uniString: rentUniString, address: rentAddress, genre: rentType, area: rentArea, likeCount: rentLikeCount!, timeStamp: timeStamp!)
                                
                                self.list.append(rentList)
                             
//                                if self.condiction == "依最新上架排序"{
//                                    self.list = self.list.sorted(by: {$0.timeStamp > $1.timeStamp})
//                                    self.tableView.reloadData()
//                                    
//                                }
                            self.tableView.reloadData()
                            }
                            //self.tableView.reloadData()
                            DispatchQueue.main.async {
                                
                                self.filterContentForMultiSearch(searchText, rentType, rentArea, rentMoney: rentMoney)
                            }
                            
                        }
                    })
                    
                }

          
            }
            
            
        })
        
    }
    
    
    //搜尋前進行過濾
    //get rent type
    func getType()-> String {
        let rentType = detailDict[0]

        if rentType == nil || rentType == "不限" {
            print("類型未選擇")
            return ""
        } else {
            return rentType!
        }
        
        
    }
    //get rent area
    func getArea()-> String {
        let rentArea = detailDict[1]

        if rentArea == nil || rentArea == "不限" {
            print("地區未選擇")
            return ""
        }else{
            return rentArea!
        }
        
        
    }

    
    //get rent money
    func getMoney()-> Array<Int> {
        var range:Array = [Int]() //min and max
        let rentMoney = detailDict[2]
        if rentMoney == nil || rentMoney == "不限" {
            print("租金範圍未選擇")
            return [0,Int.max]
        }else{
            if let actMoney = rentMoney{
                if actMoney == "5000以下" {
                    range = [0,5000]
                }else if actMoney == "5000-7000" {
                    range = [5000,7000]
                }else if actMoney == "7000-9000" {
                    range = [7000,9000]
                }else {
                    range = [9000,Int.max]
                }
            }
            return range
        }
        
    }
    
    //get search bar text
    func getSearchBarText()-> String {
        if searchText == "" {
            print("search bar 未選擇")
            return ""
        } else {
            return searchText
        }
    }
    
    //fuc compare money
    func compareRentMoney(money:Int,range:[Int]) -> Bool{
        
        let min = range[0]
        let max = range[1]
        if money >= min && money <= max {
            return true
        }else {
            return false
        }
    }
    
    //filter string into number
    func filterStringIntoNumber(str: String) -> Int {
        let numbers = str.characters
            .split(omittingEmptySubsequences: true) { !"0123456789".contains(String($0))}
            .map {Int(String($0))!}
        return numbers[0]
    }
    
    //add array != 0
    func searchConditionIsEmpty() -> Bool {
        // Returns true if the list is empty or nil
        return detailDict.isEmpty ?? true
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        //update the search results
        filterContentForSearchText(searchController.searchBar.text!)
        
    }
    
    
    
    //search bar 搜尋
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredRent = list.filter({ (list: Model) -> Bool in
            
            if let name = list.title, let address = list.address, let money = list.money, let area = list.area{
                let isMatch = name.localizedCaseInsensitiveContains(searchText) || address.localizedCaseInsensitiveContains(searchText) || money.localizedCaseInsensitiveContains(searchText) || area.localizedCaseInsensitiveContains(searchText)
                return isMatch
            }
            
            return false
        })
        
        
        
        
        searchTableView.reloadData()
    }
    
    //multi search
    func filterContentForMultiSearch(_ searchText: String,_ rentType: String, _ rentArea:String, rentMoney: [Int], scope: String = "All") {
        filteredRent = list.filter({( rent : Model) -> Bool in
            
            if let name = rent.title, let type = rent.genre, let address = rent.address, let money = rent.money, let area = rent.area{
                if searchText != ""{
                    //print("以search bar 內容為條件進行搜尋")
                    let isMatch = name.localizedCaseInsensitiveContains(searchText) || address.localizedCaseInsensitiveContains(searchText) || money.localizedCaseInsensitiveContains(searchText) || area.localizedCaseInsensitiveContains(searchText)
                    return isMatch
                } else {
                    if rentType != "" && rentArea != "" && rentMoney != [0,Int.max]{
                        //print("以類型、地區、租金為條件進行搜尋")
                        let isMatch = type.localizedCaseInsensitiveContains(rentType) && area.localizedCaseInsensitiveContains(rentArea) && compareRentMoney(money: filterStringIntoNumber(str: money), range: rentMoney)
                        return isMatch
                    } else if rentType == "" && rentArea != "" && rentMoney != [0,Int.max] {
                        //print("地區和租金為條件進行搜尋")
                        let isMatch =  area.localizedCaseInsensitiveContains(rentArea) && compareRentMoney(money: filterStringIntoNumber(str: money), range: rentMoney)
                        
                        return isMatch
                    } else if rentType != "" && rentArea == "" && rentMoney != [0,Int.max] {
                        //print("類型和租金為條件進行搜尋")
                        let isMatch = type.localizedCaseInsensitiveContains(rentType) && compareRentMoney(money: filterStringIntoNumber(str: money), range: rentMoney)
                        return isMatch
                    } else if rentType != "" && rentArea != "" && rentMoney == [0,Int.max] {
                        //print("類型和地區為條件進行搜尋")
                        
                        let isMatch = type.localizedCaseInsensitiveContains(rentType) && area.localizedCaseInsensitiveContains(rentArea)
                        return isMatch
                    } else if rentType == "" && rentArea == "" && rentMoney != [0,Int.max] {
                        //print("租金為條件進行搜尋")
                        let isMatch = compareRentMoney(money: filterStringIntoNumber(str: money), range: rentMoney)
                        return isMatch
                    } else if rentType == "" && rentArea != "" && rentMoney == [0,Int.max] {
                        //print("地區為條件進行搜尋")
                        let isMatch =  area.localizedCaseInsensitiveContains(rentArea)
                        return isMatch
                    } else if rentType != "" && rentArea == "" && rentMoney == [0,Int.max] {
                        //print("類型為條件進行搜尋")
                        let isMatch = type.localizedCaseInsensitiveContains(rentType)
                        return isMatch
                    } else {
                        //print("沒有設定任何搜尋條件")
                        let isMatch = true
                        return isMatch
                    }
                }
                
            }
            
            return false
        })
        
        searchTableView.reloadData()
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //search bar filter
    func isFiltering() -> Bool {
        if searchBarIsEmpty() {
            if searchConditionIsEmpty(){
                return false
            }
            
        }
        return true
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection
        section:Int) -> Int {
        
        if isFiltering() {
            searchFooter.setIsFilteringToShow(filteredItemCount: filteredRent.count, of: list.count) //filter 搜尋顯示
            return filteredRent.count
        }
        
        searchFooter.setNotFiltering()
        return list.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RentTableViewCell
        
        let rent: Model
        if isFiltering() {
            rent = filteredRent[indexPath.row]
        } else {
            rent = list[indexPath.row]
        }
        cell.nameLabel?.text = rent.title
        cell.addressLabel?.text = rent.address
        cell.moneyLabel?.text = rent.money

        
        
        print("\(rent.title):\(rent.imgPath)")
        
        if let rentImageUrl = rent.imgPath{
            let url = URL(string: rentImageUrl)
            URLSession.shared.dataTask(with:url!,completionHandler:{(data,response,error) in
                if error != nil{
                    print(error)
                    return
                }
                
                DispatchQueue.main.async {
                    cell.rentImage.image = UIImage(data:data!)
                }
                
            }).resume()
            
        }
        return cell
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sortList[row]
    }
    
    func showPickerView(){
        self.view.addSubview(self.sortView)
        self.searchTableView?.isScrollEnabled = false
        self.sortView.frame.origin.y = self.view.frame.height
        self.sortView.bounds = CGRect(x: 0, y: self.sortView.bounds.origin.y, width: UIScreen.main.bounds.width, height: self.sortView.bounds.height)
        self.sortView.frame.origin.x = 0
        sortView.layer.cornerRadius = 10
        UIView.animate(withDuration: 0.5){
            self.sortView.frame.origin.y = self.view.frame.height-self.sortView.frame.height
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func sortDone(_ sender: Any) {
        self.sortView.removeFromSuperview()
        self.searchTableView?.isScrollEnabled = true
    }
    
    @IBAction func sort(_ sender: Any) {
        self.showPickerView()
    }
    //prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "detail" {
            if let indexPath = searchTableView.indexPathForSelectedRow{
                if isFiltering() {
                    let rentList: Model
                    rentList = filteredRent[indexPath.row]
                    let destinationController = segue.destination as! DetailTableViewController
                    destinationController.id = rentList.id!
                    destinationController.uid = rentList.uid!
                } else {
                    let rentList: Model
                    rentList = list[indexPath.row]
                    let destinationController = segue.destination as! DetailTableViewController
                    destinationController.id = rentList.id!
                    destinationController.uid = rentList.uid!
                }
                
                
            }
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        areaMessageField.text = list[row]
//        if areaMessageField.text == list[0]{
//            areaMessageField.text = ""
//        }
    }
    
    // MARK: - Peek and Pop 3d touch
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = tableView.indexPathForRow(at: location) else {
            return nil
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return nil
        }
        
        guard let SystemMessageDetailViewController = storyboard?.instantiateViewController(withIdentifier: "DetailTableViewController") as? DetailTableViewController else {
            return nil
        }
        
        //let selectedFilteredRent = [indexPath.row]
        //DetailTableViewController = selectedFilteredRent
        
        //DetailTableViewController
        
        //let selectedSystemMessage2 = systemMessageTitle[indexPath.row]
       //DetailTableViewController.= selectedFilteredRent
        
        //SystemMessageDetailViewController.systemMessage = selectedSystemMessage
        //SystemMessageDetailViewController.systemMessageTitle = selectedSystemMessage2
       //DetailTableViewController.preferredContentSize = CGSize(width: 0.0, height: 450.0)
        previewingContext.sourceRect = cell.frame
        
        return SystemMessageDetailViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
}





