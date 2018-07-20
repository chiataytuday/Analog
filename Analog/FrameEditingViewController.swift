//
//  FrameEditingViewController.swift
//  Analog
//
//  Created by Zizhou Wang on 22/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class FrameEditingViewController: UIViewController, FrameDetailTableViewControllerDelegate {

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
    
    
    var dataController: DataController!
    //use for loading roll
    var roll: NewRoll!
    //used to cache the frames
    var frames = [Int64: NewFrame]()
        
    //start with 0!!!
    var currentFrameIndex:Int64 = 0
    
    //the reference to the container view
    var frameDetailTableViewController: FrameDetailTableViewController?
    
    var locationController: LocationController!
    
    //setting up the location manager
    var locationManager: CLLocationManager!
//    var currentLocation: CLLocation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = locationController.locationManager
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if roll.lastAddedFrame != -1 {
            currentFrameIndex = roll.lastAddedFrame
        }
        
        
        if let title = roll.title {
            self.navigationItem.title = title
        }
        
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        //set the slider and stepper value, they are currentFrameIndex + 1!!!!!
        slider.maximumValue = Float(roll.frameCount)
        stepper.maximumValue = Double(roll.frameCount)
        
        slider.value = Float(currentFrameIndex + 1)
        stepper.value = Double(currentFrameIndex + 1)
        indexLabel.text = "\(currentFrameIndex + 1)"
        
        if roll.newlyAdded == true {
            //performAddFramePrompt()
            tapToSwitchImage.isHidden = false
        } else {
            tapToSwitchImage.isHidden = true
        }
        
        //load the frame
        let frameFetchRequest:NSFetchRequest<NewFrame> = NewFrame.fetchRequest()
        let framePredicate = NSPredicate(format: "roll == %@", roll)
        frameFetchRequest.predicate = framePredicate
        
        if let result = try? dataController?.viewContext.fetch(frameFetchRequest) {
            if let result = result {
                for frame in result {
                    frames[frame.index] = frame
                }
            }
        } else {
            fatalError("Can't load frames from store")
        }
        
        resetLocationDescription()
        
        updateView(for: currentFrameIndex)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //show the index combo, should later disapper with perform normal index animation
        performAnimationWithoutPop()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if dataController.viewContext.hasChanges {
            try? dataController.viewContext.save()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Update "Loading Location" description for this view instance
    func resetLocationDescription() {
//        guard geoCoder.isGeocoding == false else {return}
        
        for frame in frames.values {
            if frame.locationName == "Loading location..." {
                frame.locationName = "Tap to reload"
                frame.locationDescription = "Can't load location info"
            }
        }
    }
    
    
    // MARK: - Animations
    
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
        
        if roll.newlyAdded == true {
            tapToSwitchImage.isHidden = false
        } else {
            tapToSwitchImage.isHidden = true
        }
        
    }
    
    
    
    // MARK: - Actions which changes data
    
    @IBAction func addFrameButtonTapped(_ sender: UIButton) {
        
        locationManager.requestLocation()
        
        roll.newlyAdded = false
        
        let frame = NewFrame(context: dataController.viewContext)
        frame.date = Date()
        frame.index = currentFrameIndex
        frame.roll = roll
        if roll.currentLens != 0 {
            frame.lens = roll.currentLens
        }
        
        frames[currentFrameIndex] = frame
        
        
        roll.lastEditedDate = Date()
        roll.lastAddedFrame = currentFrameIndex
        
        if let currentLocation = locationController.currentLocation {
            frame.location = currentLocation
            updateLocationDescription(with: currentLocation, for: currentFrameIndex)
        }
        
        updateView(for: currentFrameIndex)
        
    }
    
    //for changing the current frameindex
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let floatValue = sender.value
        let roundValue = roundf(floatValue)
        let intValue = Int64(roundValue)
        
        slider.value = roundValue
        stepper.value = Double(roundValue)
        
        currentFrameIndex = intValue - 1
        
        indexLabel.text = "\(intValue)"
        
        updateView(for: currentFrameIndex)
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        let doubleValue = sender.value
        let intValue = Int64(doubleValue)
        
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
            guard let frame = self.frames[self.currentFrameIndex] else {return}
            
            self.dataController.viewContext.delete(frame)
            //update view
            self.frames.removeValue(forKey: self.currentFrameIndex)
            
            self.roll.lastEditedDate = Date()
            //loadedRoll.lastAddedFrame = self.currentFrameIndex
            
            self.updateView(for: self.currentFrameIndex)
            self.frameDetailTableViewController?.resignResponder()
            
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
            
            if let title = roll.title {
                self.navigationItem.title = title
            } else {
                self.navigationItem.title = "Untitled Roll"
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "rollDetailSegue" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let targetController = destinationNavigationController.topViewController as! RollDetailTableViewController
            targetController.roll = roll
            targetController.dataController = dataController
            
        } else if segue.identifier == "frameEmbedSegue" {
            let destinationController = segue.destination as! FrameDetailTableViewController
            //connect the two views
            frameDetailTableViewController = destinationController
            destinationController.delegate = self
        }
        
    }
    

}
