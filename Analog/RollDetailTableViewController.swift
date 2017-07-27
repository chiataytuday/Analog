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
        
    var indexPath: IndexPath?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load from file again, end up in the dataIOQueue
        guard let indexPath = indexPath,
            let loadedRoll = Roll.loadRoll(with: indexPath) else {return}
        
        let film = loadedRoll.filmName
        let frames = loadedRoll.frameCount
        let iso = loadedRoll.iso
        
        if let pushPull = loadedRoll.pushPull {
            var pushPullString: String{
                if pushPull == -1 {
                    return "Pulled 1.0 stop"
                } else if pushPull == 1 {
                    return "Pushed 1.0 stop"
                } else if pushPull == 0 {
                    return "Not pushed or pulled"
                } else if pushPull < 0 {
                    return "Pulled \(-pushPull) stops"
                } else {
                    return "Pushed \(pushPull) stops"
                }
            }
            pushPullLabel.text = pushPullString
        } else {
            pushPullLabel.text = "Not pushed or pulled"
        }
        
        filmLabel.text = film
        framesLabel.text = "\(frames)"
        isoLabel.text = "\(iso)"
        
        if let rollName = loadedRoll.title {
            rollNameTextField.text = rollName
        }
        
        if let camera = loadedRoll.camera {
            cameraTextField.text = camera
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func rollFieldReturned(_ sender: UITextField) {
        cameraTextField.becomeFirstResponder()
    }
    
    
    @IBAction func cameraFieldReturned(_ sender: UITextField) {
        cameraTextField.resignFirstResponder()
    }
    
    func saveRollName() {
        guard let indexPath = indexPath else { return }
        
        if let text = rollNameTextField.text {
            if text != "" {
                Roll.editRollTitle(title: text, for: indexPath)
            } else {
                Roll.editRollTitle(title: nil, for: indexPath)
            }
        }
    }
    
    func saveCamera() {
        guard let indexPath = indexPath else { return }
        
        if let text = cameraTextField.text {
            if text != "" {
                Roll.editCamera(camera: text, for: indexPath)
            } else {
                Roll.editCamera(camera: nil, for: indexPath)
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "saveRollDetailSegue" {
            saveRollName()
            saveCamera()
            
        }
    }
    
}
