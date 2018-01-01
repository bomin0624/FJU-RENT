//
//  MutiMarkerViewController.swift
//  FJU-RENT
//
//  Created by WZH on 2017/10/2.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import Firebase
import FirebaseDatabase

class MutiMarkerViewController: UIViewController, GMSMapViewDelegate  {
    
    //test and print
    let flag = false
    
    //segue from favorite TableViewController
    var rentList:[Model]?
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var markerDetail: UIView!
    @IBOutlet weak var rentName: UITextField!
    @IBOutlet weak var rentAddress: UITextField!
    @IBOutlet weak var rentImageView: UIImageView!
    
    
    var markers = [GMSMarker]()
    var keyList = [String]()
    var markerList = [Amarker]()
    var id = ""
    var uid = ""
    var rentImageUrl = ""
    var longitude : Double?
    var latitude : Double?
    
    
    var orginLatitude : Double?
    var orginLongitude : Double?
    
    var placesClient: GMSPlacesClient!
    
    //init route path
    var snackLine = GMSPolyline()
    
    var userCreatedMarker: GMSMarker?
    
    //set up init markers: orgin & destination
    var orgin = GMSMarker()
    var destination = GMSMarker()
    var markersDirection = [GMSMarker]()
    
    var camera : GMSCameraPosition?
    var centerLatitude:Double?
    var centerLongitude:Double?
    
    
    func setId(id:String) -> Void{
        self.id = id
    }
    func setUid(uid:String) -> Void{
        self.uid = uid
    }
    func setRentImageUrl(rentImageUrl:String) -> Void{
        self.rentImageUrl = rentImageUrl
    }
    
    func setLongitude(longitude:Double) -> Void{
        if  longitude == longitude{
            self.longitude = longitude
        }
        
        
    }
    
    func setLatitude(latitude:Double) -> Void{
        if  latitude == latitude{
            self.latitude = latitude
        }
        
    }
    func setOrginLongitude(orginLongitude:Double) -> Void{
        if  orginLongitude == orginLongitude{
            self.orginLongitude = orginLongitude
        }
        
    }
    
    func setOrginLatitude(orginLatitude:Double) -> Void{
        if  orginLatitude == orginLatitude{
            self.orginLatitude = orginLatitude
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        placesClient = GMSPlacesClient.shared()
        
        markerDetail.isHidden = true
        // Do any additional setup after loading the view.
        if centerLatitude == nil && centerLongitude == nil{
            camera = GMSCameraPosition.camera(withLatitude: 25.035382, longitude: 121.432368, zoom: 14, bearing: 0, viewingAngle: 0)
        }else{
            camera = GMSCameraPosition.camera(withLatitude: centerLatitude!, longitude: centerLongitude!, zoom: 14, bearing: 0, viewingAngle: 0)
            
        }
        //mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView?.camera = camera!
        mapView?.mapType = GMSMapViewType(rawValue: UInt(IPPROTO_SATMON))!
        //kGMSTypeSatellite
        mapView?.isMyLocationEnabled = true
        mapView?.settings.compassButton = true
        mapView?.settings.myLocationButton = true
        mapView?.setMinZoom(10, maxZoom: 18)
        //view.addSubview(mapView!)
        
        Database.database().reference().child("location").observeSingleEvent(of: .value, with: { (snapshot) in
            
            
            if snapshot.childrenCount > 0{
                
                for rents in snapshot.children.allObjects as! [DataSnapshot]{
                    
                    let rentKey = rents.key as! String
                    self.keyList.append(rentKey)
                }
                
                if self.flag{
                    print(self.keyList)
                }
                
                
                for key in self.keyList{
                    
                    if self.flag{
                        print("key:\(key)")
                    }
                    
                    let databaseRef = Database.database().reference().child("location").child(key)
                    databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if snapshot.childrenCount > 0{
                            
                            for rents in snapshot.children.allObjects as! [DataSnapshot]{
                                let rentObject = rents.value as? [String: Any]
                                
                                let rentId = rentObject?["id"] as! String
                                let rentUid = rentObject?["uid"] as! String
                                let rentTitle = rentObject?["title"] as! String
                                let rentAddress = rentObject?["address"] as! String?
                                let latitude = rentObject?["latitude"] as! Double?
                                let longitude = rentObject?["longitude"] as! Double?
                                
                                let rentImgStorage = rentObject?["imgStorage"] as? NSDictionary
                                let imgDict = rentImgStorage?.allValues[0] as! [String : Any]
                                let rentUniString = imgDict["imgName"] as! String
                                let rentImg = imgDict["imgUrl"] as! String
                                
                                //temp debug
                                if latitude == nil || longitude == nil{
                                    if self.flag {
                                        print("此筆資料:\(rentTitle)無經緯度")
                                    }
                                    
                                }else{
                                    if self.flag {
                                        print("此筆資料存在:\(rentTitle)")
                                        print("rentImge:\(rentImg)")
                                    }
                                    //修改model
                                    let aMarker = Amarker.init(id: rentId, uid: rentUid, latitude: latitude, longitude: longitude, title: rentTitle, snippet: rentAddress, imgPath:rentImg)
                                    self.markerList.append(aMarker)
                                }
                                
                            }
                            
                        }
                        
                        let keyLength = self.keyList.count
                        let lastKeyValue = self.keyList[keyLength-1]
                        //Marker:- make sure at the last data
                        if key == lastKeyValue {
                            if self.rentList != nil{
                                for rent in self.rentList!{
                                    let marker = GMSMarker()
                                    marker.position = CLLocationCoordinate2DMake(rent.latitude!, rent.longitude!)
                                    marker.title = rent.title
                                    marker.snippet = rent.address
                                    marker.map = self.mapView
                                    marker.icon = UIImage(named:"home(50X50)")
                                    self.markers.append(marker)
                                }
                                
                            }else{
                                
                            for aMarker in self.markerList{
                                if self.flag{
                                    print("marker標題\(aMarker.title)")
                                }
                                
                                    
                                
                                    let marker = GMSMarker()
                                    marker.position = CLLocationCoordinate2DMake(aMarker.latitude!, aMarker.longitude!)
                                    marker.title = aMarker.title
                                    marker.snippet = aMarker.snippet
                                    marker.map = self.mapView
                                    marker.icon = UIImage(named:"home(50X50)")
                                    self.markers.append(marker)
                                
                                }
                            }
                        }
                        
                    })
                    
                    
                    
                }
                
                
            }
            
            
        })
        
        
        //setupMarkerData()
        self.mapView?.delegate = self
        
        print("rentList:\(rentList)")
        
    }
    
    //test data
    func setupMarkerData() {
        
        //let aMarker1 = Amarker.init(id: "-KuUJBZnbnXL7F8Wt3UN", uid: "TphogRW0BxbNba70pma67Pxs9TA2", latitude: 25.034930, longitude: 121.430816, title: "輔仁大學立言學苑", snippet: "輔仁大學立言學苑", map: nil, icon: "home(50X50)")
        //markerList.append(aMarker1)
        
        //let aMarker2 = Amarker.init(id: "-KuJ31i-3X0uoxGg5uiT", uid: "TphogRW0BxbNba70pma67Pxs9TA2", latitude: 25.033307, longitude: 121.436122, title: "輔仁大學附近離學校步行5分鐘雅房出租", snippet: "新北市新莊區中正路508巷5弄7號", map: nil, icon: "home(50X50)")
        //markerList.append(aMarker2)
        
        let marker1 = GMSMarker()
        marker1.position = CLLocationCoordinate2DMake(25.033307, 121.436122)
        marker1.title = "輔仁大學附近離學校步行5分鐘雅房出租"
        marker1.snippet = "新北市新莊區中正路508巷5弄7號"
        marker1.map = nil
        marker1.icon = UIImage(named: "home(50X50)")
        
        let marker2 = GMSMarker()
        marker2.position = CLLocationCoordinate2DMake(25.034930, 121.430816)
        marker2.title = "輔仁大學立言學苑"
        marker2.snippet = "輔仁大學立言學苑"
        marker2.map = nil
        marker2.icon = UIImage(named: "home(50X50)")
        markers = [marker1, marker2]
        //drawMarkers()
    }
    
    func drawMarkers(markers:[GMSMarker]) {
        for marker: GMSMarker in markers {
            if marker.map == nil {
                marker.map = mapView
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        initMarkerImge()
        
        self.destination = marker
        marker.icon = GMSMarker.markerImage(with: UIColor.red)
        
        markerDetail.isHidden = false
        
        rentName.text = marker.title
        rentAddress.text = marker.snippet
        
        let rentTitle = rentName.text
        for aMarker in markerList{
            if aMarker.title == rentTitle {
                
                let id = aMarker.id
                let uid = aMarker.uid
                let imgPath = aMarker.imgPath
                let latitude = aMarker.latitude
                let longitude = aMarker.longitude
                
                setId(id: id!)
                setUid(uid: uid!)
                setRentImageUrl(rentImageUrl: imgPath!)
                setLatitude(latitude: latitude!)
                setLongitude(longitude: longitude!)
            }
        }
        
        
        let url = URL(string: rentImageUrl)
        URLSession.shared.dataTask(with:url!,completionHandler:{(data,response,error) in
            if error != nil{
                print(error)
                return
            }
            
            DispatchQueue.main.async {
                
                self.rentImageView.image = UIImage(data:data!)
            }
            
        }).resume()
        
        if flag{
            print(marker.title)
            print(marker.snippet)
        }
        
        return true
    }
    
    
    //Mark:- clean the map
    func initMarkerImge(){
        
        for marker: GMSMarker in markers {
            marker.icon = UIImage(named: "home(50X50)")
            
        }
        //clean the route
        let points : String = ""
        OperationQueue.main.addOperation {
            
            let path = GMSPath.init(fromEncodedPath: points)
            self.snackLine.map = nil
            self.snackLine = GMSPolyline(path: path)
            self.snackLine.map = self.mapView
            
        }
        
    }
    
    @IBAction func directionButton(_ sender: Any) {
        if self.flag{
            print("路徑規劃！")
        }
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    if self.flag{
                        print("place.name：\(place.name)")
                        print(place.coordinate.latitude)
                        print(place.coordinate.longitude)
                    }
                    
                    self.setOrginLatitude(orginLatitude:place.coordinate.latitude )
                    self.setOrginLongitude(orginLongitude: place.coordinate.longitude)
                    
                    let marker = CSMarker()
                    marker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
                    marker.title = place.name
                    
                    self.orgin = marker
                    self.drawRoute()
                }
            }
        })
        
        
    }
    
    //set orgin & destination
    func setupMarkerData(_ orginMarker:GMSMarker,_ destinationMarker:GMSMarker) -> [GMSMarker]{
        
        markersDirection = [orginMarker,destinationMarker]
        return markersDirection
        
    }
    
    //draw route and markers
    func drawRoute(){
        
        cleanTheMap()
        //set up orgin & destination : latitude & longitude
        let markers = setupMarkerData(self.orgin, self.destination)
        drawMarkers(markers: markersDirection)
        let orgin = markersDirection[0] as GMSMarker
        let destination = markersDirection[1] as GMSMarker
        let orginLatitude = orgin.position.latitude
        let orginLongitude = orgin.position.longitude
        let destinationLatitude = destination.position.latitude
        let destinationLongitude = destination.position.longitude
        
        //set up googleMaps direction API key
        let googleMapsDirectionApiKey = "AIzaSyCUpgytJP4Ilh5f9lihAp0QaInZG0pBSrc"
        
        //set up url for fetching json from googleMaps
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(orginLatitude), \(orginLongitude)&destination=\(destinationLatitude), \(destinationLongitude)&mode=walking&key=" + googleMapsDirectionApiKey
        
        let actualURL = URL(string: url.urlEncoded())
        
        //fetch json from googleMaps
        let session = URLSession.shared.dataTask(with: actualURL!) { (data:Data?, response:URLResponse?, error:Error?) in
            if let data = data{
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                    print(json)
                    
                    // Extract distance and time
                    let status = json?["status"] as? String
                    let routes = json?["routes"] as? [[String:Any]]
                    for route in routes!{
                        let copyrights = route["copyrights"] as? String
                        let overview_polyline = route["overview_polyline"] as? [String:Any]
                        let points = overview_polyline?["points"] as? String
                        
                        //drawRoute
                        OperationQueue.main.addOperation {
                            
                            let path = GMSPath.init(fromEncodedPath: points!)
                            self.snackLine.map = nil
                            self.snackLine = GMSPolyline(path: path)
                            
                            self.snackLine.strokeWidth = 5 // stroke width : 5
                            self.snackLine.strokeColor = UIColor.blue //draw blue line
                            self.snackLine.map = self.mapView
                        }
                    }
                    
                    //print status
                    if let status:String = status {
                        print("status:\(status)")
                    }
                    
                } catch {
                    print(error)
                }
                
            }
        }
        session.resume()
        
    }
    
    //clean the route and marker on map
    func cleanTheMap(){
        for var marker in markers{
            marker.map = nil
        }
        
        //delete the current marker
        if (self.userCreatedMarker != nil) {
            self.userCreatedMarker?.map = nil
            self.userCreatedMarker = nil
        }
        //clean the route
        let points : String = ""
        OperationQueue.main.addOperation {
            
            let path = GMSPath.init(fromEncodedPath: points)
            self.snackLine.map = nil
            self.snackLine = GMSPolyline(path: path)
            self.snackLine.map = self.mapView
            
        }
    }
    
    func getCurrentPlace() -> Void{
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    if self.flag{
                        print("place.name：\(place.name)")
                        print(place.coordinate.latitude)
                        print(place.coordinate.longitude)
                    }
                    print("place.name：\(place.name)")
                    print(place.coordinate.latitude)
                    print(place.coordinate.longitude)
                    self.setOrginLatitude(orginLatitude:place.coordinate.latitude )
                    self.setOrginLongitude(orginLongitude: place.coordinate.longitude)
                    
                    let marker = CSMarker()
                    marker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
                    marker.title = place.name
                    
                    self.orgin = marker
                    
                }
            }
        })
    }
    
    //Mark:- cancel the view
    @IBAction func cancelButton(_ sender: Any) {
        
        initMarkerImge()
        markerDetail.isHidden = true
        
    }
    
    
    //Mark:- if true, hide time and power
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    //Mark:- setting the attribution of map
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        mapView?.padding = UIEdgeInsetsMake(topLayoutGuide.length + 5, 0, bottomLayoutGuide.length + 5, 0)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            
            let destinationController = segue.destination as! DetailTableViewController
            
            
            destinationController.id = id
            destinationController.uid = uid
            
            
        }
        
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// extension String func: url encoded & url decoded
extension String {
    
    //将原始的url编码为合法的url
    func urlEncoded() -> String {
        let encodeUrlString = self.addingPercentEncoding(withAllowedCharacters:
            .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
    
    //将编码后的url转换回原始的url
    func urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }
}
