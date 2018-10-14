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
import MapKit
import CoreLocation


class MapController: UIViewController, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()

    
    @IBOutlet weak var mainMap: MKMapView!
    
    var eventsUserPhoneArr: Array<String> = Array()
    var eventLatArr: Array<Double> = Array()
    var eventLongArr: Array<Double> = Array()
    var eventNameArr: Array<String> = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For use when the app is open
        DispatchQueue.main.async {
            //Requests the user to provide access to use their location.
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        self.mainMap.showsUserLocation = true
        
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self as? CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        self.navigationController?.navigationBar.topItem?.title = "Map"
        
        
        getData()
        
    }
    
    func getData(){
        let messageDB = Database.database().reference().child("Events")
        
        //Resets the arrays before adding.
        eventsUserPhoneArr.removeAll()
        eventNameArr.removeAll()
        eventLatArr.removeAll()
        eventLongArr.removeAll()
        
        messageDB.observe(.childAdded, with: { snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            let users = snapshotValue["Users"] as! String
            self.eventsUserPhoneArr.append(users)
            let name = snapshotValue["name"] as! String
            self.eventNameArr.append(name)
            let lat = snapshotValue["lat"] as! Double
            self.eventLatArr.append(lat)
            let long = snapshotValue["long"] as! Double
            self.eventLongArr.append(long)
            print("Lat:"+lat.description+" "+"Long:"+long.description)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = lat
            annotation.coordinate.longitude = long
            annotation.title = name
            self.mainMap.addAnnotation(annotation)
        })
    }
    
}
