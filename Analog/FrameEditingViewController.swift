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
    @IBOutlet weak var tapToSwitchImage: UIImageView!
    
    //use for loading roll
    var rollIndexPath: IndexPath?
    var loadedRoll: Roll?
    //used to cache the frames
    var frames: [Frame?]?
    
    
    //start with 0!!!
    var currentFrameIndex = 0
    
    //the reference to the container view
    var frameDetailTableViewController: FrameDetailTableViewController?
    
    //setting up the location manager
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    let geoCoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //load the roll
        guard let rollIndexPath = rollIndexPath,
            let loadedRoll = Roll.loadRoll(with: rollIndexPath) else { return }
        
        //assign loadedRoll
        self.loadedRoll = loadedRoll
        frames = loadedRoll.frames
        
        if let title = loadedRoll.title {
            self.navigationItem.title = title
        }
        
        //set the slider and stepper value, they are currentFrameIndex + 1!!!!!
        slider.maximumValue = Float(loadedRoll.frameCount)
        stepper.maximumValue = Double(loadedRoll.frameCount)
        
        //initialize the array for saving if not existed
        if loadedRoll.frames == nil {
            
            //initialize the frames
            frames = Array(repeating: nil, count: loadedRoll.frameCount)
            
            tapToSwitchImage.isHidden = false
            
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 7, execute: {
                self.navigationItem.prompt = nil
            })
            
        } else {
            //preparation for previously edited roll
            if let lastAddedIndex = loadedRoll.lastAddedFrame {
                
                tapToSwitchImage.isHidden = true
                
                currentFrameIndex = lastAddedIndex
                
                slider.value = Float(currentFrameIndex + 1)
                stepper.value = Double(currentFrameIndex + 1)
                indexLabel.text = "\(currentFrameIndex + 1)"
                
                updateView(for: currentFrameIndex)
                
            } else {
                
                updateView(for: 0)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //show the index combo, should later disapper with perform normal index animation
        performAnimationWithoutPop()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
        geoCoder.cancelGeocode()
        saveRoll()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //called while back batton was tapped or moving to the background
    func saveRoll() {
        guard let rollIndexPath = rollIndexPath, let loadedRoll = loadedRoll, let frames = frames else {return}
        
        loadedRoll.frames = frames
        
        Roll.saveRoll(for: rollIndexPath, with: loadedRoll)
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        currentLocation = nil
    }
    
    //delegate methods from container view
    func didUpdateDate(with date: Date) {
        guard let loadedRoll = loadedRoll, let frames  = frames else {return}
        
        loadedRoll.lastEditedDate = Date()
        //Note: this is allowed because "frames" is only a reference copy
        frames[currentFrameIndex]?.addDate = date
        
        updateView(for: currentFrameIndex)
        
    }
    
    func didUpdateLens(lens: Int?) {
        
        
        guard let loadedRoll = loadedRoll, let frames  = frames else {return}
        
        loadedRoll.lastEditedDate = Date()
        loadedRoll.currentLens = lens
        frames[currentFrameIndex]?.lens = lens
        
        updateView(for: currentFrameIndex)
        
    }
    
    func didUpdateAperture(aperture: Double?) {
        guard let loadedRoll = loadedRoll, let frames  = frames else {return}
        
        loadedRoll.lastEditedDate = Date()
        frames[currentFrameIndex]?.aperture = aperture
        
        updateView(for: currentFrameIndex)
    }
    
    func didUpdateShutter(shutter: Int?) {
        guard let loadedRoll = loadedRoll, let frames  = frames else {return}
        
        loadedRoll.lastEditedDate = Date()
        frames[currentFrameIndex]?.shutter = shutter
        
        updateView(for: currentFrameIndex)
    }
    
    func didUpdateNotes(notes: String?) {
        guard let loadedRoll = loadedRoll, let frames  = frames else {return}
        
        loadedRoll.lastEditedDate = Date()
        frames[currentFrameIndex]?.notes = notes
        
        updateView(for: currentFrameIndex)
    }
    
    
    func didUpdateLocationInfo(location: CLLocation, title: String, detail: String) {
        guard let loadedRoll = loadedRoll, let frames  = frames else {return}
        
        loadedRoll.lastEditedDate = Date()
        frames[currentFrameIndex]?.location = location
        frames[currentFrameIndex]?.locationName = title
        frames[currentFrameIndex]?.locationDescription = detail
        
        updateView(for: currentFrameIndex)
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
        
        tapToSwitchImage.isHidden = true
    }
    
    @IBAction func sliderBackButtonTapped(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.viewToolBar.alpha = 0
        }) { (_) in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.editToolBar.alpha = 1
            }, completion: nil)
        }
        
        if loadedRoll?.lastAddedFrame == nil {
            tapToSwitchImage.isHidden = false
        } else {
            tapToSwitchImage.isHidden = true
        }
    }
    
    
    
    
    //IB actions which changes data
    
    @IBAction func addFrameButtonTapped(_ sender: UIButton) {
        
        
        guard let loadedRoll = loadedRoll, var frames  = frames else {return}
        
        loadedRoll.lastEditedDate = Date()
        loadedRoll.lastAddedFrame = currentFrameIndex
        
        let frame = Frame(location: currentLocation, locationName: nil, locationDescription: nil, addDate: Date(), aperture: nil, shutter: nil, lens: nil, notes: nil)
        
        //use current lens if existed
        if let lens = loadedRoll.currentLens {
            frame.lens = lens
        }
        
        frames[currentFrameIndex] = frame
        self.frames = frames
        
        if let currentLocation = currentLocation {
            updateLocationDescription(with: currentLocation, for: currentFrameIndex)
        }
        
        updateView(for: currentFrameIndex)

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
            
            DispatchQueue.main.async {
                guard let loadedRoll = self.loadedRoll, var frames  = self.frames else {return}
                
                loadedRoll.lastEditedDate = Date()
                loadedRoll.lastAddedFrame = self.currentFrameIndex
                
                
                frames[self.currentFrameIndex] = nil
                self.frames = frames
                                
                self.updateView(for: self.currentFrameIndex)
                
            }
            
            
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
            targetController.loadedRoll = loadedRoll
            
        } else if segue.identifier == "frameEmbedSegue" {
            let destinationController = segue.destination as! FrameDetailTableViewController
            //connect the two views
            frameDetailTableViewController = destinationController
            destinationController.delegate = self
        }
        
    }
    

}
