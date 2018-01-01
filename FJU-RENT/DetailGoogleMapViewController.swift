//
//  DetailGoogleMapViewController.swift
//  FJU-RENT
//
//  Created by WZH on 2017/9/8.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker

class DetailGoogleMapViewController:UIViewController,  GMSMapViewDelegate,  CLLocationManagerDelegate  {

    
    
    
    //test and print
    let flag = false
    
    @IBOutlet weak var googleMapsView: GMSMapView!
    
    var userCreatedMarker: CSMarker?
    
    //init marker session
    var markerSession: URLSession?

    var address = ""
    
    var longitude : Double?
    var latitude : Double?
    
    //set up init markers: orgin & destination
    var orgin = GMSMarker()
    var destination = GMSMarker()
    var markersDirection = [GMSMarker]()
    
    //init route path
    var snackLine = GMSPolyline()
    
    var placesClient: GMSPlacesClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        placesClient = GMSPlacesClient.shared()
        
        
        //fetchCurrentPlace()
        if address == ""{
            print("未接收地址")
        }else{
            fetchTheAddressInMap()
        }
        
        //initPositioningAt()
        //downloadMarkerData(address)
        googleMapsView.isMyLocationEnabled = true
        googleMapsView.settings.compassButton = true
        googleMapsView.settings.myLocationButton = true
        
        fetchCurrentPlace()
      
        //地址轉坐標
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: 2 * 1024 * 1024, diskCapacity: 10 * 1024 * 1024, diskPath: "MarkerData")
        markerSession = URLSession(configuration: config)
        
    }

    func mapView(_ mapView:GMSMapView, didTapPOIWithPlaceID placeID:String,
                 name:String, location:CLLocationCoordinate2D) {
        print("You tapped \(name): \(placeID), \(location.latitude)/\(location.longitude)")
    }
   
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  
    func setLongitude(longitude:Double){
        if  longitude == longitude{
            self.longitude = longitude
        }
        
        
    }
    
    func setLatitude(latitude:Double){
        if  latitude == latitude{
            self.latitude = latitude
        }
        
    }
    
    //display a marker
    func displayMarker(){
        
        if userCreatedMarker != nil && userCreatedMarker?.map == nil {
            userCreatedMarker?.map = googleMapsView
            googleMapsView?.selectedMarker = userCreatedMarker
            var cameraUpdate = GMSCameraUpdate.setTarget((userCreatedMarker?.position)!)
            googleMapsView?.animate(with: cameraUpdate)
        }
    }
    
        
    func createMarkerObjects(withJson json: [String:Any]) {
        
        //fetch josn
        let results = json["results"] as? [[String:Any]]
        if (results?.count)! > 0{
            let result = results![0]
            let address = result["formatted_address"] as? String
            let geometry = result["geometry"] as? [String:Any]
            let locationType = geometry?["location_type"] as? String
            let location = geometry?["location"] as? [String:Any]
            let latitude = location?["lat"] as? Double
            let longitude = location?["lng"] as? Double
            
            setLatitude(latitude: latitude!)
            setLongitude(longitude: longitude!)
            
            let camera = GMSCameraPosition.camera(withLatitude: latitude!, longitude: longitude!, zoom: 15.0)
            self.googleMapsView.delegate = self
            self.googleMapsView.camera = camera
            
            
            let marker = CSMarker()
            marker.position = CLLocationCoordinate2DMake(latitude!, longitude!)
            marker.title = self.address
            marker.snippet = address
            
            self.userCreatedMarker = marker
            self.destination = marker
            displayMarker()
        }else{
            let alertController = UIAlertController(title: "載入失敗", message: "網路不穩定或該地址名稱不合法，請重試", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "確定", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)

        }
      
        
        
        
        
        
        
    }
    
    func fetchTheAddressInMap() {
        print("address:\(address)")
        
        // Do any additional setup after loading the view.
        let url = "https://maps.googleapis.com/maps/api/geocode/json?&address=\(self.address)"
        let lakesURL = URL(string: url.urlEncoded())
        
        let session = URLSession.shared.dataTask(with: lakesURL!) { (data:Data?, response:URLResponse?, error:Error?) in
            
        
        //let session : URLSessionDataTask? = markerSession?.dataTask(with: lakesURL!) { (data, response, error) in
            
            if let data = data {
                print(data)
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                    //print(json)
                    
                    //createMarkerObjects
                    OperationQueue.main.addOperation {
                        self.createMarkerObjects(withJson: json!)
                    }
                    
                } catch {
                    print(error)
                    //add
                }
            }
        }
        session.resume()
        
        //print("No session")
        

    }


    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func pickPlace(_ sender: Any) {
        let center = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        
        let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001, longitude: center.longitude + 0.001)
        let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001, longitude: center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        
        let config = GMSPlacePickerConfig(viewport: viewport)
        let placePicker = GMSPlacePicker(config: config)
        //GMSPlaceLikelihood()
        placePicker.pickPlace(callback: {(place, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                //self.nameLabel.text = place.name
                //self.addressLabel.text = place.formattedAddress?.components(separatedBy: ", ")
                //    .joined(separator: "\n")
                print(place.name)
                print(place.types)
                print(place.placeID)
            } else {
                //self.nameLabel.text = "No place selected"
                //self.addressLabel.text = ""
                print("No place selected")
            }
        })
    }

    @IBAction func drawRouteButton(_ sender: Any) {
        
        drawRoute()
    }
    
    //set orgin & destination
    func setupMarkerData(_ orginMarker:GMSMarker,_ destinationMarker:GMSMarker) -> [GMSMarker]{
        
        markersDirection = [orginMarker,destinationMarker]
        return markersDirection
        
    }
    func drawMarkers(markers:[GMSMarker]) {
        for marker: GMSMarker in markers {
            if marker.map == nil {
                marker.map = googleMapsView
            }
        }
    }
    
    //clean the route and marker on map
    func cleanTheMap(){
        
        
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
            self.snackLine.map = self.googleMapsView
            
        }
    }
    
    func fetchCurrentPlace(){
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
                    
                    //self.setOrginLatitude(orginLatitude:place.coordinate.latitude )
                    //self.setOrginLongitude(orginLongitude: place.coordinate.longitude)
                    
                    let marker = CSMarker()
                    marker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
                    marker.title = place.name
                    
                    self.orgin = marker
                    //self.drawRoute()
                }
            }
        })
        

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
                            self.snackLine.map = self.googleMapsView
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

    
    @IBAction func cancel(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)

    }
    
    
    

}
