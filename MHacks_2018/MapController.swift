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
    
    var phoneNumbersArr: Array<String> = Array()
    var phoneNumberLatArr: Array<Double> = Array()
    var phoneNumberLongArr: Array<Double> = Array()
    var phoneNumberNameArr: Array<String> = Array()
    
    var eventsIDArr: NSArray = []
    var eventsNameArr: NSArray = []
    var eventsLatArr: NSArray = []
    var eventsLongArr: NSArray = []
    var eventsUsersArr: NSArray = []
    
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
        let eventRef = rootRef.child("Users")
        //eventRef.setValue("6307061275")
        
        let messageDB = Database.database().reference().child("Users")
        
        messageDB.observe(.childAdded, with: { snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            let number = snapshotValue["number"] as! String
            print(number)
            self.phoneNumbersArr.append(number)
            let name = snapshotValue["name"] as! String
            self.phoneNumberNameArr.append(name)
            let lat = snapshotValue["lat"] as! Double
            self.phoneNumberLatArr.append(lat)
            let long = snapshotValue["long"] as! Double
            self.phoneNumberLongArr.append(long)
        })
        print(phoneNumberLongArr.count)
        
        //let itemsRef = rootRef.child("grocery-items")
        
        let messagesDB = Database.database().reference().child("Users")
        
        let messageDictionary : NSDictionary = ["number" : "6307061275", "name" : "testbob", "lat": 1.0, "long": 1.0]
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, ref) in
            if error != nil {
                print(error!)
            }
            else {
                print("Message saved successfully!")
            }
        }
        print(phoneNumberLongArr[1])
    }
    
    
}

