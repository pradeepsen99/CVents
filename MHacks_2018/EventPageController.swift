//
//  EventPageController.swift
//  MHacks_2018
//
//  Created by Pradeep Kumar on 10/13/18.
//  Copyright © 2018 Pradeep Kumar. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import MapKit

class EventPageController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numFinArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        cell.textLabel!.text = "\(numFinArr[indexPath.row])"
        return cell
    }
    
    let locationManager = CLLocationManager()
    
    var currentGroupMembers: String
    var eventName: String
    var latitude: Double
    var longitude: Double
    
    var eventsUserPhoneArr: Array<String> = Array()
    var eventLatArr: Array<Double> = Array()
    var eventLongArr: Array<Double> = Array()
    var eventNameArr: Array<String> = Array()
    
    var numFinArr: Array<String> = Array()
    
    fileprivate var stopTableView: UITableView!

    
    init(Users: String, name: String, lat: Double, long: Double){
        currentGroupMembers = Users
        eventName = name
        latitude = lat
        longitude = long
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        self.navigationController?.navigationBar.topItem?.title = eventName
        splitNums(numbers: currentGroupMembers)
        displayTable()
        
    }
    
    /// Displays the table using the given values.
    func displayTable(){
        let barHeight: CGFloat = 0
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        self.stopTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight/2))
        self.stopTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        self.stopTableView.dataSource = self
        self.stopTableView.delegate = self
        self.stopTableView.separatorStyle = .singleLine
        view.addSubview(self.stopTableView)
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
            //self.tempArr.append(number)
            
        })
    }
    
    func splitNums(numbers: String){
        let trimmedString = numbers.trimmingCharacters(in: .whitespaces)
        print(trimmedString)
        let trimStrArr: Array<String> = trimmedString.components(separatedBy: ",")
        print(trimStrArr.count)
        
        for numbers in trimStrArr{
            print("NUMBERS STR: " + numbers.count.description)
            if(numbers.count == 10){
                numFinArr.append(numbers)
            }
        }
    }

}
