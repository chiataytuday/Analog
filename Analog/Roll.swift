//
//  Roll.swift
//  Analog
//
//  Created by Zizhou Wang on 15/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import Foundation

struct PropertyKeys {
    static let frames = "frames"
    static let film = "film"
    static let iso = "iso"
    static let camera = "camera"
    static let frameCount = "frameCount"
    static let pushPull = "pushPull"
    static let dateAdded = "dateAdded"
}

class Roll: NSObject, NSCoding {
    var frames = [Frame]()
    var film: String
    var iso: Int
    var frameCount: Int
    //Only camera, pushPull info is optional
    var camera: String?
    var pushPull: Double?
    var dateAdded = Date()
    
    static let DocumentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveURL = DocumentDirectory.appendingPathComponent("rolls")
    
    
    init(film: String, iso: Int, frameCount: Int, camera: String?, pushPull: Double?) {
        self.film = film
        self.iso = iso
        self.frameCount = frameCount
        self.camera = camera
        self.pushPull = pushPull
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(frames, forKey: PropertyKeys.frames)
        aCoder.encode(film, forKey: PropertyKeys.film)
        aCoder.encode(iso, forKey: PropertyKeys.iso)
        aCoder.encode(camera, forKey: PropertyKeys.camera)
        aCoder.encode(frameCount, forKey: PropertyKeys.frameCount)
        aCoder.encode(pushPull, forKey: PropertyKeys.pushPull)
        aCoder.encode(dateAdded, forKey: PropertyKeys.dateAdded)
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        
        guard let film = aDecoder.decodeObject(forKey: PropertyKeys.film) as? String,
            let iso = aDecoder.decodeObject(forKey: PropertyKeys.iso) as? Int,
            let frameCount = aDecoder.decodeObject(forKey: PropertyKeys.frameCount) as? Int,
            let frames = aDecoder.decodeObject(forKey: PropertyKeys.frames) as? [Frame],
            let dateAdded = aDecoder.decodeObject(forKey: PropertyKeys.dateAdded) as? Date
        else { return nil }
        
        let camera = aDecoder.decodeObject(forKey: PropertyKeys.camera) as? String
        let pushPull = aDecoder.decodeObject(forKey: PropertyKeys.pushPull) as? Double
        
        self.init(film: film, iso: iso, frameCount: frameCount, camera: camera, pushPull: pushPull)
        self.frames = frames
        self.dateAdded = dateAdded
    }
}
