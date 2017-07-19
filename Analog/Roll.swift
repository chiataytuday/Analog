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
    static let frameCount = "frames"
    static let iso = "iso"
    static let title = "title"
    static let camera = "camera"
    static let pushPull = "pushPull"
    static let frames = "frames"
    static let dateAdded = "dateAdded"
    static let lastEdited = "lastEdited"
}

class Roll: NSObject, NSCoding {
    
    var filmName: String
    var format: Int
    var frameCount: Int?
    var iso: Int
    
    //Created by user
    var title: String?
    var camera: String?
    var pushPull: Double?
    var frames: [Frame]?
    var dateAdded: Date?
    var lastEdited: Date?
    
    static let DocumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveURL = DocumentDirectory.appendingPathComponent("rolls")
    
    init(filmName: String, format: Int, frameCount: Int?, iso: Int) {
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
        aCoder.encode(lastEdited, forKey: PropertyKeys.lastEdited)
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        
        guard let filmName = aDecoder.decodeObject(forKey: PropertyKeys.filmName) as? String,
            let format = aDecoder.decodeObject(forKey: PropertyKeys.format) as? Int,
            let iso = aDecoder.decodeObject(forKey: PropertyKeys.iso) as? Int
        else { return nil }
        
        let frameCount = aDecoder.decodeObject(forKey: PropertyKeys.frameCount) as? Int
        let title = aDecoder.decodeObject(forKey: PropertyKeys.title) as? String
        let camera = aDecoder.decodeObject(forKey: PropertyKeys.camera) as? String
        let pushPull = aDecoder.decodeDouble(forKey: PropertyKeys.pushPull)
        let frames = aDecoder.decodeObject(forKey: PropertyKeys.frames) as? [Frame]
        let dateAdded = aDecoder.decodeObject(forKey: PropertyKeys.dateAdded) as? Date
        let lastEdited = aDecoder.decodeObject(forKey: PropertyKeys.lastEdited) as? Date
        
        self.init(filmName: filmName, format: format, frameCount: frameCount, iso: iso)
        self.title = title
        self.camera = camera
        self.pushPull = pushPull
        self.frames = frames
        self.dateAdded = dateAdded
        self.lastEdited = lastEdited
    }
}
