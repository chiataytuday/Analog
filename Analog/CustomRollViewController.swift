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
    
    
    var customRoll: Roll?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide the warning label
        warningLabel.isHidden = true
        
        //the next button
        let navNextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(checkAndPerformSegue))
        self.navigationItem.rightBarButtonItem = navNextButton
        //disable next button on navigation controller
        checkAndEnable()
        
        //add tool bar
        addToolBar(title: "Next", textField: filmTextField)
        addToolBar(title: "Done", textField: isoTextField)
        
        //set 120 film text and first responser
        if let customRoll = customRoll {
            
            let filmName = customRoll.filmName
            let iso = customRoll.iso
            
            filmTextField.text = filmName
            isoTextField.text = "\(iso)"
            
            filmTextField.isEnabled = false
            isoTextField.isEnabled = false
            filmTypeImage.image = UIImage(named: "120")
            filmTypeSegment.isHidden = true
            addToolBar(title: "Done", textField: frameTextField)
            
        } else {
            
            addToolBar(title: "Next", textField: frameTextField)
            
            //format set to 135 since segment is initialized with 135
            customRoll = Roll(filmName: "", format: 135, frameCount: 0, iso: 0)
            
            filmTextField.becomeFirstResponder()
        }
        
        scrollView.registerForKeyboardNotifications()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Check whether all three fields are filled and
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
    
    //check for 0s and spaces
    func checkAndPerformSegue() {
        guard customRoll?.filmName != "",
            customRoll?.frameCount != 0,
            customRoll?.iso != 0
        else {
            //Dismiss the keyboard if still on
            filmTextField.resignFirstResponder()
            frameTextField.resignFirstResponder()
            isoTextField.resignFirstResponder()
            
            //show the warning label
            warningLabel.isHidden = false
            return
        }
        performSegue(withIdentifier: "cameraSettingFromCustomSegue", sender: self)
    }
    
    //call the check function whenever text was changed
    @IBAction func filmChanged(_ sender: UITextField) {
        guard let text = sender.text else { return }
        
        customRoll?.filmName = text
        checkAndEnable()
    }
    
    @IBAction func frameChanged(_ sender: UITextField) {
        
        guard let text = sender.text, let frameCount = Int(text) else { return }
        
        customRoll?.frameCount = frameCount
        checkAndEnable()
    }
    
    @IBAction func isoChanged(_ sender: UITextField) {
        
        guard let text = sender.text, let iso = Int(text) else { return }
        
        customRoll?.iso = iso
        checkAndEnable()
    }
    
    
    @IBAction func filmTypeChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            customRoll?.format = 135
            filmTypeImage.image = UIImage(named: "135")
        } else if sender.selectedSegmentIndex == 1 {
            customRoll?.format = 120
            filmTypeImage.image = UIImage(named: "120")
        }
    }
    
    //add function to the keyboard next button
    @IBAction func filmReturnTriggered(_ sender: UITextField) {
        frameTextField.becomeFirstResponder()
    }
    
    //hide the warning when text begin to edit again
    @IBAction func textFieldBeginEditing(_ sender: UITextField) {
        if warningLabel.isHidden == false {
            warningLabel.isHidden = true
        }
        
    }
    
    
    //Toolbar
    func addToolBar(title: String, textField: UITextField) {
        let toolBar = UIToolbar()
        toolBar.tintColor = .black
        let button = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(toolBarNextButtonTapped))
        toolBar.setItems([button], animated: false)
        
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        textField.inputAccessoryView = toolBar
    }
    
    //Toolbar next Button Tapped
    func toolBarNextButtonTapped() {
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
            destination.roll = customRoll
            
        }
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
