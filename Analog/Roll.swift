//
//  Roll.swift
//  Analog
//
//  Created by Zizhou Wang on 15/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import Foundation

struct PropertyKeys {
    static let filmName = "filmName"
    static let format = "format"
    static let frameCount = "frameCount"
    static let iso = "iso"
    static let title = "title"
    static let camera = "camera"
    static let pushPull = "pushPull"
    static let frames = "frames"
    static let dateAdded = "dateAdded"
    static let lastEditedDate = "lastEditedDate"
    static let lastEditedFrame = "lastEditedFrame"
    
    //for frame object
    static let location = "location"
    static let locationName = "locationName"
    static let locationDescription = "locationDescription"
    static let hasRequestedLocationDescription = "hasRequestedLocationDescription"
    static let addDate = "addDate"
    static let aperture = "aperture"
    static let shutter = "shutter"
    static let compensation = "compensation"
    static let notes = "notes"
}

class Roll: NSObject, NSCoding {
    
    var filmName: String
    var format: Int
    var frameCount: Int
    var iso: Int
    
    //Created by user
    var title: String?
    var camera: String?
    var pushPull: Double?
    var frames: [Frame?]?
    //reserved, should not change
    var dateAdded: Date?
    var lastEditedDate: Date?
    var lastEditedFrame: Int?
    
    static let DocumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let albumArchiveURL = DocumentDirectory.appendingPathComponent("album")
    static let recentlyAddedArchiveURL = DocumentDirectory.appendingPathComponent("recentlyAdded")
    
    init(filmName: String, format: Int, frameCount: Int, iso: Int) {
        self.filmName = filmName
        self.format = format
        self.frameCount = frameCount
        self.iso = iso
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(filmName, forKey: PropertyKeys.filmName)
        aCoder.encode(format, forKey: PropertyKeys.format)
        aCoder.encode(frameCount, forKey: PropertyKeys.frameCount)
        aCoder.encode(iso, forKey: PropertyKeys.iso)
        aCoder.encode(title, forKey: PropertyKeys.title)
        aCoder.encode(camera, forKey: PropertyKeys.camera)
        aCoder.encode(pushPull, forKey: PropertyKeys.pushPull)
        aCoder.encode(frames, forKey: PropertyKeys.frames)
        aCoder.encode(dateAdded, forKey: PropertyKeys.dateAdded)
        aCoder.encode(lastEditedDate, forKey: PropertyKeys.lastEditedDate)
        aCoder.encode(lastEditedFrame, forKey: PropertyKeys.lastEditedFrame)
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        
        guard let filmName = aDecoder.decodeObject(forKey: PropertyKeys.filmName) as? String
            else { return nil }
        
        let format = aDecoder.decodeInteger(forKey: PropertyKeys.format)
        let frameCount = aDecoder.decodeInteger(forKey: PropertyKeys.frameCount)
        let iso = aDecoder.decodeInteger(forKey: PropertyKeys.iso)
        let title = aDecoder.decodeObject(forKey: PropertyKeys.title) as? String
        let camera = aDecoder.decodeObject(forKey: PropertyKeys.camera) as? String
        let pushPull = aDecoder.decodeObject(forKey: PropertyKeys.pushPull) as? Double
        let frames = aDecoder.decodeObject(forKey: PropertyKeys.frames) as? [Frame?]
        let dateAdded = aDecoder.decodeObject(forKey: PropertyKeys.dateAdded) as? Date
        let lastEditedDate = aDecoder.decodeObject(forKey: PropertyKeys.lastEditedDate) as? Date
        let lastEditedFrame = aDecoder.decodeObject(forKey: PropertyKeys.lastEditedFrame) as? Int
        
        self.init(filmName: filmName, format: format, frameCount: frameCount, iso: iso)
        self.title = title
        self.camera = camera
        self.pushPull = pushPull
        self.frames = frames
        self.dateAdded = dateAdded
        self.lastEditedDate = lastEditedDate
        self.lastEditedFrame = lastEditedFrame
    }
    
    //return equal if two objects are added at the exact same date
    override func isEqual(_ object: Any?) -> Bool {
        guard let roll = object as? Roll else {return false}
        
        return dateAdded == roll.dateAdded
    }
    
    static let predefinedRolls: [String : Roll] = [
        "Kodak Tri-X 400 (135, 36exp.)" : Roll(filmName: "Kodak Tri-X 400", format: 135, frameCount: 36, iso: 400),
        "Kodak Ektar 100 (135)" : Roll(filmName: "Kodak Ektar 100", format: 135, frameCount: 36, iso: 100),
        "Ilford HP5 Plus (135, 36exp.)" : Roll(filmName: "Ilford HP5 Plus", format: 135, frameCount: 36, iso: 400),
        "Kodak Portra 400 (135)" : Roll(filmName: "Kodak Portra 400", format: 135, frameCount: 36, iso: 400),
        "Ilford HP5 Plus (120)" : Roll(filmName: "Ilford HP5 Plus", format: 120, frameCount: 0, iso: 400),
        "Kodak Portra 800 (135)" : Roll(filmName: "Kodak Portra 800", format: 135, frameCount: 36, iso: 800),
        "Kodak T-Max 400 (135)" : Roll(filmName: "Kodak T-Max 400", format: 135, frameCount: 36, iso: 400),
        "Kodak Portra 160 (135)" : Roll(filmName: "Kodak Portra 160", format: 135, frameCount: 36, iso: 160),
        "Kodak Portra 400 (120)" : Roll(filmName: "Kodak Portra 400", format: 120, frameCount: 0, iso: 400),
        "Ilford Delta 3200 (135)" : Roll(filmName: "Ilford Delta 3200", format: 135, frameCount: 36, iso: 3200),
        "Kodak GC/UltraMax 400 (135, 36exp.)" : Roll(filmName: "Kodak GC/UltraMax 400", format: 135, frameCount: 36, iso: 400),
        "Fujichrome Provia 100F (135)" : Roll(filmName: "Fujichrome Provia 100F", format: 135, frameCount: 36, iso: 100),
        "Ilford Delta 3200 (120)" : Roll(filmName: "Ilford Delta 3200", format: 120, frameCount: 0, iso: 3200),
        "Ilford Delta 100 (120)" : Roll(filmName: "Ilford Delta 100", format: 120, frameCount: 0, iso: 100),
        "Fujicolor PRO 400H (135)" : Roll(filmName: "Fujicolor PRO 400H", format: 135, frameCount: 36, iso: 400),
        "Kodak GC/UltraMax 400 (135, 24exp.)" : Roll(filmName: "Kodak GC/UltraMax 400", format: 135, frameCount: 24, iso: 400),
        "Fujifilm Neopan 100 Acros (135)" : Roll(filmName: "Fujifilm Neopan 100 Acros", format: 135, frameCount: 36, iso: 100),
        "Kodak Ektar 100 (120)" : Roll(filmName: "Kodak Ektar 100", format: 120, frameCount: 0, iso: 100),
        "Kodak T-Max 100 (135)" : Roll(filmName: "Kodak T-Max 100", format: 135, frameCount: 36, iso: 100),
        "Ilford FP4 Plus (120)" : Roll(filmName: "Ilford FP4 Plus", format: 120, frameCount: 0, iso: 125),
        "Ilford Pan F Plus (120)" : Roll(filmName: "Ilford Pan F Plus", format: 120, frameCount: 0, iso: 50),
        "Cinestill 800Tungsten Xpro (135)" : Roll(filmName: "Cinestill 800Tungsten Xpro", format: 135, frameCount: 36, iso: 800),
        "Kodak Tri-X 400 (120)" : Roll(filmName: "Kodak Tri-X 400", format: 120, frameCount: 0, iso: 400),
        "Kodak Portra 160 (120)" : Roll(filmName: "Kodak Portra 160", format: 120, frameCount: 0, iso: 160),
        "Fujicolor Superia 1600 (135)" : Roll(filmName: "Fujicolor Superia 1600", format: 135, frameCount: 36, iso: 1600),
        "Ilford Delta 400 (120)" : Roll(filmName: "Ilford Delta 400", format: 120, frameCount: 0, iso: 400),
        "Ilford Delta 400 (135)" : Roll(filmName: "Ilford Delta 400", format: 135, frameCount: 36, iso: 400),
        "Ilford Pan F Plus (135)" : Roll(filmName: "Ilford Pan F Plus", format: 135, frameCount: 36, iso: 50),
        "Ilford Delta 100 (135)" : Roll(filmName: "Ilford Delta 100", format: 135, frameCount: 36, iso: 100),
        "Fujichrome Velvia 100 (135)" : Roll(filmName: "Fujichrome Velvia 100", format: 135, frameCount: 36, iso: 100),
        "Ilford FP4 Plus (135)" : Roll(filmName: "Ilford FP4 Plus (135)", format: 135, frameCount: 36, iso: 125),
        "AgfaPhoto Vista Plus 400 (135)" : Roll(filmName: "AgfaPhoto Vista Plus 400", format: 135, frameCount: 36, iso: 400),
        "Kodak Tri-X 400 (135, 24exp.)" : Roll(filmName: "Kodak Tri-X 400", format: 135, frameCount: 24, iso: 400),
        "Fujicolor Superia X-TRA 400 (135, 24exp.)" : Roll(filmName: "Fujicolor Superia X-TRA 400", format: 135, frameCount: 24, iso: 400),
        "Ilford XP2 Super (135)" : Roll(filmName: "Ilford XP2 Super", format: 135, frameCount: 36, iso: 400),
        "Kodak GOLD 200 (135)" : Roll(filmName: "Kodak GOLD 200", format: 135, frameCount: 36, iso: 200),
        "Kentmere 400 (135)" : Roll(filmName: "Kentmere 400", format: 135, frameCount: 36, iso: 400),
        "Fujichrome Velvia 50 (135)" : Roll(filmName: "Fujichrome Velvia 50", format: 135, frameCount: 36, iso: 50),
        "Kodak Portra 800 (120)" : Roll(filmName: "Kodak Portra 800", format: 120, frameCount: 0, iso: 800),
        "CineStill 50Daylight Xpro (135)" : Roll(filmName: "CineStill 50Daylight Xpro", format: 135, frameCount: 36, iso: 50),
        "LomoChrome Purple XR 400 (135)" : Roll(filmName: "LomoChrome Purple XR 400", format: 135, frameCount: 36, iso: 400),
        "Fujicolor PRO 400H (120)" : Roll(filmName: "Fujicolor Pro 400H", format: 120, frameCount: 0, iso: 400),
        "Fujicolor 200 (135)" : Roll(filmName: "Fujicolor 200", format: 135, frameCount: 36, iso: 200),
        "Ilford HP5 Plus (135, 24exp.)" : Roll(filmName: "Ilford HP5 Plus", format: 135, frameCount: 24, iso: 400),
        "Arista EDU Ultra 400 (135)" : Roll(filmName: "Aristra EDU Ultra 400", format: 135, frameCount: 36, iso: 400),
        "Fujicolor Supera X-Tra 400 (135)" : Roll(filmName: "Fujicolor Supera X-Tra 400", format: 135, frameCount: 36, iso: 400),
        "Aristra EDU Ultra 100 (120)" : Roll(filmName: "Aristra EDU Ultra 100", format: 120, frameCount: 0, iso: 100)
    ]
    
    //new roll adding function
    
    //Only for adding new roll use
    static func addRoll(_ roll: Roll) {
        if let loadedAlbum = Roll.loadAlbum() {
            var albumToSave = loadedAlbum
            albumToSave.insert(roll, at: 0)
            NSKeyedArchiver.archiveRootObject(albumToSave, toFile: Roll.albumArchiveURL.path)
        } else {
            var albumToSave = [Roll]()
            albumToSave.append(roll)
            NSKeyedArchiver.archiveRootObject(albumToSave, toFile: Roll.albumArchiveURL.path)
        }
    }
    
    static func loadAlbum() -> [Roll]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Roll.albumArchiveURL.path) as? [Roll]
    }
    
    
    //recently added function
    
    //func for saveing recently added rolls, by passing in a string
    //the func will check whether the roll is predefined, and add it to the archive file
    static func saveRecentlyAdded(for key: String) {
        guard var recentlyAddedRolls = Roll.loadRecentlyAdded() else {
            var emptyDict = [String : Roll]()
            emptyDict[key] = predefinedRolls[key]
            NSKeyedArchiver.archiveRootObject(emptyDict, toFile: Roll.recentlyAddedArchiveURL.path)
            return
        }
        
        //Prepare for not to overwrite existing recently added
        if !recentlyAddedRolls.keys.contains(key) {
            recentlyAddedRolls[key] = predefinedRolls[key]
            NSKeyedArchiver.archiveRootObject(recentlyAddedRolls, toFile: Roll.recentlyAddedArchiveURL.path)
        }
    }
    
    //function to save a custom added roll to the recently added roll archive file
    static func saveCustomAdded(roll: Roll) {
        let customRollKey = roll.filmName + " (\(roll.format), \(roll.frameCount)exp.)"
        
        guard !predefinedRolls.keys.contains(customRollKey) else { return }
        
        guard var recentlyAddedRolls = Roll.loadRecentlyAdded() else {
            var emptyDict = [String : Roll]()
            emptyDict[customRollKey] = roll
            NSKeyedArchiver.archiveRootObject(emptyDict, toFile: Roll.recentlyAddedArchiveURL.path)
            return
        }
        
        if !recentlyAddedRolls.keys.contains(customRollKey) {
            recentlyAddedRolls[customRollKey] = roll
            NSKeyedArchiver.archiveRootObject(recentlyAddedRolls, toFile: Roll.recentlyAddedArchiveURL.path)
        }
    }
    
    //Load the recently added rolls from file
    static func loadRecentlyAdded() -> [String : Roll]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Roll.recentlyAddedArchiveURL.path) as? [String: Roll]
    }
    
    //function for delete recently added
    static func deleteRecentlyAdded(with key: String) {
        guard var recentlyAdded = Roll.loadRecentlyAdded() else { return }
        recentlyAdded[key] = nil
        NSKeyedArchiver.archiveRootObject(recentlyAdded, toFile: Roll.recentlyAddedArchiveURL.path)
    }
    
    
    //basic roll maneuver
    //all of the method below requires an existing roll
    
    //Bug notice: :>
    //If two different row should have different date added, date edited
    //But if the user attemped to change the system time and add two rolls of the same time,
    //Previous roll will be overwritten
    static func saveRoll(for rollIndex: IndexPath, with roll: Roll) {
        guard var album = Roll.loadAlbum(), album.contains(roll) else { return }
        
        roll.lastEditedDate = Date()
        album.remove(at: rollIndex.row)
        album.insert(roll, at: 0)
        
        NSKeyedArchiver.archiveRootObject(album, toFile: albumArchiveURL.path)
    }
    
    //load a specific roll from memory
    static func loadRoll(with rollIndex: IndexPath) -> Roll? {
        guard let album = Roll.loadAlbum(), album.indices.contains(rollIndex.row) else { return nil }
        
        return album[rollIndex.row]
    }
    
    //deleting roll
    static func deleteRoll(at rollIndex: IndexPath) {
        guard var album = Roll.loadAlbum(), album.indices.contains(rollIndex.row) else { return }
        album.remove(at: rollIndex.row)
        
        NSKeyedArchiver.archiveRootObject(album, toFile: albumArchiveURL.path)
    }
    
}
