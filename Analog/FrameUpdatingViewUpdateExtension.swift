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
//    func loadRoll() -> Roll? {
//        guard let rollIndexPath = rollIndexPath else {return nil}
//        
//        let loadedRoll = Roll.loadRoll(with: rollIndexPath)
//        
//        if let frames = loadedRoll?.frames {
//            self.frames = frames
//        }
//        
//        return loadedRoll
//    }
    
    //used to update the view
    //be careful frameIndex start at 0
    func updateView(for frameIndex: Int) {
        guard let frames = frames,
            //important!! check if update is needed
            frameIndex == currentFrameIndex else { return }
        
        if frames[currentFrameIndex] == nil {
//            guard let loadedRoll = loadedRoll else { return }
            
            //hide or show the notif image
//            if loadedRoll.lastAddedFrame == nil {
//                tapToSwitchImage.isHidden = false
//            } else {
//                tapToSwitchImage.isHidden = true
//            }
            
            //show the add button
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                self.addFrameView.alpha = 0.9
            }, completion: nil)
            
            deleteFrameButton.isEnabled = false
            
            //reset the view to prepare for adding
            frameDetailTableViewController?.updateView(with: nil)
            
        } else if let frameToUpdate = frames[frameIndex] {
            
            //hide the add button
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                self.addFrameView.alpha = 0
            }, completion: nil)
            
            deleteFrameButton.isEnabled = true
            
            //for container view to update map and date
            frameDetailTableViewController?.updateView(with: frameToUpdate)
            
            
//            if frameToUpdate.locationName == "Loading location..." {
//                deleteFrameButton.isEnabled = false
//            }
        }
    }
    
    //called whenever the add frame button tapped
    func updateLocationDescription(with location: CLLocation, for frameIndex: Int) {
        
        guard let frames = frames else {return}
        
        //deep copy the frameIndex
        let frameIndex = Int(frameIndex)
        
        let networkGroup = DispatchGroup()
        
        //prepare for possible currentIndex change, but set not finish loading
        frames[currentFrameIndex]?.locationName = "Loading location..."
        frames[currentFrameIndex]?.locationDescription = "Loading location..."
        updateView(for: currentFrameIndex)
        
        
//        Roll.editFrame(rollIndex: self.rollIndexPath!, frameIndex: frameIndex, location: nil, locationName: "Loading location...", locatonDescription: "Loading location...", addDate: nil, lastAddedFrame: nil, delete: false)
        
        var locationName = ""
        var locationDetail = ""
        
        geoCoder.reverseGeocodeLocation(location) { (placeMarks, error) in
            
            networkGroup.enter()
            
            if error != nil {
                
                if let error = error as? CLError {
                    if error.errorCode == 2 || error.errorCode == 10 {
                        //for network error or geoCode cancelled
                        DispatchQueue.main.async {
                            
                            if self.frames?[frameIndex] != nil {
                                self.frames?[frameIndex]?.locationName = "Tap to reload"
                                self.frames?[frameIndex]?.locationDescription = "Can't load location info"
                                
                                self.updateView(for: frameIndex)
                                //save roll again because the view might already disappear
                                self.saveRoll()
                            }
                            
                            networkGroup.leave()
                            
//                            Roll.editFrame(rollIndex: self.rollIndexPath!, frameIndex: frameIndex, location: nil, locationName: "Tap to reload", locatonDescription: "Can't load location info", addDate: nil, lastAddedFrame: nil, delete: false)
//                            self.loadedRoll = self.loadRoll()
//                            self.updateView(for: frameIndex)
                        }
                        return
                    } else {
                        //dispatch ui update on main
                        DispatchQueue.main.async {
                            
                            if self.frames?[frameIndex] != nil {
                                self.frames?[frameIndex]?.locationName = "Tap to search"
                                self.frames?[frameIndex]?.locationDescription = "Can't load location info"
                                
                                self.updateView(for: frameIndex)
                                
                                self.saveRoll()
                            }
                            
                            networkGroup.leave()
                            
                            //save the frame with error message, and set as has requested
//                            Roll.editFrame(rollIndex: self.rollIndexPath!, frameIndex: frameIndex, location: nil, locationName: "Tap to search", locatonDescription: "Can't load location info", addDate: nil, lastAddedFrame: nil, delete: false)
//                            //reload roll
//                            self.loadedRoll = self.loadRoll()
//                            //update view
//                            self.updateView(for: frameIndex)
                        }
                        return
                    }
                }
                
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
                
                if self.frames?[frameIndex] != nil {
                    self.frames?[frameIndex]?.locationName = locationName
                    self.frames?[frameIndex]?.locationDescription = locationDetail
                    
                    self.updateView(for: frameIndex)
                    
                    self.saveRoll()
                }
                
//                Roll.editFrame(rollIndex: self.rollIndexPath!, frameIndex: frameIndex, location: nil, locationName: locationName, locatonDescription: locationDetail, addDate: nil, lastAddedFrame: nil, delete: false)
//                //reload roll, load is always after the write, so data should be the latest
//                self.loadedRoll = self.loadRoll()
//                //update view
//                self.updateView(for: frameIndex)
            }

        }
    }

}
