//
//  RollDetailTableViewController.swift
//  Analog
//
//  Created by Zizhou Wang on 26/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import UIKit

class RollDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var filmLabel: UILabel!
    @IBOutlet weak var framesLabel: UILabel!
    @IBOutlet weak var isoLabel: UILabel!
    @IBOutlet weak var pushPullLabel: UILabel!
    @IBOutlet weak var rollNameTextField: UITextField!
    @IBOutlet weak var cameraTextField: UITextField!
    @IBOutlet weak var lastAddedLabel: UILabel!
    @IBOutlet weak var framesRecordedLabel: UILabel!
        
    var roll: NewRoll!
    var dataController: DataController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let film = roll.filmName
        let frameCount = roll.frameCount
        let iso = roll.iso
        let pushPull = roll.pushPull
        
        var frameRecordedCount = roll.frames?.count
        
        
        var pushPullString: String{
            if pushPull == -1 {
                return "Overexposed 1 stop"
            } else if pushPull == 1 {
                return "Underexposed 1 stop"
            } else if pushPull == 0 {
                return "Normal"
            } else if pushPull < 0 {
                return "Overexposed \(Int(-pushPull)) stops"
            } else {
                return "Underexposed \(Int(pushPull)) stops"
            }
        }
        pushPullLabel.text = pushPullString
        
        filmLabel.text = film
        framesLabel.text = "\(frameCount)"
        isoLabel.text = "\(iso)"
        
        if roll.lastAddedFrame != -1 {
            lastAddedLabel.text = "\(roll.lastAddedFrame + 1)"
        } else {
            lastAddedLabel.text = "N/A"
        }
        
        framesRecordedLabel.text = "\(frameRecordedCount ?? 0)/\(frameCount)"
        
        
        if let rollName = roll.title {
            rollNameTextField.text = rollName
        }
        
        if let camera = roll.camera {
            cameraTextField.text = camera
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func rollFieldReturned(_ sender: UITextField) {
        rollNameTextField.resignFirstResponder()
    }
    
    
    @IBAction func cameraFieldReturned(_ sender: UITextField) {
        cameraTextField.resignFirstResponder()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveRollDetailSegue" {
            let destination = segue.destination as? FrameEditingViewController
            
            //save roll title
            if let text = rollNameTextField.text {
                if text != "" {
                    destination?.roll?.title = text
                } else {
                    destination?.roll?.title = nil
                }
            }
            
            //save roll camera
            if let text = cameraTextField.text {
                if text != "" {
                    destination?.roll?.camera = text
                } else {
                    destination?.roll?.camera = nil
                }
            }
            
        }
    }
    
}
