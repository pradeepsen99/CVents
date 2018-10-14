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

class ActivitiesController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventNameArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        cell.textLabel!.text = "\(eventNameArr[indexPath.row])"
        return cell
    }
    
    var stopTableView: UITableView!
    
    let locationManager = CLLocationManager()
    
    var ref: DatabaseReference!
    
    var eventsUserPhoneArr: Array<String> = ["0123456789", "0987654321"]
    var eventLatArr: Array<Double> = [1.0, 1.1]
    var eventLongArr: Array<Double> = [1.0, 1.1]
    var eventNameArr: Array<String> = ["Project #1","Project #2"]
    
    var downloadComplete: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("hi")
        
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
        
        self.navigationController?.navigationBar.topItem?.title = "Activities"
        
        self.getData()

        displayTable()
    }
    
    func displayTable(){
        let barHeight: CGFloat = 0
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        self.stopTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        self.stopTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        self.stopTableView.dataSource = self
        self.stopTableView.delegate = self
        self.stopTableView.separatorStyle = .none
        view.addSubview(self.stopTableView)
    }
    
    func createData(Users: String, name: String, lat: Double, long: Double){
        let messagesDB = Database.database().reference().child("Events")
        let messageDictionary : NSDictionary = ["Users" : Users, "name" : name, "lat": lat, "long": long]
        
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
        
        //Resets the arrays before adding.

        
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
            print(self.eventsUserPhoneArr.count)
        })
        downloadComplete = true
    }
}


