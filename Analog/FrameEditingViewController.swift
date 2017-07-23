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

    @IBOutlet weak var indexBackgroundBlack: UIImageView!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var addFrameView: UIView!
    @IBOutlet weak var deleteFrameButton: UIBarButtonItem!
    
    @IBOutlet weak var addFrameButton: UIButton!
    
    
    //use for loading roll
    var rollIndexPath: IndexPath?
    var loadedRoll: Roll?
    
    //locationManager
    var locationManager = CLLocationManager()
    
    //In order to save roll
    //start with 0!!!
    var currentFrameIndex = 0
    var currentLocation: CLLocation?
    
    //the reference to the container view
    var rollDetailTableViewController: RollDetailTableViewController?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide the index combo
        indexBackgroundBlack.alpha = 0
        indexLabel.alpha = 0
        
        
        //load the roll, might be dangerous, perform everything else before following line
        guard let rollIndexPath = rollIndexPath,
            let loadedRoll = Roll.loadRoll(with: rollIndexPath) else { return }
        self.loadedRoll = loadedRoll
        
        //initialize the array for saving if not existed
        let frameCount = loadedRoll.frameCount
        if loadedRoll.frames == nil {
            loadedRoll.frames = Array(repeating: nil, count: frameCount)
        }
        
        //setting up the location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        //start update the location
        if CLLocationManager.locationServicesEnabled() == true &&
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
        }
        
        //update the initial view
        updateView()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //delegate methods
    func didUpdateCurrentLocation(location: CLLocation) {
        currentLocation = location
    }
    
    //location manager delegate method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
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
            }
            
            //save roll to file
            Roll.saveRoll(for: rollIndexPath, with: loadedRoll)
        }
        
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
    
//    //animations for slider change
//    @IBAction func sliderEditingBegin(_ sender: UISlider) {
//        
//        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
//            self.indexBackgroundBlack.alpha = 0.7
//            self.indexLabel.alpha = 0.9
//        }, completion: nil)
//    }
//    
//    @IBAction func sliderEditingEnd(_ sender: UISlider) {
//        UIView.animate(withDuration: 0.5, delay: 0.5, options: .curveEaseOut, animations: {
//            self.indexBackgroundBlack.alpha = 0
//            self.indexLabel.alpha = 0
//        }, completion: nil)
//    }
    
    @IBAction func addFrameButtonTapped(_ sender: UIButton) {
        //handle the situation when location cannot or not yet captured
        if CLLocationManager.locationServicesEnabled() == false
            || CLLocationManager.authorizationStatus() != .authorizedWhenInUse
            || currentLocation == nil {
            
            rollDetailTableViewController?.updateViewForLocationNotCaptured()
        }
        
        let newFrame = Frame(location: currentLocation, addDate: Date(), aperture: nil, shutter: nil, compensation: nil, notes: nil)
        
        editFrames(with: newFrame)
        
        //update both view
        updateView()
        rollDetailTableViewController?.updateView(with: newFrame)
    }
    
    @IBAction func backwardButtonTapped(_ sender: UIButton) {
        guard loadedRoll != nil else { return }
        
        if currentFrameIndex > 0 {
            currentFrameIndex -= 1
            indexLabel.text = "\(currentFrameIndex + 1)"
            //update view
            performIndexViewAnimation()
            updateView()
        }
    }
    
    @IBAction func forwardButtonTapped(_ sender: UIButton) {
        guard let loadedRoll = loadedRoll, let frames = loadedRoll.frames else { return }
        
        if currentFrameIndex < (frames.count - 1) {
            currentFrameIndex += 1
            indexLabel.text = "\(currentFrameIndex + 1)"
            //update view
            performIndexViewAnimation()
            updateView()
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
