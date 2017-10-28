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

class MutiMarkerViewController: UIViewController, GMSMapViewDelegate  {
    //test
    let flag = true
    
    @IBOutlet weak var mapView: GMSMapView!
    //var mapView: GMSMapView?
    @IBOutlet weak var markerDetail: UIView!
    
    var markers: [GMSMarker]?
    
    @IBOutlet weak var rentName: UITextField!
    @IBOutlet weak var rentAddress: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        markerDetail.isHidden = true
        // Do any additional setup after loading the view.
        var camera = GMSCameraPosition.camera(withLatitude: 25.035382, longitude: 121.432368, zoom: 14, bearing: 0, viewingAngle: 0)
        //mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView?.camera = camera
        mapView?.mapType = GMSMapViewType(rawValue: UInt(IPPROTO_SATMON))!
        //kGMSTypeSatellite
        mapView?.isMyLocationEnabled = true
        mapView?.settings.compassButton = true
        mapView?.settings.myLocationButton = true
        mapView?.setMinZoom(10, maxZoom: 18)
        //view.addSubview(mapView!)
        
        
        setupMarkerData()
        self.mapView?.delegate = self
    }
    
    func setupMarkerData() {
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
        drawMarkers()
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        initMarkerImge()
        marker.icon = GMSMarker.markerImage(with: UIColor.red)
        if markerDetail.isHidden{
            markerDetail.isHidden = false
        }else {
            markerDetail.isHidden = true
        }
        rentName.text = marker.title
        rentAddress.text = marker.snippet
        
        if flag{
            print(marker.title)
            print(marker.snippet)
        }
       
        return true
    }
    
    func drawMarkers() {
        for marker: GMSMarker in markers! {
            if marker.map == nil {
                marker.map = mapView
            }
        }
    }
    
    func initMarkerImge(){
        for marker: GMSMarker in markers! {
            marker.icon = UIImage(named: "home(50X50)")
            
        }
    }
    
    //Mark: -if true, hide time and power
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        mapView?.padding = UIEdgeInsetsMake(topLayoutGuide.length + 5, 0, bottomLayoutGuide.length + 5, 0)
    }
    
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchResult" {
            
            let destinationController = segue.destination as! RentSearchTableViewController
            //send search text
            destinationController.searchText = rentName.text!
            //send condition
            //destinationController.detailDict = detailDict
            
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
