//
//  HomeTableViewCell.swift
//  Analog
//
//  Created by Zizhou Wang on 20/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import UIKit
import TimeAgoInWords

class HomeTableViewCell: UITableViewCell {

    
    @IBOutlet weak var filmTypeImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rollDetailLabel: UILabel!
    
    @IBOutlet weak var addedDateLabel: UILabel!
    @IBOutlet weak var lastEditLabel: UILabel!
    @IBOutlet weak var frameCountLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //called by the table view, update all the info related to the roll
    func update(with roll: NewRoll) {
        filmTypeImage.image = UIImage(named: "\(roll.format)")
        
        if roll.title == nil {
            titleLabel.textColor = .lightGray
            titleLabel.text = "Untitled Roll"
        } else {
            titleLabel.textColor = .black
            titleLabel.text = roll.title
        }
        
        var evString = ""
        let pushPull = roll.pushPull
        
        if pushPull > 0 {
            evString = ", \(-Int(pushPull))ev"
        } else if pushPull < 0 {
            evString = ", +\(-Int(pushPull))ev"
        }
        
        if let filmName = roll.filmName {
            if roll.camera == nil  {
                rollDetailLabel.text = filmName + evString
            } else {
                rollDetailLabel.text = filmName + ", " + (roll.camera ?? "Camera missing") + evString
            }
        }
        
        
        let dateFormatter = DateFormatter()
        
        if let dateAdded = roll.dateAdded {
            dateFormatter.dateStyle = .full
            let date = dateFormatter.string(from: dateAdded)
            addedDateLabel.text = date
        }
        
        if let lastEdited = roll.lastEditedDate {
            lastEditLabel.text = lastEdited.timeAgoInWords()
//            if Calendar.current.isDateInToday(lastEdited) {
//                dateFormatter.dateFormat = "h:mm a"
//                lastEditLabel.text = dateFormatter.string(from: lastEdited)
//            } else {
//                dateFormatter.dateStyle = .short
//                lastEditLabel.text = dateFormatter.string(from: lastEdited)
//            }
        } else {
            if let dateAdded = roll.dateAdded {
                lastEditLabel.text = dateAdded.timeAgoInWords()
//                if Calendar.current.isDateInToday(dateAdded) {
//                    dateFormatter.dateFormat = "h:mm a"
//                    lastEditLabel.text = dateFormatter.string(from: dateAdded)
//                } else {
//                    dateFormatter.dateStyle = .short
//                    lastEditLabel.text = dateFormatter.string(from: dateAdded)
//                }
            }
        }
        
        let largestFrame = roll.frames?.max(by: { (f1, f2) -> Bool in
            let frame1 = f1 as! NewFrame
            let frame2 = f2 as! NewFrame
            
            if frame1.index < frame2.index {
                return true
            } else {
                return false
            }
        }) as? NewFrame
        
        var largestFrameIndex:Int64 = 0
        
        if let largestFrame = largestFrame {
            largestFrameIndex = largestFrame.index + 1
        }
        
        frameCountLabel.text = "\(largestFrameIndex)/\(roll.frameCount)"
        
        
        //end of cell update method
    }
    

}
