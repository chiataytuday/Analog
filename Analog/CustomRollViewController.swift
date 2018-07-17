//
//  CustomRollViewController.swift
//  Analog
//
//  Created by Zizhou Wang on 19/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import UIKit

class CustomRollViewController: UIViewController {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var filmTextField: UITextField!
    @IBOutlet weak var frameTextField: UITextField!
    @IBOutlet weak var isoTextField: UITextField!
    @IBOutlet weak var filmTypeSegment: UISegmentedControl!
    @IBOutlet weak var filmTypeImage: UIImageView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var conflictWarningLabel: UILabel!
    @IBOutlet weak var framesLabel: UILabel!
    @IBOutlet weak var framesWarningLabel: UILabel!
    
    
    var cameraSettingDelegate: CameraSettingViewControllerDelegate?
    var rollPredefined = false
    var halfCompleteRoll: PredefinedRoll!
    var predefinedRollDictionaryKey: String?
    
    var dataController: DataController!

    
//    var customRoll: Roll?
//    var selectedRollKey: String?
//    let predefinedRoll = Roll.predefinedRolls
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide the warning labels
        warningLabel.isHidden = true
        conflictWarningLabel.isHidden = true
        framesWarningLabel.isHidden = true
        
        //the next button
        let navNextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(CustomRollViewController.checkAndPerformSegue))
        self.navigationItem.rightBarButtonItem = navNextButton
        //disable next button on navigation controller
        checkAndEnable()
        
        //add tool bar
        addToolBar(title: "Next", textField: filmTextField)
        addToolBar(title: "Done", textField: isoTextField)
        
        //set 120 film text and first responser
        if let customRoll = halfCompleteRoll {
            
            rollPredefined = true
            
            let filmName = customRoll.filmName
            let iso = customRoll.iso
            
            filmTextField.text = filmName
            isoTextField.text = "\(iso)"
            
            filmTextField.isEnabled = false
            isoTextField.isEnabled = false
            filmTypeImage.image = UIImage(named: "120")
            filmTypeSegment.isHidden = true
            framesLabel.text = "Frames on your camera"
            
            addToolBar(title: "Done", textField: frameTextField)
            frameTextField.becomeFirstResponder()
            
        } else {
            
            addToolBar(title: "Next", textField: frameTextField)
            
            //format set to 135 since segment is initialized with 135
            halfCompleteRoll = PredefinedRoll(filmName: "", format: 135, frameCount: 0, iso: 0)
            
//            customRoll = Roll(filmName: "", format: 135, frameCount: 0, iso: 0)
            
            filmTextField.becomeFirstResponder()
        }
        
        scrollView.registerForKeyboardNotifications()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Check whether all three fields are filled
    func checkAndEnable() {
        guard let filmText = filmTextField.text,
            let frameText = frameTextField.text,
            let isoText = isoTextField.text,
            let navNextButton = navigationItem.rightBarButtonItem
        else { return }
        
        if !filmText.isEmpty && !frameText.isEmpty && !isoText.isEmpty {
            navNextButton.isEnabled = true
        } else {
            navNextButton.isEnabled = false
        }
    }
    
    //check for 0s and empty spaces
    //As well as save recently added
    @objc func checkAndPerformSegue() {
        let filmName = halfCompleteRoll.filmName
        let frameCount = halfCompleteRoll.frameCount
        let iso = halfCompleteRoll.iso
        let format = halfCompleteRoll.format
        
        if filmName.isEmpty || frameCount == 0 || iso == 0 {
            //Dismiss all the keyboards
            filmTextField.resignFirstResponder()
            frameTextField.resignFirstResponder()
            isoTextField.resignFirstResponder()
            //show the warning label
            warningLabel.isHidden = false
            return
        }
        
        if frameCount == 1 || frameCount > 99 {
            //Dismiss all the keyboards
            filmTextField.resignFirstResponder()
            frameTextField.resignFirstResponder()
            isoTextField.resignFirstResponder()
            //show the warning label
            framesWarningLabel.isHidden = false
            //clear the frame field while being edited
            frameTextField.clearsOnBeginEditing = true
            return

        }
        
        //following block to check whether name is illegal (has no conflict with defined roll)
        //Making sure it's a custom roll
        guard filmTextField.isEnabled else {
            performSegue(withIdentifier: "cameraSettingFromCustomSegue", sender: self)
            return
        }
        
        let customRollKey = filmName + " (\(format), \(frameCount)exp.)"
        
        //Do below if containing an illegal roll name
        if AddRollViewController.predefinedRolls.keys.contains(customRollKey) {
            //Dismiss all the keyboards
            filmTextField.resignFirstResponder()
            frameTextField.resignFirstResponder()
            isoTextField.resignFirstResponder()
            //show the warning label
            conflictWarningLabel.isHidden = false
            //clear text
            filmTextField.clearsOnBeginEditing = true
        } else {
            //It should be an legal name now
            performSegue(withIdentifier: "cameraSettingFromCustomSegue", sender: self)
        }
        
    }
    
    //call the check function whenever text was changed
    @IBAction func filmChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        
        halfCompleteRoll.filmName = text
        checkAndEnable()
    }
    
    @IBAction func frameChanged(_ sender: UITextField) {
        
        guard let text = sender.text else { return }
        //if casting is successful
        if let frameCount = Int64(text) {
            halfCompleteRoll.frameCount = frameCount
        }
        
        checkAndEnable()
    }
    
    @IBAction func isoChanged(_ sender: UITextField) {
        
        guard let text = sender.text else { return }
        //if casting is sucesseful
        if let iso = Int64(text) {
            halfCompleteRoll.iso = iso
        }
        
        checkAndEnable()
    }
    
    
    @IBAction func filmTypeChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            halfCompleteRoll.format = 135
            filmTypeImage.image = UIImage(named: "135")
        } else if sender.selectedSegmentIndex == 1 {
            halfCompleteRoll.format = 120
            filmTypeImage.image = UIImage(named: "120")
        }
    }
    
    //add function to the keyboard next button
    @IBAction func filmReturnTriggered(_ sender: UITextField) {
        frameTextField.becomeFirstResponder()
    }
    
    //hide the warning when text begin to edit again
    @IBAction func textFieldBeginEditing(_ sender: UITextField) {
        //text fields no longer needed to be cleared again
        filmTextField.clearsOnBeginEditing = false
        frameTextField.clearsOnBeginEditing = false
        
        //hide all the warning labels
        warningLabel.isHidden = true
        conflictWarningLabel.isHidden = true
        framesWarningLabel.isHidden = true
        
    }
    
    
    //Keyboard Toolbar
    func addToolBar(title: String, textField: UITextField) {
        let toolBar = UIToolbar()
        toolBar.tintColor = .black
        //Add a flexible space so that the button is positioned on the right
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let button = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(CustomRollViewController.toolBarNextButtonTapped))
        toolBar.setItems([flexSpace, button], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        textField.inputAccessoryView = toolBar
    }
    
    //Toolbar next Button Tapped
    @objc func toolBarNextButtonTapped() {
        if filmTextField.isFirstResponder {
            frameTextField.becomeFirstResponder()
        } else if frameTextField.isFirstResponder && isoTextField.isEnabled {
            isoTextField.becomeFirstResponder()
        } else if frameTextField.isFirstResponder && !isoTextField.isEnabled {
            frameTextField.resignFirstResponder()
        } else if isoTextField.isFirstResponder {
            isoTextField.resignFirstResponder()
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cameraSettingFromCustomSegue" {
            let destination = segue.destination as! CameraSettingViewController
            destination.rollPredefined = rollPredefined
            destination.halfCompleteRoll = halfCompleteRoll
            destination.delegate = cameraSettingDelegate
            destination.predefinedRollDictionaryKey = predefinedRollDictionaryKey
            destination.dataController = dataController
            
//            destination.selectedRollKey = selectedRollKey
//            destination.roll = customRoll
        }
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
