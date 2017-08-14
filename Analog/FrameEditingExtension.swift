//
//  FrameEditingExtension.swift
//  Analog
//
//  Created by Zizhou Wang on 14/08/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import Foundation
import MapKit

extension FrameEditingViewController {
    
    //delegate methods from container view
    func didUpdateDate(with date: Date) {
        guard let loadedRoll = loadedRoll, let frames  = frames else {return}
        
        loadedRoll.lastEditedDate = Date()
        //Note: this is allowed because "frames" is only a reference copy
        frames[currentFrameIndex]?.addDate = date
        
        updateView(for: currentFrameIndex)
    }
    
    func didUpdateLens(lens: Int?) {
        
        
        guard let loadedRoll = loadedRoll, let frames  = frames else {return}
        
        loadedRoll.lastEditedDate = Date()
        loadedRoll.currentLens = lens
        frames[currentFrameIndex]?.lens = lens
        
        updateView(for: currentFrameIndex)
    }
    
    func didUpdateAperture(aperture: Double?) {
        guard let loadedRoll = loadedRoll, let frames  = frames else {return}
        
        loadedRoll.lastEditedDate = Date()
        frames[currentFrameIndex]?.aperture = aperture
        
        updateView(for: currentFrameIndex)
    }
    
    func didUpdateShutter(shutter: Int?) {
        guard let loadedRoll = loadedRoll, let frames  = frames else {return}
        
        loadedRoll.lastEditedDate = Date()
        frames[currentFrameIndex]?.shutter = shutter
        
        //necessary because the necessary refresh if frame deleted
        updateView(for: currentFrameIndex)
        
    }
    
    func didUpdateNotes(notes: String?) {
        guard let loadedRoll = loadedRoll, let frames  = frames else {return}
        
        loadedRoll.lastEditedDate = Date()
        frames[currentFrameIndex]?.notes = notes
        
        updateView(for: currentFrameIndex)
    }
    
    
    func didUpdateLocationInfo(location: CLLocation, title: String, detail: String) {
        guard let loadedRoll = loadedRoll, let frames  = frames else {return}
        
        loadedRoll.lastEditedDate = Date()
        frames[currentFrameIndex]?.location = location
        frames[currentFrameIndex]?.locationName = title
        frames[currentFrameIndex]?.locationDescription = detail
        
        updateView(for: currentFrameIndex)
        
    }
    
}
