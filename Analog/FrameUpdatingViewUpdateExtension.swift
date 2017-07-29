//
//  FrameUpdatingViewUpdateExtension.swift
//  Analog
//
//  Created by Zizhou Wang on 27/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import Foundation
import MapKit

extension FrameEditingViewController {
    
    //function for reload roll
    func loadRoll() -> Roll? {
        guard let rollIndexPath = rollIndexPath else {return nil}
        
        return Roll.loadRoll(with: rollIndexPath)
    }
    
    //used to update the view
    //be careful frameIndex start at 0
    func updateView(for frameIndex: Int) {
        guard let loadedRoll = loadedRoll,
            let frames = loadedRoll.frames,
            frames.indices.contains(currentFrameIndex),
            
            //important!! check if update is needed
            frameIndex == currentFrameIndex else { return }
        
        if frames[currentFrameIndex] == nil {
            
            //show the add button
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                self.addFrameView.alpha = 0.9
            }, completion: nil)
            deleteFrameButton.isEnabled = false
            //reset the view to prepare for adding
            frameDetailTableViewController?.updateView(with: nil)
            
        } else if let frameToUpdate = frames[currentFrameIndex] {
            
            
            //hide the add button
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                self.addFrameView.alpha = 0
            }, completion: nil)
            deleteFrameButton.isEnabled = true
            
            //for container view to update map and date
            frameDetailTableViewController?.updateView(with: frameToUpdate)
            
            //used to update lens
            if let lens = frameToUpdate.lens {
                frameDetailTableViewController?.lensTextField.text = "\(lens)mm"
            }
            
            
            //used to handle the location info update
            //if location already exist, or is loading location
            if let locationName = frameToUpdate.locationName,
                let locationDescription = frameToUpdate.locationDescription {
                
                //IMPORTANT! disable the delete button if loading
                if locationName == "Loading location..." {
                    deleteFrameButton.isEnabled = false
                }
                //update the location info, either loading or canceled
                frameDetailTableViewController?.locationNameLabel.text = locationName
                frameDetailTableViewController?.locationDetailLabel.text = locationDescription
                
            }
        }
    }
    
    //called whenever the add frame button tapped
    func updateLocationDescription(with location: CLLocation, for frameIndex: Int) {
        
        //prepare for possible currentIndex change, but set not finish loading
        Roll.editFrame(rollIndex: self.rollIndexPath!, frameIndex: frameIndex, location: nil, locationName: "Loading location...", locatonDescription: "Loading location...", addDate: nil, lastAddedFrame: nil, delete: false)
        
        DispatchQueue.global(qos: .userInitiated).async {
            let geoCoder = CLGeocoder()
            //wait for the networkgroup to finish before updating ui
            let networkGroup = DispatchGroup()
            var locationName = ""
            var locationDetail = ""
            
            geoCoder.reverseGeocodeLocation(location) { (placeMarks, error) in
                networkGroup.enter()
                if error != nil {
                    networkGroup.leave()
                    //dispatch ui update on main
                    DispatchQueue.main.async {
                        
                        //save the frame with error message, and set as has requested
                        Roll.editFrame(rollIndex: self.rollIndexPath!, frameIndex: frameIndex, location: nil, locationName: "Tap to search", locatonDescription: "Can't load location info", addDate: nil, lastAddedFrame: nil, delete: false)
                        //reload roll
                        self.loadedRoll = self.loadRoll()
                        //update view
                        self.updateView(for: frameIndex)
                    }
                    return
                } else {
                    guard let returnedPlaceMarks = placeMarks else { return }
                    
                    let placeMark = returnedPlaceMarks[0]
                    
                    //placemark info processing
                    if let name = placeMark.name {
                        locationName += name
                    }
                    
                    locationDetail += placeMark.phrasePlacemarkDetail()
                    
                    networkGroup.leave()
                }
                
                networkGroup.wait()
                DispatchQueue.main.async {
                    Roll.editFrame(rollIndex: self.rollIndexPath!, frameIndex: frameIndex, location: nil, locationName: locationName, locatonDescription: locationDetail, addDate: nil, lastAddedFrame: nil, delete: false)
                    //reload roll, load is always after the write, so data should be the latest
                    self.loadedRoll = self.loadRoll()
                    //update view
                    self.updateView(for: frameIndex)
                }
            }
        }
    }

}
