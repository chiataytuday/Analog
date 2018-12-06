//
//  FrameEditingUpdatingExtension.swift
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
        roll.lastEditedDate = Date()
        frames[currentFrameIndex]?.date = date
        
        frameDetailTableViewController?.updateDateView(with: date)
        
    }
    
    func didUpdateLens(lens: Int64?) {
        roll.lastEditedDate = Date()
        
        if let lens = lens {
            roll.currentLens = lens
            frames[currentFrameIndex]?.lens = lens
            frameDetailTableViewController?.updateLensText(with: lens)
        } else {
            roll.currentLens = 0
            frames[currentFrameIndex]?.lens = 0
            frameDetailTableViewController?.updateLensText(with: 0)
        }
    }
    
    //aperture is 0.0 when not set
    func didUpdateAperture(aperture: Double?) {
        roll.lastEditedDate = Date()
        
        if let aperture = aperture {
            frames[currentFrameIndex]?.aperture = aperture
            frameDetailTableViewController?.updateApertureText(with: aperture)
        } else {
            frames[currentFrameIndex]?.aperture = 0.0
            frameDetailTableViewController?.updateApertureText(with: 0)
        }
    }
    
    func didUpdateShutter(shutter: Int64?) {
        roll.lastEditedDate = Date()
        
        if let shutter = shutter {
            frames[currentFrameIndex]?.shutter = shutter
            frameDetailTableViewController?.updateShutterText(with: shutter)
        } else {
            frames[currentFrameIndex]?.shutter = 0
            frameDetailTableViewController?.updateShutterText(with: 0)
        }
        
    }
    
    func didUpdateNotes(notes: String?) {
        roll.lastEditedDate = Date()
        frames[currentFrameIndex]?.notes = notes
        
        frameDetailTableViewController?.updateNotesView(with: notes)
        
    }
    
    
    func didUpdateLocationInfo(location: CLLocation, title: String, detail: String) {
        roll.lastEditedDate = Date()
        
        frames[currentFrameIndex]?.location = location
        frames[currentFrameIndex]?.locationName = title
        frames[currentFrameIndex]?.locationDescription = detail
        
        frameDetailTableViewController?.updateLocationViews(with: location, locationName: title, locationDescription: detail)
        
    }
    
    
    //used to update the view excluding the static table view
    //be careful frameIndex start at 0
    func showHideFrame(for frameIndex: Int64) {
        guard
            //important!! check if update is needed
            frameIndex == currentFrameIndex else { return }
        
        if frames.keys.contains(currentFrameIndex) {
            //hide the add button
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                self.addFrameView.alpha = 0
            }, completion: nil)
            
            deleteFrameButton.isEnabled = true
            
            //for container view to update map and date
            frameDetailTableViewController?.updateView(with: frames[currentFrameIndex])
            
        } else {
            //show the add button
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                self.addFrameView.alpha = 0.9
            }, completion: nil)
            
            deleteFrameButton.isEnabled = false
            
            //reset the view to prepare for adding
            frameDetailTableViewController?.updateView(with: nil)
        }
    }
    
}
