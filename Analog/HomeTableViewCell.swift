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

        // Configure the view for the selected state
    }
    
    func update(with roll: Roll) {
        filmTypeImage.image = UIImage(named: "\(roll.format)")
        
        if roll.title == nil {
            titleLabel.textColor = .lightGray
            titleLabel.text = "Untitled Roll"
        } else {
            titleLabel.textColor = .black
            titleLabel.text = roll.title
        }
        
        if roll.camera == nil  {
            rollDetailLabel.text = roll.filmName
        } else {
            rollDetailLabel.text = roll.filmName + ", " + (roll.camera ?? "Camera missing")
        }
        
        let dateFormatter = DateFormatter()
        
        if let dateAdded = roll.dateAdded {
            dateFormatter.dateStyle = .full
            let date = dateFormatter.string(from: dateAdded)
            addedDateLabel.text = date
        }
        
        if let lastEdited = roll.lastEditedDate {
            let now = Date()
            if now.timeIntervalSince(lastEdited) > 86400 {
                dateFormatter.dateStyle = .short
                lastEditLabel.text = dateFormatter.string(from: lastEdited)
            } else {
                dateFormatter.dateFormat = "h:mm a"
                lastEditLabel.text = dateFormatter.string(from: lastEdited)
            }
        } else {
            if let dateAdded = roll.dateAdded {
                let now = Date()
                if now.timeIntervalSince(dateAdded) > 86400 {
                    dateFormatter.dateStyle = .short
                    lastEditLabel.text = dateFormatter.string(from: dateAdded)
                } else {
                    dateFormatter.dateFormat = "h:mm a"
                    lastEditLabel.text = dateFormatter.string(from: dateAdded)
                }
            }
        }
        
        if let frames = roll.frames {
            let filtered = frames.filter({ (frame) -> Bool in
                frame != nil
            })
            frameCountLabel.text = "\(filtered.count)/\(roll.frameCount)"
            
        }
        
        
    }
    

}
