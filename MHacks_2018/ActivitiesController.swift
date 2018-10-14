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
    
    var eventsUserPhoneArr: Array<String> = Array()
    var eventLatArr: Array<Double> = Array()
    var eventLongArr: Array<Double> = Array()
    var eventNameArr: Array<String> = Array()
    
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
        
        self.navigationController?.navigationBar.topItem?.title = "Map"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(showInputDialog))

        
        self.getData()

        displayTable()
    }

    
    
    @objc func showInputDialog(){
        //Creating UIAlertController and
        //Setting title and message for the alert dialog
        let alertController = UIAlertController(title: "Enter details?", message: "Enter your name and email", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            //getting the input values from user
            let name = alertController.textFields?[0].text
            let lat = alertController.textFields?[1].text
            let long = alertController.textFields?[2].text
            let numbers = alertController.textFields?[3].text
           
            self.createData(Users: numbers!, name: name!, lat: Double(lat!)!, long: Double(long!)!)
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        //adding textfields to our dialog box
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Name"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Latitude"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Longitude"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Enter Numbers seperated by commas"
        }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
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
            print(self.eventsUserPhoneArr.count)
            self.stopTableView.reloadData()
        })
        downloadComplete = true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        eventViewer(Users: eventsUserPhoneArr[indexPath.row], name: eventNameArr[indexPath.row], lat: eventLatArr[indexPath.row], long: eventLongArr[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ActivitiesController{
    func eventViewer(Users: String, name: String, lat: Double, long: Double){
        navigationController?.pushViewController(EventPageController(Users: Users, name: name, lat: lat, long: long), animated: true)
    }
}


