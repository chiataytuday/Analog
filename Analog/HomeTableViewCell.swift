//
//  HomeTableViewCell.swift
//  Analog
//
//  Created by Zizhou Wang on 20/07/2017.
//  Copyright © 2017 Zizhou Wang. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var filmInfoDescriptionLabel: UILabel!
    @IBOutlet weak var filmTypeImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cameraLabel: UILabel!
    
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
        
        if let camera = roll.camera {
            cameraLabel.text = camera
        }
        
        filmInfoDescriptionLabel.text = roll.filmName + ", frame: \(roll.frameCount), iso: \(roll.iso)"
        dateLabel.text = roll.dateAdded?.description
    }

}
