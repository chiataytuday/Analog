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
    func didUpdateLens(lens: Int16?)
    func didUpdateAperture(aperture: Double?)
    func didUpdateShutter(shutter: Int16?)
    func didUpdateNotes(notes: String?)
    func didUpdateLocationInfo(location: CLLocation, title: String, detail: String)
}

class FrameDetailTableViewController: UITableViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextViewDelegate, LocationSearchViewControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationDetailLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
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
    
    //date formatter
    let dateFormatter = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the mapView's delegate
        mapView.delegate = self
        noteTextView.delegate = self
        
        //setup date formatter
        dateFormatter.dateStyle = .full
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        
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
    
    // MARK: - table view protocol method
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
                    let location = delegate?.frames[currentFrameIndex]?.location else {return}
                
                delegate?.updateLocationDescription(with: location, for: currentFrameIndex)
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
    
    
    // MARK: - Functions for update parts of the view
    func updateDateView(with date: Date) {
        dateFormatter.dateStyle = .full
        dateLabel.text = dateFormatter.string(from: date)
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        timeLabel.text = dateFormatter.string(from: date)
        
        datePicker.date = date
    }
    
    func updateLensText(with lens: Int16) {
        if lens != 0 {
            lensTextField.text = "\(lens)mm"
        } else {
            lensTextField.text = nil
        }
    }
    
    func updateApertureText(with aperture: Double) {
        if aperture != 0 {
            apertureTextField.text = "\(aperture)"
        } else {
            apertureTextField.text = nil
        }
    }
    
    func updateShutterText(with shutter: Int16) {
        if shutter != 0 {
            shutterTextField.text = "\(shutter)"
        } else {
            shutterTextField.text = nil
        }
    }
    
    func updateNotesView(with notes: String?) {
        if let notes = notes {
            noteTextView.textColor = .black
            noteTextView.text = notes
        } else {
            //reset to the place holder
            noteTextView.textColor = .lightGray
            noteTextView.text = "Notes"
        }
    }
    
    func updateLocationViews(with location: CLLocation?, locationName: String?, locationDescription: String?) {
        if let location = location {
            
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
            locationNameLabel.text = locationName
            locationDetailLabel.text = locationDescription
            
        } else {
            updateViewForLocationNotCaptured()
        }
    }
    
    
    func updateView(with frame: NewFrame?) {
        
        //remove annotation
        let existingAnnotations = mapView.annotations
        mapView.removeAnnotations(existingAnnotations)
        
        guard let frame = frame else {
            //if frame is nil
            let region = MKCoordinateRegionMake(mapView.centerCoordinate, MKCoordinateSpanMake(180, 360))
            mapView.setRegion(region, animated: true)
            
            locationNameLabel.text = "Loading location..."
            locationDetailLabel.text = "Loading location..."
            
            isDatePickerHidden = true
            tableView.beginUpdates()
            tableView.endUpdates()
            dateLabel.text = "Date"
            timeLabel.text = "Time"
            
            lensTextField.text = nil
            apertureTextField.text = nil
            shutterTextField.text = nil
            noteTextView.textColor = .lightGray
            noteTextView.text = "Notes"
            
            //scroll the table view to the top
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: true)
            
            return
        }
        
        //for existing frames
        updateLocationViews(with: frame.location, locationName: frame.locationName, locationDescription: frame.locationDescription)
        
//        if let location = frame.location {
//
//            //update map
//            let locationObject = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
//
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = locationObject
//            mapView.addAnnotation(annotation)
//
//            let span = MKCoordinateSpanMake(0.002, 0.002)
//            let region = MKCoordinateRegionMake(locationObject, span)
//
//
//            //map setup
//            mapView.setRegion(region, animated: true)
//            mapView.showsUserLocation = false
//
//            //location info
//            locationNameLabel.text = frame.locationName
//            locationDetailLabel.text = frame.locationDescription
//
//        } else {
//            updateViewForLocationNotCaptured()
//        }
        
        //update other views
        //let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .full
//        dateLabel.text = dateFormatter.string(from: frame.addDate)
//        dateFormatter.dateFormat = "h:mm a"
//        dateFormatter.amSymbol = "AM"
//        dateFormatter.pmSymbol = "PM"
//        timeLabel.text = dateFormatter.string(from: frame.addDate)
//
//        datePicker.date = frame.addDate
        
        //update date view
        if let date = frame.date {
            updateDateView(with: date)
        }
        datePicker.maximumDate = Date()
        
        //update lens
        updateLensText(with: frame.lens)
//        if let lens = frame.lens {
//            lensTextField.text = "\(lens)mm"
//        } else {
//            lensTextField.text = nil
//        }
        
        //update aperture
        updateApertureText(with: frame.aperture)
//        if let aperture = frame.aperture {
//            apertureTextField.text = "\(aperture)"
//        } else {
//            apertureTextField.text = nil
//        }
        
        
        //update shutter
        updateShutterText(with: frame.shutter)
//        if let shutter = frame.shutter {
//            shutterTextField.text = "\(shutter)"
//        } else {
//            shutterTextField.text = nil
//        }
        
        
        //update notes
        updateNotesView(with: frame.notes)
//        if let notes = frame.notes {
//            noteTextView.textColor = .black
//            noteTextView.text = notes
//        } else {
//            //reset to the place holder
//            noteTextView.textColor = .lightGray
//            noteTextView.text = "Notes"
//        }
    }
    
    func resignResponder() {
        lensTextField.resignFirstResponder()
        apertureTextField.resignFirstResponder()
        shutterTextField.resignFirstResponder()
        noteTextView.resignFirstResponder()
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
    
    // MARK: - Stroy board action methods
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
            delegate?.didUpdateLens(lens: Int16(sender.text!))
            //("mm" was appended in update view)
        }
    }
    
    
    @IBAction func aperatureEditingBegin(_ sender: UITextField) {
        apertureTextField.placeholder = nil
    }
    
    @IBAction func apertureEditingEnd(_ sender: UITextField) {
        if sender.text == nil || sender.text == "" {
            delegate?.didUpdateAperture(aperture: nil)
            apertureTextField.placeholder = "Aperture"
        } else {
            delegate?.didUpdateAperture(aperture: Double(sender.text!))
        }
    }
    
    @IBAction func ShutterEditingBegin(_ sender: UITextField) {
        shutterTextField.placeholder = nil
    }
    
    
    @IBAction func shutterEditingEnd(_ sender: UITextField) {
        if sender.text == nil || sender.text == "" {
            delegate?.didUpdateShutter(shutter: nil)
            shutterTextField.placeholder = "Shutter"
        } else {
            delegate?.didUpdateShutter(shutter: Int16(sender.text!))
        }
    }
    
    @IBAction func didUpdateDate(_ sender: UIDatePicker) {
        delegate?.didUpdateDate(with: sender.date)
    }
    
    // MARK: - delegate methods for textView
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
    
    //MARK: - Keyboard toolbar support
    @objc func toolBarButtonTapped() {
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
