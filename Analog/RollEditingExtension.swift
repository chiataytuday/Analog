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
    
    //called while back button was tapped or app being moved to background
    static func saveRoll(for rollIndexPath: IndexPath, with roll: Roll) {
        guard var album = NSKeyedUnarchiver.unarchiveObject(withFile: Roll.albumArchiveURL.path) as? [Roll], album.indices.contains(rollIndexPath.row) else {return }
        
        album[rollIndexPath.row] = roll
        
        NSKeyedArchiver.archiveRootObject(album, toFile: albumArchiveURL.path)
    }
    
    
    //load a specific roll from memory
    static func loadRoll(with rollIndex: IndexPath) -> Roll? {
        if var album = NSKeyedUnarchiver.unarchiveObject(withFile: Roll.albumArchiveURL.path) as? [Roll], album.indices.contains(rollIndex.row) {
            
            return album[rollIndex.row]
        } else {
            return nil
        }
    }
    
    //deleting roll
    static func deleteRoll(at rollIndex: IndexPath) {
        guard var album = NSKeyedUnarchiver.unarchiveObject(withFile: Roll.albumArchiveURL.path) as? [Roll], album.indices.contains(rollIndex.row) else { return }
        
        album.remove(at: rollIndex.row)
        
        NSKeyedArchiver.archiveRootObject(album, toFile: albumArchiveURL.path)
    }
    
    static func editRollTitle(title: String?, for rollIndex: IndexPath) {
        guard var album = NSKeyedUnarchiver.unarchiveObject(withFile: Roll.albumArchiveURL.path) as? [Roll], album.indices.contains(rollIndex.row) else { return }
        
        let roll = album[rollIndex.row]
        roll.title = title
        album[rollIndex.row] = roll
        
        NSKeyedArchiver.archiveRootObject(album, toFile: albumArchiveURL.path)
    }
    
}
