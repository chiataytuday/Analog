//
//  RollEditingExtension.swift
//  Analog
//
//  Created by Zizhou Wang on 27/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import Foundation
import MapKit

extension Roll {
    //roll editing maneuvers
    
    //only used for initial adding (automatic recording)
    //handle all the frame changes while use
    //serial enhanced by dataIOQueue
    static func editFrame(rollIndex: IndexPath, frameIndex: Int, location: CLLocation?, locationName: String?, locatonDescription: String?, addDate: Date?, lastAddedFrame: Int?, delete: Bool) {
        
        dataIOQueue.sync {
            guard var album = NSKeyedUnarchiver.unarchiveObject(withFile: Roll.albumArchiveURL.path) as? [Roll] else {return}
            
            let roll = album[rollIndex.row]
            guard var frames = roll.frames, frames.indices.contains(frameIndex) else {return}
            
            
            if let frame = frames[frameIndex] {
                if delete == true {
                    frames[frameIndex] = nil
                    roll.frames = frames
                    roll.lastEditedDate = Date()
                    album.remove(at: rollIndex.row)
                    album.insert(roll, at: 0)
                    NSKeyedArchiver.archiveRootObject(album, toFile: albumArchiveURL.path)
                    
                    return
                    
                } else if location != nil {
                    frame.location = location
                } else if locationName != nil && locatonDescription != nil {
                    frame.locationName = locationName
                    frame.locationDescription = locatonDescription
                } else if addDate != nil {
                    frame.addDate = addDate!
                } else if lastAddedFrame != nil {
                    roll.lastAddedFrame = lastAddedFrame
                }
                
                frames[frameIndex] = frame
                roll.frames = frames
                roll.lastEditedDate = Date()
                album.remove(at: rollIndex.row)
                album.insert(roll, at: 0)
                
                NSKeyedArchiver.archiveRootObject(album, toFile: albumArchiveURL.path)
            } else {
                //which means frame not yet exist
                let frame = Frame(location: location, locationName: nil, locationDescription: nil, addDate: Date(), aperture: nil, shutter: nil, lens: nil, notes: nil)
                
                //set the current lens for convinence
                if let lens = roll.currentLens {
                    frame.lens = lens
                }
                
                frames[frameIndex] = frame
                roll.frames = frames
                roll.lastEditedDate = Date()
                roll.lastAddedFrame = lastAddedFrame
                album.remove(at: rollIndex.row)
                album.insert(roll, at: 0)
                
                NSKeyedArchiver.archiveRootObject(album, toFile: albumArchiveURL.path)
            }
            
        }
        
    }
    
    
    static func initializeFrames(for rollIndex: IndexPath, count: Int) {
        dataIOQueue.sync {
            guard var album = NSKeyedUnarchiver.unarchiveObject(withFile: Roll.albumArchiveURL.path) as? [Roll], album.indices.contains(rollIndex.row) else {return }
            
            let roll = album[rollIndex.row]
            
            if roll.frames == nil {
                roll.frames = Array(repeating: nil, count: count)
                album[rollIndex.row] = roll
            }
            NSKeyedArchiver.archiveRootObject(album, toFile: albumArchiveURL.path)
        }
    }
    
    
    //load a specific roll from memory
    static func loadRoll(with rollIndex: IndexPath) -> Roll? {
        var roll: Roll?
        dataIOQueue.sync {
            if var album = NSKeyedUnarchiver.unarchiveObject(withFile: Roll.albumArchiveURL.path) as? [Roll], album.indices.contains(rollIndex.row) {
                
                roll = album[rollIndex.row]
            } else {
                roll = nil
            }
        }
        return roll
    }
    
    //deleting roll
    static func deleteRoll(at rollIndex: IndexPath) {
        
        dataIOQueue.sync {
            guard var album = NSKeyedUnarchiver.unarchiveObject(withFile: Roll.albumArchiveURL.path) as? [Roll], album.indices.contains(rollIndex.row) else { return }
            
            album.remove(at: rollIndex.row)
            
            NSKeyedArchiver.archiveRootObject(album, toFile: albumArchiveURL.path)
        }
    }
    
    static func editRollTitle(title: String?, for rollIndex: IndexPath) {
        dataIOQueue.sync {
            guard var album = NSKeyedUnarchiver.unarchiveObject(withFile: Roll.albumArchiveURL.path) as? [Roll], album.indices.contains(rollIndex.row) else { return }
            
            let roll = album[rollIndex.row]
            roll.title = title
            album[rollIndex.row] = roll
            
            NSKeyedArchiver.archiveRootObject(album, toFile: albumArchiveURL.path)
        }
        
    }
    
    static func editCamera(camera: String?, for rollIndex: IndexPath) {
        dataIOQueue.sync {
            guard var album = NSKeyedUnarchiver.unarchiveObject(withFile: Roll.albumArchiveURL.path) as? [Roll], album.indices.contains(rollIndex.row) else { return }
            
            let roll = album[rollIndex.row]
            roll.camera = camera
            album[rollIndex.row] = roll
            
            NSKeyedArchiver.archiveRootObject(album, toFile: albumArchiveURL.path)
        }
        
    }
    
    static func editCurrentLens(lens: Int?, for rollIndex: IndexPath) {
        dataIOQueue.sync {
            guard var album = NSKeyedUnarchiver.unarchiveObject(withFile: Roll.albumArchiveURL.path) as? [Roll], album.indices.contains(rollIndex.row) else { return }
            
            let roll = album[rollIndex.row]
            roll.currentLens = lens
            album[rollIndex.row] = roll
            
            NSKeyedArchiver.archiveRootObject(album, toFile: albumArchiveURL.path)
        }
    }
    
    static func editFrameLens(lens: Int?, rollIndex: IndexPath, frameIndex: Int) {
        dataIOQueue.sync {
            guard var album = NSKeyedUnarchiver.unarchiveObject(withFile: Roll.albumArchiveURL.path) as? [Roll], album.indices.contains(rollIndex.row) else { return }
            
            let roll = album[rollIndex.row]
            
            guard var frames = roll.frames, frames.indices.contains(frameIndex) else {return}
            
            if let frame = frames[frameIndex] {
                frame.lens = lens
                frames[frameIndex] = frame
                
                //new roll already
                roll.frames = frames
                roll.lastEditedDate = Date()
                album.remove(at: rollIndex.row)
                album.insert(roll, at: 0)
                
                NSKeyedArchiver.archiveRootObject(album, toFile: albumArchiveURL.path)
            }
            
        }
        
    }
    
    static func editFrameAperture(aperture: Double?, rollIndex: IndexPath, frameIndex: Int) {
        dataIOQueue.sync {
            guard var album = NSKeyedUnarchiver.unarchiveObject(withFile: Roll.albumArchiveURL.path) as? [Roll], album.indices.contains(rollIndex.row) else { return }
            
            let roll = album[rollIndex.row]
            
            guard var frames = roll.frames, frames.indices.contains(frameIndex) else {return}
            
            if let frame = frames[frameIndex] {
                frame.aperture = aperture
                frames[frameIndex] = frame
                
                //new roll already
                roll.frames = frames
                roll.lastEditedDate = Date()
                album.remove(at: rollIndex.row)
                album.insert(roll, at: 0)
                
                NSKeyedArchiver.archiveRootObject(album, toFile: albumArchiveURL.path)
            }
        }
    }
    
    
    static func editFrameShutter(shutter: Int?, rollIndex: IndexPath, frameIndex: Int) {
        dataIOQueue.sync {
            guard var album = NSKeyedUnarchiver.unarchiveObject(withFile: Roll.albumArchiveURL.path) as? [Roll], album.indices.contains(rollIndex.row) else { return }
            
            let roll = album[rollIndex.row]
            
            guard var frames = roll.frames, frames.indices.contains(frameIndex) else {return}
            
            if let frame = frames[frameIndex] {
                frame.shutter = shutter
                frames[frameIndex] = frame
                
                //new roll already
                roll.frames = frames
                roll.lastEditedDate = Date()
                album.remove(at: rollIndex.row)
                album.insert(roll, at: 0)
                
                NSKeyedArchiver.archiveRootObject(album, toFile: albumArchiveURL.path)
            }
            
        }
    }
    
    static func editFrameNotes(notes: String?, rollIndex: IndexPath, frameIndex: Int) {
        dataIOQueue.sync {
            guard var album = NSKeyedUnarchiver.unarchiveObject(withFile: Roll.albumArchiveURL.path) as? [Roll], album.indices.contains(rollIndex.row) else { return }
            
            let roll = album[rollIndex.row]
            
            guard var frames = roll.frames, frames.indices.contains(frameIndex) else {return}
            
            if let frame = frames[frameIndex] {
                frame.notes = notes
                frames[frameIndex] = frame
                
                //new roll already
                roll.frames = frames
                roll.lastEditedDate = Date()
                album.remove(at: rollIndex.row)
                album.insert(roll, at: 0)
                
                NSKeyedArchiver.archiveRootObject(album, toFile: albumArchiveURL.path)
            }
            
        }
    }
    
    

}
