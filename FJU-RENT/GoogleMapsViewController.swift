//
//  GoogleMapsViewController.swift
//  FJU-RENT
//
//  Created by WZH on 2017/8/30.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker

//extend GMSMarker func: isEqual,hash
class CSMarker: GMSMarker {
    
    var objectID: String = ""
    
    override func isEqual(_ object: Any?) -> Bool {
        var otherMarker: CSMarker? = (object as? CSMarker)
        if objectID == otherMarker?.objectID {
            return true
        }
        return false
    }
    override var hash: Int {
        return objectID.hash
    }
    
    
    
}

enum Location {
    case startLocation
    case destinationLocation
    case justSearch
}

class GoogleMapsViewController: UIViewController, CLLocationManagerDelegate , GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate {
    
    var locationSelected = Location.startLocation
    
    //set up init markers: orgin & destination
    var orgin = CSMarker()
    var destination = CSMarker()
    var addMarker = CSMarker()
    
    // OUTLETS
    @IBOutlet weak var googleMapsView: GMSMapView!
    
    //positioning
    var locationManager = CLLocationManager()
    
    //init marker in Set
    var markers = [CSMarker]()
    
    //触屏显示
    var userCreatedMarker: CSMarker?
    
    //init marker session
    var markerSession: URLSession?
    
    //init route path
    var snackLine = GMSPolyline()
    
    
    //draw route auto
    //    @IBOutlet weak var selectOrgin: UITextField!
    //    @IBOutlet weak var selectDestination: UITextField!
    @IBOutlet weak var selectOrgin: UIButton!
    
    @IBOutlet weak var selectDestination: UIButton!
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    var homeMarkers = [CSMarker]()
    
    var placesClient: GMSPlacesClient!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    
    
    
    
    var marker1 = CSMarker()
    var marker2 = CSMarker()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placesClient = GMSPlacesClient.shared()
        
        
        //let marker1 = CSMarker()
        //userCreatedMarker?.map = nil
        
        //let marker2 = CSMarker()
        
      
        
        initPositioning()
        
        initPositioningAt()
        
        
        //print("輔仁大學")
        //downloadData("輔仁大學")
        
        //地址轉坐標
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(memoryCapacity: 2 * 1024 * 1024, diskCapacity: 10 * 1024 * 1024, diskPath: "MarkerData")
        markerSession = URLSession(configuration: config)
        
        // Do any additional setup after loading the view.
        
        //userCreatedMarker = marker1
        //displayMarker()
        
        //userCreatedMarker = marker2
        //displayMarker()
        
        
    }
    
    
    
    
    
    
    
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        print(marker.title)
        print(marker.snippet)
        self.nameLabel.text = marker.title
        self.addressLabel.text = marker.snippet
        return true
    }
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print(marker.title)
        print(marker.snippet)
        self.nameLabel.text = marker.title
        self.addressLabel.text = marker.snippet
    }
   
    
    
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        print("You tapped at \(placeID),\(name),\(location.latitude), \(location.longitude)")
    }
    func mapView(_ mapView:GMSMapView, didTapAt coordinate:CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
    }
    
    func setMarkers() -> [CSMarker] {
        
        var markers = [CSMarker]()
        
        let marker1 = CSMarker()
        marker1.position = CLLocationCoordinate2D(latitude: 25.038463, longitude: 121.427593)
        marker1.title = "輔大花園夜市"
        marker1.snippet = "Taiwan"
        marker1.icon = UIImage(named: "home(50X50)")
        //marker1.map = googleMapsView
        markers.append(marker1)
        let marker2 = CSMarker()
        marker2.position = CLLocationCoordinate2D(latitude: 25.034930, longitude:121.430816)
        marker2.title = "輔大立言學苑"
        marker2.snippet = "Taiwan"
        marker2.icon = UIImage(named: "home(50X50)")
        //marker2.map = googleMapsView
        markers.append(marker2)
        
        //25.033307, 121.436122
        let marker3 = CSMarker()
        marker3.position = CLLocationCoordinate2D(latitude: 25.033307, longitude:121.436122)
        marker3.title = "租屋"
        marker3.snippet = "Taiwan"
        marker3.icon = UIImage(named: "home(50X50)")
        //marker3.map = googleMapsView
        markers.append(marker3)
        
        return markers
    }
    
    
    // Add a UIButton in Interface Builder, and connect the action to this function.
    @IBAction func pickPlace(_ sender: UIButton) {
        let center = CLLocationCoordinate2D(latitude: 37.788204, longitude: -122.411937)
        let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001, longitude: center.longitude + 0.001)
        let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001, longitude: center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        let placePicker = GMSPlacePicker(config: config)
        
        placePicker.pickPlace(callback: {(place, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                place.coordinate
                self.nameLabel.text = place.name
                self.addressLabel.text = place.formattedAddress?.components(separatedBy: ", ")
                    .joined(separator: "\n")
            } else {
                self.nameLabel.text = "No place selected"
                self.addressLabel.text = ""
            }
        })
    }
    
    @IBAction func getCurrentPlace(_ sender: UIButton) {
        
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            self.selectOrgin.titleLabel?.text = "No current place"
            //self.addressLabel.text = ""
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    
                    self.selectOrgin.titleLabel?.text = place.name
                    //self.addressLabel.text = place.formattedAddress?.components(separatedBy: ", ")
                    //    .joined(separator: "\n")
                }
            }
        })
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func initPositioning(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.requestAlwaysAuthorization()
    }
    
    //initial positioning at FJU
    func initPositioningAt() {
        
        //Fju location & zoom
        let initLatitude = 25.035382
        let initLongitude = 121.432368
        let zoom : Float = 15.0
        
        let camera = GMSCameraPosition.camera(withLatitude: initLatitude, longitude: initLongitude, zoom: zoom)
        self.googleMapsView.delegate = self
        self.googleMapsView.camera = camera
        self.googleMapsView.isMyLocationEnabled = true
        self.googleMapsView.settings.myLocationButton = true
        
        // Creates a marker in the center of the map.
        let marker = CSMarker()
        marker.position = CLLocationCoordinate2D(latitude: initLatitude, longitude: initLongitude)
        marker.title = "Fu Jen University"
        marker.snippet = "Taiwan"
        //marker.icon = UIImage(named: "home(50X50)")
        //marker.infoWindowAnchor = CGPoint(x:0.5, y:0.5)
        marker.icon = GMSMarker.markerImage(with: UIColor.red)
        
        
        //marker.map = googleMapsView
        
        self.userCreatedMarker = marker
        displayMarker()
        
        //self.orgin = marker
        //self.destination = marker
        
        //display orgin(default)
        //self.selectOrgin.text = marker.title
    }
   
    
    // MARK: CLLocation Manager Delegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while get location \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 15.0)
        
        self.googleMapsView.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
        
    }
    
    // MARK: GMSMapview Delegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.googleMapsView.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
        self.googleMapsView.isMyLocationEnabled = true
        if (gesture) {
            mapView.selectedMarker = nil
        }
        
    }
    
    // MARK: GOOGLE AUTO COMPLETE DELEGATE
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        cleanTheMap()
        
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15.0)
        self.googleMapsView.camera = camera
        self.dismiss(animated: true, completion: nil) // dismiss after select place
        
        
        //set a marker -> destination marker
        //        let marker = CSMarker()
        //        marker.position = place.coordinate
        //        marker.map = nil
        
        //self.destinationMarker = marker
        //self.setupMarkerData(self.orgin, destinationMarker)
        
        //setup the marker
        downloadMarkerData(place.coordinate)
        //        let markers = setupMarkerData(self.orgin, self.destination)
        //        drawMarkers(markers: markers)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
        print("ERROR AUTO COMPLETE \(error)")
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil) // when cancel search
    }
    
    
    
    @IBAction func openSearchAddress(_ sender: UIBarButtonItem) {
        
        
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        // selected location
        locationSelected = .justSearch
        
        self.locationManager.startUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
        
        
    }
    
    @IBAction func openSearchOrginAddress(_ sender: Any) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        // selected location
        locationSelected = .startLocation
        
        self.locationManager.startUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
        
        
        
    }
    
    @IBAction func openSearchDestinationAddress(_ sender: Any) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        // selected location
        locationSelected = .destinationLocation
        
        self.locationManager.startUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
    }
    @IBAction func showtext(_ sender: Any) {
        print("Ok!")
        if gowhere.isHidden {
            gowhere.isHidden = false
        } else {
            gowhere.isHidden = true
        }
        print("OKOK!")
        
    }
    @IBOutlet weak var gowhere: UIView!

    
    //display a marker
    func displayMarker(){
        
        if userCreatedMarker != nil && userCreatedMarker?.map == nil {
            userCreatedMarker?.map = googleMapsView
            googleMapsView?.selectedMarker = userCreatedMarker
            var cameraUpdate = GMSCameraUpdate.setTarget((userCreatedMarker?.position)!)
            googleMapsView?.animate(with: cameraUpdate)
        }
    }
    
    //display all markers
    func drawMarkers(markers: [CSMarker]) {
        for marker: CSMarker in markers {
            if marker.map == nil {
                marker.map = googleMapsView
            }
        }
        
    }
    
    
    //did long press at position and get a marker
    //    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
    //
    //        cleanTheMap()
    //
    //        let geocoder = GMSGeocoder()
    //
    //        geocoder.reverseGeocodeCoordinate(coordinate) { (response:GMSReverseGeocodeResponse?, error:Error?) in
    //
    //
    //            //set a marker -> destination marker
    //            let marker = CSMarker()
    //            marker.position = coordinate
    //            marker.map = nil
    //
    //            self.destination = marker
    //
    //            //self.setupMarkerData(self.destinationMarker, self.destination)
    //
    //            //setup the marker
    //            self.downloadMarkerData(coordinate)
    //
    //        }
    //    }
    
    //set orgin & destination
    func setupMarkerData(_ orginMarker:CSMarker,_ destinationMarker:CSMarker, _ addMarker:CSMarker) -> [CSMarker]{
        
        //markers[0] = orginMarker
        //markers[1] = destinationMarker
        
        
        markers = [orginMarker,destinationMarker,addMarker]
        return markers
        
    }
    
    
    //download marker data using address
    func downloadData(_ address: String) {
        
        
        let url = "https://maps.googleapis.com/maps/api/geocode/json?&address=\(address)"
        let lakesURL = URL(string: url.urlEncoded())
        
        let session : URLSessionDataTask? = markerSession?.dataTask(with: lakesURL!) { (data, response, error) in
            
            if let data = data {
                print(data)
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                    print(json)
                    
                    //createMarkerObjects
//                    OperationQueue.main.addOperation {
//                        self.createMarkerObjects(withJson: json!)
//                    }
                    
                } catch {
                    print(error)
                }
            }
        }
        session?.resume()
        
    }
    
    //download marker data using coordinate
    func downloadMarkerData(_ coordinate: CLLocationCoordinate2D) {
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        let url = "https://maps.googleapis.com/maps/api/geocode/json?&address=\(latitude),\(longitude)"
        let lakesURL = URL(string: url.urlEncoded())
        
        let session : URLSessionDataTask? = markerSession?.dataTask(with: lakesURL!) { (data, response, error) in
            
            if let data = data {
                //print(data)
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                    //print(json)
                    
                    //createMarkerObjects
                    OperationQueue.main.addOperation {
                        self.createMarkerObjects(withJson: json!)
                    }
                    
                } catch {
                    print(error)
                }
            }
        }
        session?.resume()
        
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
        
        let marker = CSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude!, longitude!)
        marker.title = address
        marker.objectID = marker.title!
        marker.snippet = locationType
        
        //newMarker.map = googleMapsView
        //        self.userCreatedMarker = marker
        //        self.displayMarker()
        
        
        //Mark: -add some conditions
        
        // set coordinate to text
        //display destination in textField
        if self.locationSelected == .startLocation {
            self.orgin = marker
            
            self.selectOrgin.titleLabel?.text = marker.title
            //self.selectOrgin.titleLabel?.textColor = UIColor.black
            
            let marker2 = CSMarker()
            marker2.position = CLLocationCoordinate2D(latitude: 25.034930, longitude:121.430816)
            marker2.title = "輔大立言學苑"
            marker2.snippet = "Taiwan"
            marker2.icon = UIImage(named: "home(50X50)")
            self.addMarker = marker2
            
            let markers = setupMarkerData(self.orgin, self.destination, self.addMarker)
            
            drawMarkers(markers: markers)
            
        }else if self.locationSelected == .destinationLocation{
            self.destination = marker
            
            self.selectDestination.titleLabel?.text = marker.title
            //self.selectDestination.titleLabel?.textColor = UIColor.black
            let markers = setupMarkerData(self.orgin, self.destination, self.addMarker)
            drawMarkers(markers: markers)
        } else{
            cleanTheMap()
            self.userCreatedMarker = marker
            displayMarker()
            
            //
            self.addMarker = marker
            let markers = setupMarkerData(self.orgin, self.destination, self.addMarker)
            drawMarkers(markers: markers)
        }
        
        
        
        
        
        
    }
    
    @IBAction func drawRouteButton(_ sender: Any) {
        drawRoute()
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
            self.snackLine.map = self.googleMapsView
            
        }
    }
    
    //draw route and markers
    func drawRoute(){
        
        cleanTheMap()
        //set up orgin & destination : latitude & longitude
        let markers = setupMarkerData(self.orgin, self.destination, self.addMarker)
        drawMarkers(markers: markers)
        let orgin = markers[0] as CSMarker
        let destination = markers[1] as CSMarker
        let orginLatitude = orgin.position.latitude
        let orginLongitude = orgin.position.longitude
        let destinationLatitude = destination.position.latitude
        let destinationLongitude = destination.position.longitude
        
        //set up googleMaps direction API key
        let googleMapsDirectionApiKey = "AIzaSyCUpgytJP4Ilh5f9lihAp0QaInZG0pBSrc"
        
        //set up url for fetching json from googleMaps
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(orginLatitude), \(orginLongitude)&destination=\(destinationLatitude), \(destinationLongitude)&key=" + googleMapsDirectionApiKey
        let actualURL = URL(string: url.urlEncoded())
        
        //fetch json from googleMaps
        let session : URLSessionDataTask = markerSession!.dataTask(with: actualURL!) { (data, response, error) in
            
            if let data = data {
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                    
                    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchResult" {
            
            let destinationController = segue.destination as! RentSearchTableViewController
            //send search text
            destinationController.searchText = nameLabel.text!
            //send condition
            //destinationController.detailDict = detailDict
            
        }
        
    }
    
    
}



