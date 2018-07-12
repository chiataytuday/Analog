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
    var format: Int16
    var frameCount: Int16
    var iso: Int16
    
    init(filmName: String, format: Int16, frameCount: Int16, iso: Int16) {
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
        let format = aDecoder.decodeObject(forKey: PropertyKeys.format) as! Int16
        let frameCount = aDecoder.decodeObject(forKey: PropertyKeys.frameCount) as! Int16
        let iso = aDecoder.decodeObject(forKey: PropertyKeys.iso) as! Int16
        
        self.init(filmName: filmName, format: format, frameCount: frameCount, iso: iso)
    }
}
