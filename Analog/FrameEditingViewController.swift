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
    
    //use for loading roll
    var rollIndexPath: IndexPath?
    var loadedRoll: Roll?
    
    
    //In order to save roll
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
        
        
        //load the roll, might be dangerous, perform everything else before following line
        guard let rollIndexPath = rollIndexPath,
            let loadedRoll = Roll.loadRoll(with: rollIndexPath) else { return }
        self.loadedRoll = loadedRoll
        
        //set the slider and stepper value
        slider.maximumValue = Float(loadedRoll.frameCount)
        stepper.maximumValue = Double(loadedRoll.frameCount)
        
        //initialize the array for saving if not existed
        let frameCount = loadedRoll.frameCount
        
        if loadedRoll.frames == nil {
            loadedRoll.frames = Array(repeating: nil, count: frameCount)
        } else {
            //loaded only once, so can not be but in updateView
            if let lastEditedIndex = loadedRoll.lastEditedFrame {
                currentFrameIndex = lastEditedIndex
                slider.value = Float(currentFrameIndex + 1)
                stepper.value = Double(currentFrameIndex + 1)
                indexLabel.text = "\(currentFrameIndex + 1)"
            }
        }
        
        updateView()
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    
    func updateView() {
        guard let loadedRoll = loadedRoll,
            let frames = loadedRoll.frames,
            frames.indices.contains(currentFrameIndex) else { return }
        
        if frames[currentFrameIndex] == nil {
            addFrameView.isHidden = false
            deleteFrameButton.isEnabled = false
        } else {
            addFrameView.isHidden = true
            deleteFrameButton.isEnabled = true
            
            if let frameToUpdate = frames[currentFrameIndex] {
                rollDetailTableViewController?.updateView(with: frameToUpdate)
            }
        }
    }
    
    //delegate method
    func didUpdateLocationDescription(locationName: String, locationDescription: String) {
        if let roll = loadedRoll,
            let frames = roll.frames,
            let currentFrame = frames[currentFrameIndex] {
            
            currentFrame.locationName = locationName
            currentFrame.locationDescription = locationDescription
            //frame has requested location, should not do again
            currentFrame.hasRequestedLocationDescription = true
            
            editFrames(with: currentFrame)
            
            updateView()
        }
    }
    
    
    
    //implement the delegate method to add, save, or delete frame and roll at the same time
    func editFrames(with frame: Frame?) {
        guard let loadedRoll = loadedRoll else { return }
        
        //unwrap the frames and rollIndexPath
        if var frames = loadedRoll.frames, let rollIndexPath = rollIndexPath {
            //handle possible out of range
            if frames.indices.contains(currentFrameIndex) {
                //this can add, replace or delete frame
                frames[currentFrameIndex] = frame
                loadedRoll.frames = frames
                loadedRoll.lastEditedFrame = currentFrameIndex
            }
            
            //save roll to file
            Roll.saveRoll(for: rollIndexPath, with: loadedRoll)
        }
        
    }
    
    //used for disable control
    func disableControls() {
        deleteFrameButton.isEnabled = false
        slider.isEnabled = false
        stepper.isEnabled = false
    }
    
    func enableControls() {
        deleteFrameButton.isEnabled = true
        slider.isEnabled = true
        stepper.isEnabled = true
    }
    
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
        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
            self.indexBackgroundBlack.alpha = 0
            self.indexLabel.alpha = 0
        }, completion: nil)
    }
    
    @IBAction func addFrameButtonTapped(_ sender: UIButton) {
        
        let newFrame = Frame(location: currentLocation, locationName: nil, locationDescription: nil, addDate: Date(), aperture: nil, shutter: nil, compensation: nil, notes: nil)
        
        editFrames(with: newFrame)
        
        //update both view
        updateView()
        rollDetailTableViewController?.updateView(with: newFrame)
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
        
        updateView()
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        let doubleValue = sender.value
        let intValue = Int(doubleValue)
        
        
        slider.value = Float(doubleValue)
        
        currentFrameIndex = intValue - 1
        indexLabel.text = "\(intValue)"
        
        performIndexViewAnimation()
        
        updateView()
    }
    
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
