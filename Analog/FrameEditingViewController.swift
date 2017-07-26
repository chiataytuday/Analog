//
//  FrameEditingViewController.swift
//  Analog
//
//  Created by Zizhou Wang on 22/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import UIKit
import MapKit

class FrameEditingViewController: UIViewController, CLLocationManagerDelegate, RollDetailTableViewControllerDelegate {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var indexBackgroundBlack: UIImageView!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var addFrameView: UIView!
    @IBOutlet weak var deleteFrameButton: UIBarButtonItem!
    @IBOutlet weak var addFrameButton: UIButton!
    @IBOutlet weak var editToolBar: UIToolbar!
    @IBOutlet weak var viewToolBar: UIToolbar!
    
    let geoCodeNetworkQueue = DispatchQueue(label: "com.Analog.geoCodeNetworkQueue")
    
    //use for loading roll
    var rollIndexPath: IndexPath?
    var loadedRoll: Roll?
    //start with 0!!!
    var currentFrameIndex = 0
    
    //the reference to the container view
    var rollDetailTableViewController: RollDetailTableViewController?
    
    //setting up the location manager
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //check for authorization and whether location services are available
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            //and start updating location
            locationManager.startUpdatingLocation()
            
        }
        
        //notify the user which frame they are in
        performIndexViewAnimation()
        
        //load the roll
        guard let loadedRoll = loadRoll() else { return }
        
        self.loadedRoll = loadedRoll
        
        //set the slider and stepper value
        slider.maximumValue = Float(loadedRoll.frameCount)
        stepper.maximumValue = Double(loadedRoll.frameCount)
        
        //initialize the array for saving if not existed
        if loadedRoll.frames == nil {
            guard let rollIndexPath = rollIndexPath else {return}
            Roll.initializeFrames(for: rollIndexPath, count: loadedRoll.frameCount)
            
            updateView(for: 0)
            
        } else {
            //loaded only once, so can not be but in updateView
            if let lastEditedIndex = loadedRoll.lastEditedFrame {
                currentFrameIndex = lastEditedIndex
                slider.value = Float(currentFrameIndex + 1)
                stepper.value = Double(currentFrameIndex + 1)
                indexLabel.text = "\(currentFrameIndex + 1)"
                
                //if roll hasn't finish loading, set the roll not able to load
                if let rollIndexPath = rollIndexPath,
                    let frame = loadedRoll.frames?[currentFrameIndex],
                    frame.hasRequestedLocationDescription == false {
                    
                    //if location info hasn't been get
                    Roll.editFrame(rollIndex: rollIndexPath, frameIndex: currentFrameIndex, location: nil, locationName: "Can't load location", locatonDescription: "Select location here", hasRequestedLocationDescription: true, addDate: nil, aperture: nil, shutter: nil, compensation: nil, notes: nil, lastEditedFrame: currentFrameIndex, delete: false)
                    
                    self.loadedRoll = loadRoll()
                    self.updateView(for: currentFrameIndex)
                } else {
                    updateView(for: 0)
                }
            }
        }
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //be careful frameIndex start at 0
    func updateView(for frameIndex: Int) {
        guard let loadedRoll = loadRoll(),
            let frames = loadedRoll.frames,
            frames.indices.contains(currentFrameIndex),
            //important!! check if update is needed
            frameIndex == currentFrameIndex else { return }
        
        if frames[currentFrameIndex] == nil {
            
            //show the add button
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                self.addFrameView.alpha = 0.9
            }, completion: nil)
            deleteFrameButton.isEnabled = false
            //reset the view to prepare for adding
            rollDetailTableViewController?.updateView(with: nil)
            
        } else if let frameToUpdate = frames[currentFrameIndex] {
            //hide the add button
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                self.addFrameView.alpha = 0
            }, completion: nil)
            deleteFrameButton.isEnabled = true
            
            //for container view to update map and date
            rollDetailTableViewController?.updateView(with: frameToUpdate)
            
            //used to handle the location info update
            //if location already exist, or is loading location
            if let locationName = frameToUpdate.locationName,
                let locationDescription = frameToUpdate.locationDescription {
                
                rollDetailTableViewController?.locationNameLabel.text = locationName
                rollDetailTableViewController?.locationDetailLabel.text = locationDescription
                
            }
        }
    }
    
    
    //function for reload roll, calls the update view in the end
    func loadRoll() -> Roll? {
        guard let rollIndexPath = rollIndexPath else {return nil}
        
        var loadedRoll: Roll?
        Roll.dataIOQueue.sync {
            loadedRoll = Roll.loadRoll(with: rollIndexPath)
        }
        
        return loadedRoll
        
    }
    
    
    //core location delegate method
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
    
    func updateLocationDescription(with location: CLLocation, for frameIndex: Int) {
        
        //prepare for possible index change, but set not finish loading
        Roll.editFrame(rollIndex: self.rollIndexPath!, frameIndex: frameIndex, location: nil, locationName: "Loading location...", locatonDescription: "Loading location...", hasRequestedLocationDescription: false, addDate: nil, aperture: nil, shutter: nil, compensation: nil, notes: nil, lastEditedFrame: frameIndex, delete: false)
        
        geoCodeNetworkQueue.sync {
            let geoCoder = CLGeocoder()
            //in order to let the whole group finish
            let networkGroup = DispatchGroup()
            var locationName = ""
            var locationDetail = ""
            
            geoCoder.reverseGeocodeLocation(location) { (placeMarks, error) in
                networkGroup.enter()
                if error != nil {
                    networkGroup.leave()
                    DispatchQueue.main.async {
                        //save the frame with error message, and set as has requested
                        Roll.editFrame(rollIndex: self.rollIndexPath!, frameIndex: frameIndex, location: nil, locationName: "Select location", locatonDescription: "Can't load location", hasRequestedLocationDescription: true, addDate: nil, aperture: nil, shutter: nil, compensation: nil, notes: nil, lastEditedFrame: frameIndex, delete: false)
                        //reload roll
                        self.loadedRoll = self.loadRoll()
                        //update view
                        self.updateView(for: frameIndex)
                    }
                    return
                } else {
                    guard let returnedPlaceMarks = placeMarks else { return }
                    
                    let placeMark = returnedPlaceMarks[0]
                    
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
                    
                    networkGroup.leave()
                }
                
                networkGroup.wait()
                DispatchQueue.main.async {
                    Roll.editFrame(rollIndex: self.rollIndexPath!, frameIndex: frameIndex, location: nil, locationName: locationName, locatonDescription: locationDetail, hasRequestedLocationDescription: true, addDate: nil, aperture: nil, shutter: nil, compensation: nil, notes: nil, lastEditedFrame: self.currentFrameIndex, delete: false)
                    //reload roll
                    self.loadedRoll = self.loadRoll()
                    //update view
                    self.updateView(for: frameIndex)
                }
            }
        }
    }
    
    
    func didUpdateDate(with date: Date) {
        if let rollIndexPath = rollIndexPath {
            
            Roll.editFrame(rollIndex: rollIndexPath, frameIndex: currentFrameIndex, location: nil, locationName: nil, locatonDescription: nil, hasRequestedLocationDescription: nil, addDate: date, aperture: nil, shutter: nil, compensation: nil, notes: nil, lastEditedFrame: currentFrameIndex, delete: false)
            
            //reload roll
            loadedRoll = loadRoll()
            //update view
            updateView(for: currentFrameIndex)
        }
    }
    
        
    //for index appear then disapppear animation
    func performIndexViewAnimation() {
        UIView.animate(withDuration: 0, animations: {
            self.indexBackgroundBlack.alpha = 0.7
            self.indexLabel.alpha = 0.9
        }) { (_) in
            UIView.animate(withDuration: 0.5, delay: 2, options: .curveEaseOut, animations: {
                self.indexBackgroundBlack.alpha = 0
                self.indexLabel.alpha = 0
            }, completion: nil)
        }
    }
    
    
    //IB actions
    @IBAction func sliderEditingBegin(_ sender: UISlider) {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.indexBackgroundBlack.alpha = 0.7
            self.indexLabel.alpha = 0.9
        }, completion: nil)
    }

    @IBAction func sliderEditingEnd(_ sender: UISlider) {
        UIView.animate(withDuration: 0.5, delay: 1, options: .curveEaseOut, animations: {
            self.indexBackgroundBlack.alpha = 0
            self.indexLabel.alpha = 0
        }, completion: nil)
    }
    
    @IBAction func addFrameButtonTapped(_ sender: UIButton) {
        
        guard let rollIndexPath = self.rollIndexPath else {return }
        
        //get the current location and save
        Roll.editFrame(rollIndex: rollIndexPath, frameIndex: self.currentFrameIndex, location: currentLocation, locationName: nil, locatonDescription: nil, hasRequestedLocationDescription: nil, addDate: nil, aperture: nil, shutter: nil, compensation: nil, notes: nil, lastEditedFrame: currentFrameIndex, delete: false)
        
        if let currentLocation = currentLocation {
            updateLocationDescription(with: currentLocation, for: currentFrameIndex)
        }
        
        //update view
        self.loadedRoll = self.loadRoll()
        updateView(for: self.currentFrameIndex)

    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let floatValue = sender.value
        let roundValue = roundf(floatValue)
        let intValue = Int(roundValue)
        
        slider.value = roundValue
        stepper.value = Double(roundValue)
        
        currentFrameIndex = intValue - 1
        
        indexLabel.text = "\(intValue)"
        
        performIndexViewAnimation()
        
        updateView(for: currentFrameIndex)
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        let doubleValue = sender.value
        let intValue = Int(doubleValue)
        
        
        slider.value = Float(doubleValue)
        
        currentFrameIndex = intValue - 1
        indexLabel.text = "\(intValue)"
        
        performIndexViewAnimation()
        
        updateView(for: currentFrameIndex)
    }
    
    //animation for tool bar change
    @IBAction func goToButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0, animations: {
            self.viewToolBar.alpha = 0
        }) { (_) in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.editToolBar.alpha = 0
            }, completion: { (_) in
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                    self.viewToolBar.alpha = 1
                }, completion: nil)
            })
        }
    }
    
    @IBAction func sliderBackButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: { 
            self.viewToolBar.alpha = 0
        }) { (_) in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: { 
                self.editToolBar.alpha = 1
            }, completion: nil)
        }
    }
    
    @IBAction func deleteFrameButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Delete this frame?", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            
            guard let rollIndexPath = self.rollIndexPath else {return}
            
            Roll.editFrame(rollIndex: rollIndexPath, frameIndex: self.currentFrameIndex, location: nil, locationName: nil, locatonDescription: nil, hasRequestedLocationDescription: nil, addDate: nil, aperture: nil, shutter: nil, compensation: nil, notes: nil, lastEditedFrame: self.currentFrameIndex, delete: true)
            
            self.loadedRoll = self.loadRoll()
            self.updateView(for: self.currentFrameIndex)
        }
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "frameEmbedSegue" {
            let destinationController = segue.destination as! RollDetailTableViewController
            //connect the two views
            rollDetailTableViewController = destinationController
            destinationController.delegate = self
        }
    }
    

}
