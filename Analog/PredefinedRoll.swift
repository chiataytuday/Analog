//
//  PredefinedRollsExtension.swift
//  Analog
//
//  Created by Zizhou Wang on 27/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import Foundation

public class PredefinedRoll: NSObject, NSCoding {
    
    var filmName: String
    var format: Int64
    var frameCount: Int64
    var iso: Int64
    
    init(filmName: String, format: Int64, frameCount: Int64, iso: Int64) {
        self.filmName = filmName
        self.format = format
        self.frameCount = frameCount
        self.iso = iso
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(filmName, forKey: PropertyKeys.filmName)
        aCoder.encode(format, forKey: PropertyKeys.format)
        aCoder.encode(frameCount, forKey: PropertyKeys.frameCount)
        aCoder.encode(iso, forKey: PropertyKeys.iso)
    }
    
    convenience required public init?(coder aDecoder: NSCoder) {
        let filmName = aDecoder.decodeObject(forKey: PropertyKeys.filmName) as! String
        let format = aDecoder.decodeInt64(forKey: PropertyKeys.format)
        let frameCount = aDecoder.decodeInt64(forKey: PropertyKeys.frameCount)
        let iso = aDecoder.decodeInt64(forKey: PropertyKeys.iso)
        
        self.init(filmName: filmName, format: format, frameCount: frameCount, iso: iso)
    }
}
