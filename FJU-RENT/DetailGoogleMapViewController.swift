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

    
    @IBOutlet weak var googleMapsView: GMSMapView!
    
    var userCreatedMarker: CSMarker?
    
    //init marker session
    var markerSession: URLSession?

    var address = ""
    
    var longitude : Double?
    var latitude : Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
       
        
        fetchTheAddressInMap()
        //initPositioningAt()
        //downloadMarkerData(address)
      
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
        displayMarker()
        
        
        
        
        
        
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

    
    @IBAction func cancel(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)

    }
    
    
    

}
