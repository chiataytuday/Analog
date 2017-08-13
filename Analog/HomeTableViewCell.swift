//
//  HomeTableViewCell.swift
//  Analog
//
//  Created by Zizhou Wang on 20/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import UIKit

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
    func update(with roll: Roll) {
        filmTypeImage.image = UIImage(named: "\(roll.format)")
        
        if roll.title == nil {
            titleLabel.textColor = .lightGray
            titleLabel.text = "Untitled Roll"
        } else {
            titleLabel.textColor = .black
            titleLabel.text = roll.title
        }
        
        var evString = ""
        if let pushPull = roll.pushPull {
            if pushPull > 0 {
                evString = ", pushed \(Int(pushPull))"
            } else if pushPull < 0 {
                evString = ", pulled \(-Int(pushPull))"
            }
        }
        
        if roll.camera == nil  {
            rollDetailLabel.text = roll.filmName + evString
        } else {
            rollDetailLabel.text = roll.filmName + ", " + (roll.camera ?? "Camera missing") + evString
        }
        
        
        let dateFormatter = DateFormatter()
        
        if let dateAdded = roll.dateAdded {
            dateFormatter.dateStyle = .full
            let date = dateFormatter.string(from: dateAdded)
            addedDateLabel.text = date
        }
        
        if let lastEdited = roll.lastEditedDate {
            if Calendar.current.isDateInToday(lastEdited) {
                dateFormatter.dateFormat = "h:mm a"
                lastEditLabel.text = dateFormatter.string(from: lastEdited)
            } else {
                dateFormatter.dateStyle = .short
                lastEditLabel.text = dateFormatter.string(from: lastEdited)
            }
        } else {
            if let dateAdded = roll.dateAdded {
                                
                if Calendar.current.isDateInToday(dateAdded) {
                    dateFormatter.dateFormat = "h:mm a"
                    lastEditLabel.text = dateFormatter.string(from: dateAdded)
                } else {
                    dateFormatter.dateStyle = .short
                    lastEditLabel.text = dateFormatter.string(from: dateAdded)
                }
            }
        }
        
        if let frames = roll.frames {
            var lastFrame: Int?
            
            for index in frames.indices {
                if frames[index] != nil {
                    lastFrame = index + 1
                }
            }
            
            if let lastFrame = lastFrame {
                frameCountLabel.text = "\(lastFrame)/\(roll.frameCount)"
            } else {
                frameCountLabel.text = "0/\(roll.frameCount)"
            }
            
        }
        
        //end of cell update method
    }
    

}
