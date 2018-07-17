//
//  AddRollExtension.swift
//  Analog
//
//  Created by Zizhou Wang on 27/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import Foundation

//handling all use while user is adding a roll
extension Roll {
    //Only for adding new roll use
//    static func addRoll(_ roll: Roll) {
//        if let loadedAlbum = Roll.loadAlbum() {
//            var albumToSave = loadedAlbum
//            albumToSave.insert(roll, at: 0)
//            NSKeyedArchiver.archiveRootObject(albumToSave, toFile: Roll.albumArchiveURL.path)
//        } else {
//            var albumToSave = [Roll]()
//            albumToSave.append(roll)
//            NSKeyedArchiver.archiveRootObject(albumToSave, toFile: Roll.albumArchiveURL.path)
//        }
//    }
//    
    //for album loading at home screen
    static func loadAlbum() -> [Roll]? {
        var album: [Roll]?
        album = NSKeyedUnarchiver.unarchiveObject(withFile: Roll.albumArchiveURL.path) as? [Roll]
        return album
    }
//
//    
//    
//    //recently added function
//    
//    //func for saveing recently added rolls, by passing in a string
//    //the func will check whether the roll is predefined, and add it to the archive file
//    static func saveRecentlyAdded(for key: String) {
//        guard var recentlyAddedRolls = Roll.loadRecentlyAdded() else {
//            var emptyDict = [String : Roll]()
//            emptyDict[key] = predefinedRolls[key]
//            NSKeyedArchiver.archiveRootObject(emptyDict, toFile: Roll.recentlyAddedArchiveURL.path)
//            return
//        }
//        
//        //Prepare for not to overwrite existing recently added
//        if !recentlyAddedRolls.keys.contains(key) {
//            recentlyAddedRolls[key] = predefinedRolls[key]
//            NSKeyedArchiver.archiveRootObject(recentlyAddedRolls, toFile: Roll.recentlyAddedArchiveURL.path)
//        }
//    }
//    
//    //function to save a custom added roll to the recently added roll archive file
//    static func saveCustomAdded(roll: Roll) {
//        let customRollKey = roll.filmName + " (\(roll.format), \(roll.frameCount)exp.)"
//        
//        guard !predefinedRolls.keys.contains(customRollKey) else { return }
//        
//        guard var recentlyAddedRolls = Roll.loadRecentlyAdded() else {
//            var emptyDict = [String : Roll]()
//            emptyDict[customRollKey] = roll
//            NSKeyedArchiver.archiveRootObject(emptyDict, toFile: Roll.recentlyAddedArchiveURL.path)
//            return
//        }
//        
//        if !recentlyAddedRolls.keys.contains(customRollKey) {
//            recentlyAddedRolls[customRollKey] = roll
//            NSKeyedArchiver.archiveRootObject(recentlyAddedRolls, toFile: Roll.recentlyAddedArchiveURL.path)
//        }
//    }
    
    //Load the recently added rolls from file
    static func loadRecentlyAdded() -> [String : Roll]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Roll.recentlyAddedArchiveURL.path) as? [String: Roll]
    }
    
//    //function for delete recently added
//    static func deleteRecentlyAdded(with key: String) {
//        guard var recentlyAdded = Roll.loadRecentlyAdded() else { return }
//        recentlyAdded[key] = nil
//        NSKeyedArchiver.archiveRootObject(recentlyAdded, toFile: Roll.recentlyAddedArchiveURL.path)
//    }
}
