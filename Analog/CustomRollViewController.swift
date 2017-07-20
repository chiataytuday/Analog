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
    //navigation bar button
    let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(checkAndPerformSegue))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = nextButton
        //disable next button on navigation controller
        checkAndEnable()
        
        //add tool bar
        addToolBar(textField: filmTextField)
        addToolBar(textField: frameTextField)
        addToolBar(textField: isoTextField)
        
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
            warningLabel.isHidden = true
            
            frameTextField.becomeFirstResponder()
        } else {
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
    
    //This function is used to check whether all three fields are filled
    func checkAndEnable() {
        guard let filmText = filmTextField.text,
            let frameText = frameTextField.text,
            let isoText = isoTextField.text
        else {
            nextButton.isEnabled = false
            return
        }
        
        if !filmText.isEmpty && !frameText.isEmpty && !isoText.isEmpty {
            nextButton.isEnabled = true
        } else {
            nextButton.isEnabled = false
        }
    }
    
    func checkAndPerformSegue() {
        guard customRoll?.filmName != "",
            customRoll?.frameCount != 0,
            customRoll?.iso != 0
        else {
            //Dismiss the keyboard
            filmTextField.resignFirstResponder()
            frameTextField.resignFirstResponder()
            isoTextField.resignFirstResponder()
            
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
    func addToolBar(textField: UITextField) {
        let toolBar = UIToolbar()
        toolBar.tintColor = .black
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(toolBarNextButtonTapped))
        toolBar.setItems([nextButton], animated: false)
        
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
            checkAndPerformSegue()
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
