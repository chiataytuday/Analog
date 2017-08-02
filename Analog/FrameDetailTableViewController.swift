//
//  FrameDetailTableViewController.swift
//  Analog
//
//  Created by Zizhou Wang on 20/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import UIKit
import MapKit

protocol FrameDetailTableViewControllerDelegate {
    func didUpdateDate(with date: Date)
    func didUpdateLens(lens: Int?)
    func didUpdateAperture(aperture: Double?)
    func didUpdateShutter(shutter: Int?)
    func didUpdateNotes(notes: String?)
    func didUpdateLocationInfo(location: CLLocation, title: String, detail: String)
}

class FrameDetailTableViewController: UITableViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextViewDelegate, LocationSearchViewControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationDetailLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lensTextField: UITextField!
    @IBOutlet weak var apertureTextField: UITextField!
    @IBOutlet weak var shutterTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    
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
        noteTextView.delegate = self
        
        //add toolbar items
        addToolBar(title: "Done", textField: lensTextField, textView: nil)
        addToolBar(title: "Next", textField: apertureTextField, textView: nil)
        addToolBar(title: "Done", textField: shutterTextField, textView: nil)
        addToolBar(title: "Done", textField: nil, textView: noteTextView)
        
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
        case (0, 1), (0, 3):
            return 75
        case (0, 2):
            if isDatePickerHidden {
                return 75
            } else {
                return 230
            }
        case (0, 4):
            return 100
        //for (0, 5)
        default:
            return 180
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (0, 1):
            //prevent searching while still loading and saving
            if locationNameLabel.text == "Loading location..." {
                let alertController = UIAlertController(title: "Please wait", message: "Please wait until the load finishes", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                alertController.addAction(dismissAction)
                present(alertController, animated: true, completion: nil)
                
            } else if locationNameLabel.text == "Tap to reload" {
                guard let currentFrameIndex = delegate?.currentFrameIndex,
                    let location = delegate?.frames?[currentFrameIndex]?.location else {return}
                
                delegate?.updateLocationDescription(with: location, for: currentFrameIndex)
                delegate?.deleteFrameButton.isEnabled = false
                locationNameLabel.text = "Loading location..."
                locationDetailLabel.text = "Loading location..."
                
            } else {
                performSegue(withIdentifier: "searchLocationSegue", sender: self)
            }
            
        case (0, 2):
            isDatePickerHidden = !isDatePickerHidden
            tableView.beginUpdates()
            tableView.endUpdates()
        case (0, 3):
            lensTextField.becomeFirstResponder()
        case (0, 4):
            apertureTextField.becomeFirstResponder()
        case(0, 5):
            noteTextView.becomeFirstResponder()
        default:
            return
        }
        
        
    }
    
    
    
    func updateView(with frame: Frame?) {
        
        //remove annotation
        let existingAnnotations = mapView.annotations
        mapView.removeAnnotations(existingAnnotations)
        
        guard let frame = frame else {
            
            let region = MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(180, 360))
            mapView.setRegion(region, animated: true)
            
            locationNameLabel.text = "Loading location..."
            locationDetailLabel.text = "Loading location..."
            datePicker.date = Date()
            lensTextField.text = nil
            apertureTextField.text = nil
            shutterTextField.text = nil
            noteTextView.textColor = .lightGray
            noteTextView.text = "Notes"
            
            return
        }
        
        //for existing frames
        if let location = frame.location {
            
            //update map
            let locationObject = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = locationObject
            mapView.addAnnotation(annotation)
            
            let span = MKCoordinateSpanMake(0.002, 0.002)
            let region = MKCoordinateRegionMake(locationObject, span)
            
            
            //map setup
            mapView.setRegion(region, animated: true)
            mapView.showsUserLocation = false
            
            //location info
            locationNameLabel.text = frame.locationName
            locationDetailLabel.text = frame.locationDescription
            
        } else {
            updateViewForLocationNotCaptured()
        }
        
        //update other views
        let dateFormatter = DateFormatter()
        dateFormatter.locale
        dateFormatter.dateStyle = .full
        timeLabel.text = dateFormatter.string(from: frame.addDate)
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateLabel.text = dateFormatter.string(from: frame.addDate)
        datePicker.date = frame.addDate
        datePicker.maximumDate = Date()
        
        //lens info should be covered in parent controller
        
        //update aperture
        if let aperture = frame.aperture {
            apertureTextField.text = "\(aperture)"
        } else {
            apertureTextField.text = nil
        }
        //update shutter
        if let shutter = frame.shutter {
            shutterTextField.text = "\(shutter)"
        } else {
            shutterTextField.text = nil
        }
        //update notes
        if let notes = frame.notes {
            noteTextView.text = notes
        } else {
            //reset to the place holder
            noteTextView.textColor = .lightGray
            noteTextView.text = "Notes"
        }
    }
    
        
    
    func updateViewForLocationNotCaptured() {
        locationNameLabel.text = "Select location here"
        locationDetailLabel.text = "Location not captured"
        
        //recenter the map to locale
        let region = MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(180, 360))
        mapView.setRegion(region, animated: true)
    }
    
    func didUpdateLocationInfo(location: CLLocation, title: String, detail: String) {
        delegate?.didUpdateLocationInfo(location: location, title: title, detail: detail)
    }
    
    @IBAction func lensEditingBegin(_ sender: UITextField) {
        if sender.text != nil && sender.text != "" {
            let withouMM = sender.text?.replacingOccurrences(of: "mm", with: "")
            sender.text = withouMM
        }
    }
    
    @IBAction func lensEditingEnd(_ sender: UITextField) {
        if sender.text == nil || sender.text == "" {
            delegate?.didUpdateLens(lens: nil)
        } else {
            delegate?.didUpdateLens(lens: Int(sender.text!))
            //("mm" was appended in update view)
        }
    }
    
    @IBAction func apertureEditingEnd(_ sender: UITextField) {
        if sender.text == nil || sender.text == "" {
            delegate?.didUpdateAperture(aperture: nil)
        } else {
            delegate?.didUpdateAperture(aperture: Double(sender.text!))
        }
    }
    
    @IBAction func shutterEditingEnd(_ sender: UITextField) {
        if sender.text == nil || sender.text == "" {
            delegate?.didUpdateShutter(shutter: nil)
        } else {
            delegate?.didUpdateShutter(shutter: Int(sender.text!))
        }
    }
    
    //delegate methods for textView
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Notes" {
            noteTextView.text = ""
            noteTextView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            noteTextView.textColor = .lightGray
            noteTextView.text = "Notes"
            delegate?.didUpdateNotes(notes: nil)
        } else {
            delegate?.didUpdateNotes(notes: textView.text)
        }
    }
    
    
    func toolBarButtonTapped() {
        if lensTextField.isFirstResponder {
            lensTextField.resignFirstResponder()
        } else if apertureTextField.isFirstResponder {
            shutterTextField.becomeFirstResponder()
        } else if shutterTextField.isFirstResponder {
            shutterTextField.resignFirstResponder()
        } else if noteTextView.isFirstResponder {
            noteTextView.resignFirstResponder()
        }
    }
    
    //Keyboard Toolbar
    func addToolBar(title: String, textField: UITextField?, textView: UITextView?) {
        
        let toolBar = UIToolbar()
        toolBar.tintColor = .black
        //Add a flexible space so that the button is positioned on the right
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let button = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(toolBarButtonTapped))
        toolBar.setItems([flexSpace, button], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        if let textField = textField {
            textField.inputAccessoryView = toolBar
        } else if let textView = textView {
            textView.inputAccessoryView = toolBar
        }
        
        
    }
    
    
    @IBAction func didUpdateDate(_ sender: UIDatePicker) {
        delegate?.didUpdateDate(with: sender.date)
    }
    
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchLocationSegue" {
            let destination = segue.destination as! UINavigationController
            let targetController = destination.topViewController as! LocationSearchViewController
            
            targetController.previousRegion = mapView.region
            targetController.delegate = self
        }
    }
    

}
