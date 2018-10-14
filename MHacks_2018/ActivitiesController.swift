//
//  ActivitiesController.swift
//  MHacks_2018
//
//  Created by Pradeep Kumar on 10/13/18.
//  Copyright © 2018 Pradeep Kumar. All rights reserved.
//
import UIKit
import CoreLocation
import Firebase

class ActivitiesController: UIViewController {
    
    let locationManager = CLLocationManager()
    
    var ref: DatabaseReference!
    
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
            getData()
        }
        
        // If location services is enabled get the users location
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self as? CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        self.navigationController?.navigationBar.topItem?.title = "Activities"
        
        let rootRef = Database.database().reference()
        let eventRef = rootRef.child("Events")
        
        
        
        
        
        
        
        
        
        
    }
    
    func createData(Users: String, name: String, lat: Double, long: Double){
        let messagesDB = Database.database().reference().child("Events")
        let messageDictionary : NSDictionary = ["Users" : "0123456789,0987654321", "name" : "testbob", "lat": 1.0, "long": 1.0]
        
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, ref) in
            if error != nil {
                print(error!)
            }
            else {
                print("Message saved successfully!")
            }
        }
        
    }
    
    func getData(){
        let messageDB = Database.database().reference().child("Events")
        
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
        })
    }
}


