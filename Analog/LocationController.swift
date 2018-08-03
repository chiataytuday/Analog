//
//  LocationController.swift
//  Analog
//
//  Created by Zizhou Wang on 2018/7/20.
//  Copyright © 2018 Zizhou Wang. All rights reserved.
//

import Foundation
import CoreLocation


class LocationController: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.distanceFilter = 100
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            self.currentLocation = currentLocation
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status != .authorizedWhenInUse {
            currentLocation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        currentLocation = nil
    }
}
