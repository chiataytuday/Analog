//
//  FrameEditingLocationExtension.swift
//  Analog
//
//  Created by Zizhou Wang on 27/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import Foundation
import MapKit

extension FrameEditingViewController {
    
    //called whenever the add frame button tapped
    func updateLocationDescription(with location: CLLocation, for frameIndex: Int64) {
        
        
        //deep copy the frameIndex
        let frameIndex = Int64(frameIndex)
        
        let networkGroup = DispatchGroup()
        
        //prepare for possible currentIndex change, but set not finish loading
        frames[currentFrameIndex]?.locationName = "Loading location..."
        frames[currentFrameIndex]?.locationDescription = "Loading location..."
        frameDetailTableViewController?.updateLocationViews(with: location, locationName: "Loading location...", locationDescription: "Loading location...")
        
        //updateView(for: currentFrameIndex)
        
        var locationName = ""
        var locationDetail = ""
        
        geoCoder.reverseGeocodeLocation(location) { (placeMarks, error) in
            
            networkGroup.enter()
            
            if error != nil {
                
                if let error = error as? CLError {
                    if error.errorCode == 2 || error.errorCode == 10 {
                        //for network error or geoCode cancelled
                        DispatchQueue.main.async {
                            
                            if self.frames[frameIndex] != nil {
                                self.frames[frameIndex]?.locationName = "Tap to reload"
                                self.frames[frameIndex]?.locationDescription = "Can't load location info"
                                
                                if frameIndex == self.currentFrameIndex {
                                    self.frameDetailTableViewController?.updateLocationViews(with: location, locationName: "Tap to reload", locationDescription: "Can't load location info")
                                }
                                
                                try? self.dataController.viewContext.save()
                                
                            }
                            
                            networkGroup.leave()
                            
                        }
                        return
                    } else {
                        //dispatch ui update on main
                        DispatchQueue.main.async {
                            
                            if self.frames[frameIndex] != nil {
                                self.frames[frameIndex]?.locationName = "Tap to search"
                                self.frames[frameIndex]?.locationDescription = "Can't load location info"
                                
                                if frameIndex == self.currentFrameIndex {
                                    self.frameDetailTableViewController?.updateLocationViews(with: location, locationName: "Tap to search", locationDescription: "Can't load location info")
                                }
                                
                                try? self.dataController.viewContext.save()
                                
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
                
                if self.frames[frameIndex] != nil {
                    self.frames[frameIndex]?.locationName = locationName
                    self.frames[frameIndex]?.locationDescription = locationDetail
                    
                    if frameIndex == self.currentFrameIndex {
                        self.frameDetailTableViewController?.updateLocationViews(with: location, locationName: locationName, locationDescription: locationDetail)
                    }
                    
                }
                
            }

        }
    }

}
