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
    func didUpdateDate(with date: Date)
}

class RollDetailTableViewController: UITableViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationDetailLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    //setting up location manager for map and description use
    let locationManager = CLLocationManager()
    //delegate in order to pass data to the parent
    var delegate: FrameEditingViewController?
    
    //variable for showing or hiding date picker
    var isDatePickerHidden = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the mapView's delegate
        mapView.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //table view protocol method
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            return 230
        case (0, 1):
            return 75
        case (0, 2):
            if isDatePickerHidden {
                return 75
            } else {
                return 230
            }
        default:
            return 44.0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 2 {
            isDatePickerHidden = !isDatePickerHidden
            tableView.beginUpdates()
            tableView.endUpdates()
        }
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
            
            let span = MKCoordinateSpanMake(0.01, 0.01)
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
        
        //block to update other view here
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        timeLabel.text = dateFormatter.string(from: frame.addDate)
        
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateLabel.text = dateFormatter.string(from: frame.addDate)
        
        datePicker.date = frame.addDate
    }
    
    
    func updateLocationDescription(with location: CLLocation) {
        
        let geoCoder = CLGeocoder()
        //disable the control now and reable when info is available
        self.delegate?.disableControls()
        
        self.locationNameLabel.text = "Loading location"
        self.locationDetailLabel.text = "Loading location"
        
        geoCoder.reverseGeocodeLocation(location) { (placeMarks, error) in
            
            if error != nil {
                self.delegate?.didUpdateLocationDescription(locationName: "Select location", locationDescription: "Can't load location Info")
                
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
            
            var locationName = ""
            var locationDetail = ""
            
            
            //placemark info processing
            if let name = placeMark.name {
                locationName += name
            }
            if let thoroughfare = placeMark.thoroughfare {
                locationDetail += thoroughfare
            }
            //check for whether the locality is the same as the administrativeArea
            if let locality = placeMark.locality,
                let administrativeArea = placeMark.administrativeArea {
                locationDetail += ", " + locality
                
                if administrativeArea != locality {
                    locationDetail += ", " + administrativeArea
                }
            }
            if let country = placeMark.country {
                locationDetail += ", " + country
            }
            self.delegate?.didUpdateLocationDescription(locationName: locationName, locationDescription: locationDetail)
        }
    }
    
    
    func updateViewForLocationNotCaptured() {
        locationNameLabel.text = "Select location here"
        locationDetailLabel.text = "Location not captured"
        
        //recenter the map to locale
        let region = MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(180, 360))
        mapView.setRegion(region, animated: true)
    }
    
    
    @IBAction func didUpdateDate(_ sender: UIDatePicker) {
        delegate?.didUpdateDate(with: sender.date)
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
