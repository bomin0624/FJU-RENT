//
//  ViewController.swift
//  FJU-RENT
//
//  Created by Bomin on 2017/7/4.
//  Copyright © 2017年 Bomin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleMaps

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    let ref = Database.database().reference(fromURL: "https://fju-rent-823a2.firebaseio.com/")
        ref.updateChildValues(["somevalue": 123123])
        
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: 25.035421, longitude: 121.432468, zoom: 15.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 25.035421, longitude: 121.432468)
        marker.title = "FJU"
        marker.snippet = "Taiwan"
        marker.map = mapView

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

