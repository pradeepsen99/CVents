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

class EventPageController: UIViewController {
    
    let locationManager = CLLocationManager()
    
    var currentGroupMembers: String
    var eventName: String
    var latitude: Double
    var longitude: Double
    
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

        
    }
    
}
