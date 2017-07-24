//
//  Frame.swift
//  Analog
//
//  Created by Zizhou Wang on 15/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import Foundation
import MapKit

class Frame: NSObject, NSCoding {
    
    var location: CLLocation?
    var locationName: String?
    var locationDescription: String?
    var hasRequestedLocationDescription = false
    var addDate: Date
    var aperture: Double?
    var shutter: Int?
    var compensation: Double?
    var notes: String?
    
    
    init(location: CLLocation?, locationName: String?, locationDescription: String?, addDate: Date, aperture: Double?, shutter: Int?, compensation: Double?, notes: String?) {
        self.location = location
        self.locationName = locationName
        self.locationDescription = locationDescription
        self.addDate = addDate
        self.aperture = aperture
        self.shutter = shutter
        self.compensation = compensation
        self.notes = notes
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(location, forKey: PropertyKeys.location)
        aCoder.encode(locationName, forKey: PropertyKeys.locationName)
        aCoder.encode(locationDescription, forKey: PropertyKeys.locationDescription)
        aCoder.encode(hasRequestedLocationDescription, forKey: PropertyKeys.hasRequestedLocationDescription)
        aCoder.encode(addDate, forKey: PropertyKeys.addDate)
        aCoder.encode(aperture, forKey: PropertyKeys.aperture)
        aCoder.encode(shutter, forKey: PropertyKeys.shutter)
        aCoder.encode(compensation, forKey: PropertyKeys.compensation)
        aCoder.encode(notes, forKey: PropertyKeys.notes)
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        guard let addDate = aDecoder.decodeObject(forKey: PropertyKeys.addDate) as? Date
            else { return nil }
        
        let location = aDecoder.decodeObject(forKey: PropertyKeys.location) as? CLLocation
        let locationName = aDecoder.decodeObject(forKey: PropertyKeys.locationName) as? String
        let locationDescription = aDecoder.decodeObject(forKey: PropertyKeys.locationDescription) as? String
        let hasRequestedLocationDescription = aDecoder.decodeBool(forKey: PropertyKeys.hasRequestedLocationDescription)
        let aperture = aDecoder.decodeObject(forKey: PropertyKeys.aperture) as? Double
        let shutter = aDecoder.decodeObject(forKey: PropertyKeys.shutter) as? Int
        let compensation = aDecoder.decodeObject(forKey: PropertyKeys.compensation) as? Double
        let notes = aDecoder.decodeObject(forKey: PropertyKeys.notes) as? String
        
        self.init(location: location, locationName: locationName, locationDescription: locationDescription, addDate: addDate, aperture: aperture, shutter: shutter, compensation: compensation, notes: notes)
        self.hasRequestedLocationDescription = hasRequestedLocationDescription
    }
    
    
    
}
