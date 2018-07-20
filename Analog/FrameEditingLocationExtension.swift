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
        let geoCoder = CLGeocoder()
        
        //deep copy the frameIndex
        let frameIndex = Int64(frameIndex)
        
        //prepare for possible currentIndex change, but set not finish loading
        frames[currentFrameIndex]?.locationName = "Loading location..."
        frames[currentFrameIndex]?.locationDescription = "Loading location..."
        frameDetailTableViewController?.updateLocationViews(with: location, locationName: "Loading location...", locationDescription: "Loading location...")
        
        //updateView(for: currentFrameIndex)
        
        var locationName = ""
        var locationDetail = ""
        
        geoCoder.reverseGeocodeLocation(location) { (placeMarks, error) in
            
            if error != nil {
                if let error = error as? CLError {
                    if error.code == CLError.geocodeCanceled {
                        return
                    }
                }
                
                DispatchQueue.main.async {
                    
                    if self.frames[frameIndex] != nil {
                        self.frames[frameIndex]?.locationName = "Tap to reload"
                        self.frames[frameIndex]?.locationDescription = "Can't load location info"
                        
                        if frameIndex == self.currentFrameIndex {
                            self.frameDetailTableViewController?.updateLocationViews(with: location, locationName: "Tap to reload", locationDescription: "Can't load location info")
                        }
                        
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

}
