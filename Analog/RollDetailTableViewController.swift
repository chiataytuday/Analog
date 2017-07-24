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
    func didUpdateLocationDescription(locationName: String, locationDescription: String)
    func disableControls()
    func enableControls()
}

class RollDetailTableViewController: UITableViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationDetailLabel: UILabel!
    
    //setting up location manager for map and description use
    let locationManager = CLLocationManager()
    //delegate in order to pass data to the parent
    var delegate: FrameEditingViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
            //if location already exist
            if let locationName = frame.locationName, let locationDescription =
                frame.locationDescription {
                
                locationNameLabel.text = locationName
                locationDetailLabel.text = locationDescription
                
            } else if frame.hasRequestedLocationDescription == false {
                //Do the request
                updateLocationDescription(with: location)
            }
            
        } else {
            updateViewForLocationNotCaptured()
        }
        
        //block to update view here
        
    }
    
    
    func updateLocationDescription(with location: CLLocation) {
        
        let geoCoder = CLGeocoder()
        //disable the control now and reable when info is available
        self.delegate?.disableControls()
        
        geoCoder.reverseGeocodeLocation(location) { (placeMarks, error) in
            
            
            if error != nil {
                self.delegate?.didUpdateLocationDescription(locationName: "Select location here", locationDescription: "Can't load location Info")
                
                UIApplication.shared.endIgnoringInteractionEvents()
                self.delegate?.enableControls()
                return
            }
            
            guard let returnedPlaceMarks = placeMarks else {
                self.delegate?.enableControls()
                return
            }
            
            let placeMark = returnedPlaceMarks[0]
            //should now be able to control
            self.delegate?.enableControls()
            
            if let locationName = placeMark.name,
                let locationDetail = placeMark.thoroughfare {
                
                //call the delegate's method, 
                //and the delegate's method will be responsible to update the view
                self.delegate?.didUpdateLocationDescription(locationName: locationName, locationDescription: locationDetail)
            }
        }
    }
    
    
    func updateViewForLocationNotCaptured() {
        locationNameLabel.text = "Select location here"
        locationDetailLabel.text = "Location not captured"
        
        //recenter the map to locale
        let region = MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(180, 360))
        mapView.setRegion(region, animated: true)
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
