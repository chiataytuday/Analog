//
//  CameraSettingViewController.swift
//  Analog
//
//  Created by Zizhou Wang on 19/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import UIKit


class CameraSettingViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cameraTextField: UITextField!
    @IBOutlet weak var filmTextField: UITextField!
    @IBOutlet weak var filmImage: UIImageView!
    @IBOutlet weak var exposureLabel: UILabel!
    
    var selectedRollKey: String?
    var roll: Roll?
    let predefinedRoll = Roll.predefinedRolls
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let roll = roll {
            filmTextField.text = roll.filmName
            filmTextField.isEnabled = false
            if roll.format == 135 {
                filmImage.image = UIImage(named: "135")
            } else if roll.format == 120 {
                filmImage.image = UIImage(named: "120")
            }
            cameraTextField.becomeFirstResponder()
        }
        scrollView.registerForKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cameraTextChanged(_ sender: UITextField) {
        guard let cameraName = sender.text else { return }
        
        if !cameraName.isEmpty {
            roll?.camera = cameraName
        }
        
    }
    
    @IBAction func cameraTextReturnTriggered(_ sender: UITextField) {
        cameraTextField.resignFirstResponder()
    }
    
    @IBAction func exposureStepperValueChanged(_ sender: UIStepper) {
        let value = sender.value
        if value == -1 {
            exposureLabel.text = "Pull 1.0 stop"
        } else if value == 1 {
            exposureLabel.text = "Push 1.0 stop"
        } else if value == 0 {
            exposureLabel.text = "Not pushed or pulled"
        } else if value < 0 {
            exposureLabel.text = "Pull \(-value) stops"
        } else if value > 0 {
            exposureLabel.text = "Push \(value) stops"
        }
        
        roll?.pushPull = value
    }
    
    
    @IBAction func doneButtonTriggered(_ sender: UIBarButtonItem) {
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
            Roll.addRoll(roll)
            
            //Code for adding the roll to recently added
            guard selectedRollKey != nil else {
                //Leaning the roll for future use
                let leanedRoll = Roll(filmName: roll.filmName, format: roll.format, frameCount: roll.frameCount, iso: roll.iso)
                Roll.saveCustomAdded(roll: leanedRoll)
                performSegue(withIdentifier: "backToHomeSegue", sender: self)
                return
            }
            
            Roll.saveRecentlyAdded(for: selectedRollKey!)
            performSegue(withIdentifier: "backToHomeSegue", sender: self)
        }
        
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "backToHomeSegue" {
//            if let roll = roll, let text = cameraTextField.text {
//                if text.isEmpty {
//                    roll.camera = nil
//                }
//                roll.dateAdded = Date()
//                Roll.addRoll(roll)
//            }
//        }
//    }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    
    

}
