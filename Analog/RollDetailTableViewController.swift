//
//  RollDetailTableViewController.swift
//  Analog
//
//  Created by Zizhou Wang on 20/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import UIKit
import MapKit

protocol RollDetailTableViewControllerDelegate {
    func editFrames (with frame: Frame?)
}

class RollDetailTableViewController: UITableViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationDetailLabel: UILabel!
    
    //setting up location manager
    let locationManager = CLLocationManager()
    //delegate in order to pass data to the parent
    var delegate: FrameEditingViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting up the location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        //check for authorization and whether location services are available
//        if CLLocationManager.locationServicesEnabled() == true &&
//            CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
//            
//            locationManager.startUpdatingLocation()
//            
//        }
        
        //set the mapView's delegate
        mapView.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func updateView(with frame: Frame) {
        //remove annotation
        let existingAnnotations = mapView.annotations
        mapView.removeAnnotations(existingAnnotations)
        
        if let location = frame.location {
            //update map
            let locationObject = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = locationObject
            mapView.addAnnotation(annotation)
            
            let span = MKCoordinateSpanMake(0.03, 0.03)
            let region = MKCoordinateRegionMake(locationObject, span)
            
            
            //map setup
            mapView.setRegion(region, animated: true)
            mapView.showsUserLocation = false
            
            //update geo location labels
            updateGeoDescription(with: location)
        }
        
        //block to update view here
        
    }
    
    func updateViewForLocationNotCaptured() {
        locationNameLabel.text = "Select location here"
        locationDetailLabel.text = "Location not captured"
        
        //recenter the map to locale
        let region = MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(180, 360))
        mapView.setRegion(region, animated: true)
    }
    
    func updateGeoDescription(with location: CLLocation) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { (placeMarks, error) in
            
            guard let returnedPlaceMarks = placeMarks else {
                self.locationNameLabel.text = "Error loading location"
                self.locationDetailLabel.text = "Error loading location"
                return }
            
            let placeMark = returnedPlaceMarks[0]
            
            if let locationName = placeMark.addressDictionary?["Name"] as? String,
                let locationDetail = placeMark.addressDictionary?["thoroughfare"] as? String {
                
                self.locationNameLabel.text = locationName
                self.locationDetailLabel.text = locationDetail
            }
            
        }
        
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
