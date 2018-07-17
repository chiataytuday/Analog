//
//  DataMigrator.swift
//  Analog
//
//  Created by Zizhou Wang on 2018/7/13.
//  Copyright © 2018 Zizhou Wang. All rights reserved.
//

import Foundation

class DataMigrator {
    let dataController: DataController!
    
    init(dataController: DataController) {
        self.dataController = dataController
    }
    
    //Function for migrate rolls and frames
    func migrateRollsAndFrames() -> Bool {
        guard let album = Roll.loadAlbum() else {
            print("Migrator can't load album")
            return false
        }
        
        for roll in album {
            let newRoll = NewRoll(context: dataController.viewContext)
            newRoll.camera = roll.camera
            if let currentLens = roll.currentLens {
                newRoll.currentLens = Int64(currentLens)
            }
            newRoll.dateAdded = roll.dateAdded
            newRoll.filmName = roll.filmName
            newRoll.format = Int64(roll.format)
            newRoll.frameCount = Int64(roll.frameCount)
            
            if roll.iso <= Int64.max {
                newRoll.iso = Int64(roll.iso)
            }
            
            if let lastAddedFrame = roll.lastAddedFrame {
                if lastAddedFrame <= Int64.max {
                    newRoll.lastAddedFrame = Int64(lastAddedFrame)
                }
            }
            
            if let lastEditedDate = roll.lastEditedDate {
                newRoll.lastEditedDate = lastEditedDate
            }
            newRoll.newlyAdded = false
            if let pushPull = roll.pushPull {
                newRoll.pushPull = pushPull
            }
            if let title = roll.title {
                newRoll.title = title
            }
            
            //start to migrate frames
            guard let frames = roll.frames else { continue }
            
            for i in 0..<frames.count {
                guard let frame = frames[i] else { continue }
                
                let newFrame = NewFrame(context: dataController.viewContext)
                newFrame.roll = newRoll
                if let aperture = frame.aperture {
                    newFrame.aperture = aperture
                }
                newFrame.date = frame.addDate
                newFrame.index = Int64(i)
                
                if let lens = frame.lens {
                    if lens <= Int64.max {
                        newFrame.lens = Int64(lens)
                    }
                }
                
                newFrame.location = frame.location
                newFrame.locationDescription = frame.locationDescription
                newFrame.locationName = frame.locationName
                newFrame.notes = frame.notes
                if let shutter = frame.shutter {
                    if shutter <= Int64.max {
                        newFrame.shutter = Int64(shutter)
                    }
                }
            }
        }
        
        return true
    }
    
    //Function for migrating recently added
    func migrateRecentlyAdded() -> Bool {
        guard let recentlyAdded = Roll.loadRecentlyAdded() else {
            print("Migrator can't load recently added")
            return false
        }
        
        for (key, value) in recentlyAdded {
            guard value.iso <= Int64.max else { continue }
            
            let recentlyAddedRoll = RecentlyAddedRoll(context: dataController.viewContext)
            let predefinedRoll = PredefinedRoll(filmName: value.filmName, format: Int64(value.format), frameCount: Int64(value.frameCount), iso: Int64(value.iso))
            
            recentlyAddedRoll.fullName = key
            recentlyAddedRoll.predefinedRoll = predefinedRoll
            recentlyAddedRoll.timesAdded = 1
        }
        
        return true
    }
}

extension Roll {
    static func loadAlbum() -> [Roll]? {
        var album: [Roll]?
        album = NSKeyedUnarchiver.unarchiveObject(withFile: Roll.albumArchiveURL.path) as? [Roll]
        return album
    }
    
    static func loadRecentlyAdded() -> [String : Roll]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Roll.recentlyAddedArchiveURL.path) as? [String: Roll]
    }
}
