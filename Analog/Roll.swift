//
//  Roll.swift
//  Analog
//
//  Created by Zizhou Wang on 15/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import Foundation


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
    var lastAddedFrame: Int?
    var currentLens: Int?
    
    //data io serial queue
    static let dataIOQueue = DispatchQueue(label: "com.Analog.dataIOQueue")
    
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
        aCoder.encode(lastAddedFrame, forKey: PropertyKeys.lastAddedFrame)
        aCoder.encode(currentLens, forKey: PropertyKeys.currentLens)
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
        let lastAddedFrame = aDecoder.decodeObject(forKey: PropertyKeys.lastAddedFrame) as? Int
        let currentLens = aDecoder.decodeObject(forKey: PropertyKeys.currentLens) as? Int
        
        self.init(filmName: filmName, format: format, frameCount: frameCount, iso: iso)
        self.title = title
        self.camera = camera
        self.pushPull = pushPull
        self.frames = frames
        self.dateAdded = dateAdded
        self.lastEditedDate = lastEditedDate
        self.lastAddedFrame = lastAddedFrame
        self.currentLens = currentLens
    }
    
    //return equal if two objects are added at the exact same date
    override func isEqual(_ object: Any?) -> Bool {
        guard let roll = object as? Roll else {return false}
        
        return dateAdded == roll.dateAdded
    }
    
}
