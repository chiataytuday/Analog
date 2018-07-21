//
//  RollDetailTableViewController.swift
//  Analog
//
//  Created by Zizhou Wang on 26/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import Foundation
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
    var frames: [Int64: NewFrame]!
    
    
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 3 {
            exportCSV()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func exportCSV() {
        
        let filename = (roll.title ?? "Untitled Roll") + ".csv"
        let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        
        var CSVtext = ""
        
        if frames.values.count > 0 {
            CSVtext.append("Frame,Lens,Aperture,Shutter,Date,Location Name,Location Description,Notes\n")
            
            let framesSorted = frames.values.sorted { (frame1, frame2) -> Bool in
                if frame1.index < frame2.index {
                    return true
                } else {
                    return false
                }
            }
            
            for frame in framesSorted {
                
                let lens = frame.lens != 0 ? "\(frame.lens)" + "mm" : "None"
                let aperture = frame.aperture != 0 ? "\(frame.aperture)" : "None"
                let shutter = frame.shutter != 0 ? "\(frame.shutter)" : "None"
                let locationName = frame.locationName != "Loading location..." && frame.locationName != "Tap to reload" ? frame.locationName?.replacingOccurrences(of: ",", with: " ") : "None"
                let locationDescription = frame.locationDescription != "Loading location..." && frame.locationDescription != "Can't load location info" ? frame.locationDescription?.replacingOccurrences(of: ",", with: " ") : "None"
                let notes = frame.notes?.replacingOccurrences(of: ",", with: " ").replacingOccurrences(of: "\n", with: " ") ?? "None"
                
                let newLine = "\(frame.index + 1),\(lens),\(aperture),\(shutter),\(frame.date?.description ?? "None"),\(locationName ?? "None"),\(locationDescription ?? "None"),\(notes)\n"
                
                CSVtext.append(newLine)
            }
            
            CSVtext.append("\n\n")
        }
        
        var title = rollNameTextField.text?.replacingOccurrences(of: ",", with: " ")
        var camera = cameraTextField.text?.replacingOccurrences(of: ",", with: " ")
        
        if (title?.isEmpty)! {
            title = "Untitled"
        }
        
        if (camera?.isEmpty)! {
            camera = "None"
        }
        
        let rollString = "Roll Name,Film Type,Film Format,Frame Count,Film Speed,Camera,Date Added\n\(title ?? "Untitled"),\(roll.filmName ?? "None"),\(roll.format),\(roll.frameCount),\(roll.pushPull)ev,\(camera ?? "None"),\(roll.dateAdded?.description ?? "None")\n"
        
        CSVtext.append(rollString)
        
        CSVtext = CSVtext.replacingOccurrences(of: "\"", with: " ")
        
        do {
            try CSVtext.write(to: path, atomically: true, encoding: .utf8)
            let vc = UIActivityViewController(activityItems: [path], applicationActivities: [])
            present(vc, animated: true, completion: nil)
        } catch {
            print("Can't export to CSV")
        }
        
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
