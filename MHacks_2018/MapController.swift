//
//  ViewController.swift
//  MHacks_2018
//
//  Created by Pradeep Kumar on 10/13/18.
//  Copyright © 2018 Pradeep Kumar. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class MapController: UIViewController {

    let locationManager = CLLocationManager()
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For use when the app is open
        DispatchQueue.main.async {
            //Requests the user to provide access to use their location.
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self as? CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        self.navigationController?.navigationBar.topItem?.title = "Map"
        
        let rootRef = Database.database().reference()
        print(rootRef.key)

        //let itemsRef = rootRef.child("grocery-items")
        

    }


}

