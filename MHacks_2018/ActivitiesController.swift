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
import Foundation
import Alamofire


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
    
    var tempArr: Array<String> = Array()
    
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

        //sendSMS(numToSend: "6307061275")
        
        displayTable()
        
    }
    
//    func buttonConfig(){
//        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
//        button.backgroundColor = .green
//        button.setTitle("Test Button", for: .normal)
//        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
//
//        self.view.addSubview(button)
//    }
//
    
    
    func sendSMS(numToSend: String)
    {
        
        let twilioSID = "AC227456c7709f73c9822614f1ad01ade3"
        let twilioSecret = "262db79790cdfcf98b96b6e7881fc46e"
        
        //Note replace + = %2B , for To and From phone number
        let fromNumber = "%2B16307934370"// actual number is +14803606445
        let toNumber = "%2B1"+numToSend// actual number is +919152346132
        let message = "One of your friends have invited you to join one of their events. Open up CVents to check it out!"
        
        // Build the request
        let request = NSMutableURLRequest(url: NSURL(string:"https://\(twilioSID):\(twilioSecret)@api.twilio.com/2010-04-01/Accounts/\(twilioSID)/SMS/Messages")! as URL)
        request.httpMethod = "POST"
        request.httpBody = "From=\(fromNumber)&To=\(toNumber)&Body=\(message)".data(using: String.Encoding.utf8)
        
        // Build the completion block and send the request
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            print("Finished")
            if let data = data, let responseDetails = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                // Success
                print("Response: \(responseDetails)")
            } else {
                // Failure
                print("Error: \(error)")
            }
        }).resume()
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
            self.checkNumbers(numbers: numbers!)
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
        self.stopTableView.separatorStyle = .singleLine
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
        
        
        let messageDB2 = Database.database().reference().child("Users")
        messageDB2.observe(.childAdded, with: { snapshot in
            
            let snapshotValue = snapshot.value as! NSDictionary
            
            let number = snapshotValue["number"] as! String
            self.tempArr.append(number)
            
        })
        downloadComplete = true
    }
    
    func checkNumbers(numbers: String){
        let trimmedString = numbers.trimmingCharacters(in: .whitespaces)
        print(trimmedString)
        let trimStrArr: Array<String> = trimmedString.components(separatedBy: ",")
        print(trimStrArr.count)
        var numFinArr: Array<String> = Array()
        for numbers in trimStrArr{
            print("NUMBERS STR: " + numbers.count.description)
            if(numbers.count == 10){
                numFinArr.append(numbers)
            }
        }
        print("PICKLE 2")
        
        print("PICKLE 1")
        print(tempArr.count)
        print(numFinArr.count)
        for nums in numFinArr{
            var tempSwitch: Bool = false
            print("NUM: " + nums.description)
            for nums2 in tempArr{
                print("NUM2: " + nums2.description)
                if(nums == nums2){
                    tempSwitch = true
                }
            }
            
            if(tempSwitch){
                sendSMS(numToSend: nums)
            }
        }

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


