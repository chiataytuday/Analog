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
    
    //used to update the view
    //be careful frameIndex start at 0
    func updateView(for frameIndex: Int) {
        guard let frames = frames,
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
            
        } else if let frameToUpdate = frames[frameIndex] {
            
            //hide the add button
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                self.addFrameView.alpha = 0
            }, completion: nil)
            
            deleteFrameButton.isEnabled = true
            
            //for container view to update map and date
            frameDetailTableViewController?.updateView(with: frameToUpdate)
            
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
                
            }

        }
    }

}
