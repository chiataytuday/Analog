//
//  CameraSettingViewController.swift
//  Analog
//
//  Created by Zizhou Wang on 19/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import UIKit

protocol CameraSettingViewControllerDelegate {
    func didConfirmSavingPredefinedRoll(rollKey: String)
}

class CameraSettingViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cameraTextField: UITextField!
    @IBOutlet weak var filmLabel: UILabel!
    @IBOutlet weak var confirmationLabel: UILabel!
    @IBOutlet weak var filmImage: UIImageView!
    @IBOutlet weak var exposureLabel: UILabel!
    
    var cameraName: String?
    var pushPull: Double = 0.0
    
    //var selectedRollKey: String?
    var dataController: DataController!
    var roll: NewRoll!
    var halfCompleteRoll: PredefinedRoll!
    var predefinedRollDictionaryKey: String?
    var rollPredefined = false
    var delegate: CameraSettingViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filmLabel.text = halfCompleteRoll.filmName
        confirmationLabel.text = "Frames: \(halfCompleteRoll.frameCount), ISO: \(halfCompleteRoll.iso)"
        if halfCompleteRoll.format == 135 {
            filmImage.image = UIImage(named: "135")
        } else if halfCompleteRoll.format == 120 {
            filmImage.image = UIImage(named: "120")
            cameraTextField.becomeFirstResponder()
        }
        
        scrollView.registerForKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cameraEditEnded(_ sender: UITextField) {
        if let cameraName = sender.text {
            self.cameraName = cameraName
        } else {
            self.cameraName = nil
        }
        
    }
    
    @IBAction func cameraTextReturnTriggered(_ sender: UITextField) {
        cameraTextField.resignFirstResponder()
    }
    
    @IBAction func exposureStepperValueChanged(_ sender: UIStepper) {
        let value = sender.value
        if value == -1 {
            exposureLabel.text = "Overexpose 1 stop"
        } else if value == 1 {
            exposureLabel.text = "Underexpose 1 stop"
        } else if value == 0 {
            exposureLabel.text = "Normal"
        } else if value < 0 {
            exposureLabel.text = "Overexpose \(Int(-value)) stops"
        } else if value > 0 {
            exposureLabel.text = "Underexpose \(Int(value)) stops"
        }
        
        pushPull = value
    }
    
    
    @IBAction func doneButtonTriggered(_ sender: UIBarButtonItem) {
        
        //block used to save recently added
        if rollPredefined {
            guard let delegate = delegate else {fatalError("camera setting view controller doesn't have a delegate")}
            
            delegate.didConfirmSavingPredefinedRoll(rollKey: predefinedRollDictionaryKey!)
        } else {
            let recentlyAdded = RecentlyAddedRoll(context: dataController.viewContext)
            recentlyAdded.predefinedRoll = halfCompleteRoll
            recentlyAdded.timesAdded = 1
            recentlyAdded.fullName = halfCompleteRoll.filmName + " (\(halfCompleteRoll.format), \(halfCompleteRoll.frameCount)exp.)"
        }
        
        roll = NewRoll(context: dataController.viewContext)
        
        //Using predefined roll data to populate roll
        roll.filmName = halfCompleteRoll.filmName
        roll.frameCount = halfCompleteRoll.frameCount
        roll.iso = halfCompleteRoll.iso
        roll.format = halfCompleteRoll.format
        roll.newlyAdded = true
        roll.dateAdded = Date()
        roll.camera = cameraName
        roll.pushPull = pushPull
        
        
        try? dataController.viewContext.save()
        
        performSegue(withIdentifier: "showNewRollSegue", sender: self)
        
/*
        if let roll = roll {
            
            
            
            guard let text = cameraTextField.text else {
                //Simply add date and save roll
                roll.dateAdded = Date()
                Roll.addRoll(roll)
                return
            }
            
            if text.isEmpty {
                roll.camera = nil
            } else {
                roll.camera = text
            }
            
            roll.dateAdded = Date()
            
            //save the new roll, it's indexpath on Home should be 0, 0
            Roll.addRoll(roll)
            
            //Code for adding the roll to recently added
            guard selectedRollKey != nil else {
                //Leaning the roll for future use
                let leanedRoll = Roll(filmName: roll.filmName, format: roll.format, frameCount: roll.frameCount, iso: roll.iso)
                
                //save the custom roll to recently added
                Roll.saveCustomAdded(roll: leanedRoll)
                performSegue(withIdentifier: "showNewRollSegue", sender: self)
                return
            }
            //else call the save recently added
            Roll.saveRecentlyAdded(for: selectedRollKey!)
            performSegue(withIdentifier: "showNewRollSegue", sender: self)
        }
 */
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNewRollSegue" {
            let destination = segue.destination as! FrameEditingViewController
            //set the frame editing view controller's index path to new rolls
            //destination.rollIndexPath = IndexPath(row: 0, section: 0)
            destination.roll = roll
            destination.dataController = dataController
        }
        
    }
    
    
    

}
