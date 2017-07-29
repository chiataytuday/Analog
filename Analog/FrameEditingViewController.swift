//
//  FrameEditingViewController.swift
//  Analog
//
//  Created by Zizhou Wang on 22/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import UIKit
import MapKit

class FrameEditingViewController: UIViewController, CLLocationManagerDelegate, FrameDetailTableViewControllerDelegate {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var indexBackgroundBlack: UIImageView!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var addFrameView: UIView!
    @IBOutlet weak var deleteFrameButton: UIBarButtonItem!
    @IBOutlet weak var addFrameButton: UIButton!
    @IBOutlet weak var editToolBar: UIToolbar!
    @IBOutlet weak var viewToolBar: UIToolbar!
    
    let networkQueue = DispatchQueue(label: "com.hankerve.Analog.networkQueue", attributes: .concurrent)
    
    //use for loading roll
    var rollIndexPath: IndexPath?
    var loadedRoll: Roll?
    //start with 0!!!
    var currentFrameIndex = 0
    
    //the reference to the container view
    var frameDetailTableViewController: FrameDetailTableViewController?
    
    //setting up the location manager
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(swipe:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(swipe:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //check for authorization and whether location services are available
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            //and start updating location
            locationManager.startUpdatingLocation()
            
        }
        
        //show the index combo, should later disapper with perform normal index animation
        indexBackgroundBlack.alpha = 0.7
        indexLabel.alpha = 0.9
        
        //load the roll
        guard let rollIndexPath = rollIndexPath,
            let loadedRoll = loadRoll() else { return }
        
        //assign loadedRoll
        self.loadedRoll = loadedRoll
        
        if let title = loadedRoll.title {
            self.navigationItem.title = title
        }
        
        //set the slider and stepper value, they are currentFrameIndex + 1!!!!!
        slider.maximumValue = Float(loadedRoll.frameCount)
        stepper.maximumValue = Double(loadedRoll.frameCount)
        
        //initialize the array for saving if not existed
        if loadedRoll.frames == nil {
            
            Roll.initializeFrames(for: rollIndexPath, count: loadedRoll.frameCount)
            
            //reload roll after initialization
            self.loadedRoll = loadRoll()
            
            performAnimationWithoutPop()
            
            updateView(for: 0)
            
            //have a notification for user when first added
            let notifGroup = DispatchGroup()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                notifGroup.enter()
                self.navigationItem.prompt = "Now you can start to record your frames!"
                notifGroup.leave()
            })
            //wait for the first to complete
            notifGroup.wait()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                self.navigationItem.prompt = nil
            })
            
        } else if let frames = loadedRoll.frames {
            //preparation for previously edited roll
            if let lastAddedIndex = loadedRoll.lastAddedFrame {
                
                currentFrameIndex = lastAddedIndex
                
                slider.value = Float(currentFrameIndex + 1)
                stepper.value = Double(currentFrameIndex + 1)
                indexLabel.text = "\(currentFrameIndex + 1)"
                
                //resume location request (if restart, but not necessarily restart)
                for index in frames.indices {
                    if let frame = frames[index] {
                        if frame.locationName == "Loading location..." {
                            updateLocationDescription(with: frame.location!, for: index)
                        }
                    }
                }
                
                //Notify the user about the current frame
                performAnimationWithoutPop()
                
                updateView(for: currentFrameIndex)
                
            } else {
                //the user has not added any frame
                performAnimationWithoutPop()
                updateView(for: 0)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //handle the swipe gesture
    func handleSwipe(swipe: UISwipeGestureRecognizer) {
        guard let loadedRoll = loadedRoll else { return }
        
        if swipe.direction == .left && currentFrameIndex < loadedRoll.frameCount - 1 {
            currentFrameIndex += 1
            //link the slider and stepper
            slider.value = Float(currentFrameIndex + 1)
            stepper.value = Double(currentFrameIndex + 1)
            indexLabel.text = "\(currentFrameIndex + 1)"
            performIndexViewAnimation()
            updateView(for: currentFrameIndex)
        } else if swipe.direction == .right && currentFrameIndex > 0 {
            currentFrameIndex -= 1
            //link the slider and stepper
            slider.value = Float(currentFrameIndex + 1)
            stepper.value = Double(currentFrameIndex + 1)
            indexLabel.text = "\(currentFrameIndex + 1)"
            performIndexViewAnimation()
            updateView(for: currentFrameIndex)
        } else if currentFrameIndex == 0 {
            performIndexViewAnimation()
        } else if currentFrameIndex == loadedRoll.frameCount - 1 {
            performIndexViewAnimation()
        }
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
    
    //delegate methods from container view
    func didUpdateDate(with date: Date) {
        if let rollIndexPath = rollIndexPath {
            
            Roll.editFrame(rollIndex: rollIndexPath, frameIndex: currentFrameIndex, location: nil, locationName: nil, locatonDescription: nil, addDate: date, lastAddedFrame: nil, delete: false)
            
            //reload roll
            loadedRoll = loadRoll()
            //update view
            updateView(for: currentFrameIndex)
        }
    }
    
    func didUpdateLens(lens: Int?) {
        if let rollIndexPath = rollIndexPath {
            Roll.editCurrentLens(lens: lens, for: rollIndexPath)
            
            Roll.editFrameLens(lens: lens, rollIndex: rollIndexPath, frameIndex: currentFrameIndex)
            
            loadedRoll = loadRoll()
            
            updateView(for: currentFrameIndex)
        }
    }
    
    func didUpdateAperture(aperture: Double?) {
        if let rollIndexPath = rollIndexPath {
            
            Roll.editFrameAperture(aperture: aperture, rollIndex: rollIndexPath, frameIndex: currentFrameIndex)
            
            //reload roll
            loadedRoll = loadRoll()
            //update view
            updateView(for: currentFrameIndex)
        }
    }
    
    func didUpdateShutter(shutter: Int?) {
        if let rollIndexPath = rollIndexPath {
            
            Roll.editFrameShutter(shutter: shutter, rollIndex: rollIndexPath, frameIndex: currentFrameIndex)
            
            //reload roll
            loadedRoll = loadRoll()
            //update view
            updateView(for: currentFrameIndex)
        }
    }
    
    func didUpdateNotes(notes: String?) {
        if let rollIndexPath = rollIndexPath {
            
            Roll.editFrameNotes(notes: notes, rollIndex: rollIndexPath, frameIndex: currentFrameIndex)
            
            //reload roll
            loadedRoll = loadRoll()
            //update view
            updateView(for: currentFrameIndex)
        }
    }
    
    
    func didUpdateLocationInfo(location: CLLocation, title: String, detail: String) {
        if let rollIndexPath = rollIndexPath {
            
            Roll.editFrame(rollIndex: rollIndexPath, frameIndex: currentFrameIndex, location: location, locationName: title, locatonDescription: detail, addDate: nil, lastAddedFrame: nil, delete: false)
            
            //reload roll
            loadedRoll = loadRoll()
            //update view
            updateView(for: currentFrameIndex)
        }
    }
    
    
    //Animations
    
    //for index pop animation
    func performIndexViewAnimation() {
        
        UIView.animate(withDuration: 0, animations: {
            self.indexBackgroundBlack.alpha = 0.7
            self.indexLabel.alpha = 0.9
        }, completion: { (_) in
            UIView.animate(withDuration: 0.09, animations: {
                self.indexBackgroundBlack.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                self.indexLabel.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
            }, completion: { (_) in
                UIView.animate(withDuration: 0.09, animations: {
                    self.indexBackgroundBlack.transform = CGAffineTransform.identity
                    self.indexLabel.transform = CGAffineTransform.identity
                }, completion: { (_) in
                    UIView.animate(withDuration: 0.5, delay: 8, options: .curveEaseOut, animations: {
                        self.indexBackgroundBlack.alpha = 0
                        self.indexLabel.alpha = 0
                    }, completion: nil)
                })
            })
        })
    }
    
    func performAnimationWithoutPop() {
        UIView.animate(withDuration: 0.5, delay: 8, options: .curveEaseOut, animations: {
            self.indexBackgroundBlack.alpha = 0
            self.indexLabel.alpha = 0
        }, completion: nil)
    }
    
    //for slider animation
    @IBAction func sliderEditingBegin(_ sender: UISlider) {
        
        self.indexBackgroundBlack.alpha = 0.7
        self.indexLabel.alpha = 0.9
    }
    
    @IBAction func sliderEditingEnd(_ sender: UISlider) {
        UIView.animate(withDuration: 0.5, delay: 8, options: .curveEaseOut, animations: {
            self.indexBackgroundBlack.alpha = 0
            self.indexLabel.alpha = 0
        }, completion: nil)
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
    
    
    
    
    //IB actions which changes data
    
    @IBAction func addFrameButtonTapped(_ sender: UIButton) {
        
        guard let rollIndexPath = self.rollIndexPath else {return }
        
        //get the current location and save
        Roll.editFrame(rollIndex: rollIndexPath, frameIndex: self.currentFrameIndex, location: currentLocation, locationName: nil, locatonDescription: nil, addDate: nil, lastAddedFrame: currentFrameIndex, delete: false)
        
        if let currentLocation = currentLocation {
            updateLocationDescription(with: currentLocation, for: currentFrameIndex)
        }
        
        //update view
        self.loadedRoll = self.loadRoll()
        performIndexViewAnimation()
        updateView(for: self.currentFrameIndex)

    }
    
    //for changing the current frameindex
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let floatValue = sender.value
        let roundValue = roundf(floatValue)
        let intValue = Int(roundValue)
        
        slider.value = roundValue
        stepper.value = Double(roundValue)
        
        currentFrameIndex = intValue - 1
        
        indexLabel.text = "\(intValue)"
        
        updateView(for: currentFrameIndex)
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        let doubleValue = sender.value
        let intValue = Int(doubleValue)
        
        
        slider.value = Float(doubleValue)
        
        currentFrameIndex = intValue - 1
        indexLabel.text = "\(intValue)"
        
        updateView(for: currentFrameIndex)
    }
    
    @IBAction func stepperTouched(_ sender: UIStepper) {
        
        performIndexViewAnimation()
        
    }
    
    @IBAction func deleteFrameButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Delete this frame?", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            
            guard let rollIndexPath = self.rollIndexPath else {return}
            
            Roll.editFrame(rollIndex: rollIndexPath, frameIndex: self.currentFrameIndex, location: nil, locationName: nil, locatonDescription: nil, addDate: nil, lastAddedFrame: nil, delete: true)
            
            self.loadedRoll = self.loadRoll()
            self.updateView(for: self.currentFrameIndex)
        }
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "rollDetailSegue", sender: self)
    }
    
    
    
    
    // MARK: - Navigation
    @IBAction func unwindToEditing(unwindSegue: UIStoryboardSegue) {
        
        if unwindSegue.identifier == "saveRollDetailSegue" {
            self.loadedRoll = loadRoll()
            updateView(for: currentFrameIndex)
            
            guard let loadedRoll = loadedRoll, let title = loadedRoll.title else {
                self.navigationItem.title = "Untitled Roll"
                return
            }
            self.navigationItem.title = title
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "rollDetailSegue" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! RollDetailTableViewController
            targetController.indexPath = rollIndexPath
            //targetController.delegate = self
            
        } else if segue.identifier == "frameEmbedSegue" {
            let destinationController = segue.destination as! FrameDetailTableViewController
            //connect the two views
            frameDetailTableViewController = destinationController
            destinationController.delegate = self
        }
        
    }
    

}
