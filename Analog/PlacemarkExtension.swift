//
//  PlacemarkExtension.swift
//  Analog
//
//  Created by Zizhou Wang on 29/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import Foundation
import MapKit

extension CLPlacemark {
    
    //used to phrase the placemark
    func phrasePlacemarkDetail() -> String {
        
        var locationDetail = ""
        
        if let thoroughfare = self.thoroughfare {
            locationDetail += thoroughfare + ", "
        }
        //check for whether the locality is the same as the administrativeArea
        if let locality = self.locality,
            let administrativeArea = self.administrativeArea {
            locationDetail += locality + ", "
            
            if administrativeArea != locality {
                locationDetail += administrativeArea + ", "
            }
        }
        if let country = self.country {
            locationDetail += country
        }
        
        return locationDetail
        
    }
}

