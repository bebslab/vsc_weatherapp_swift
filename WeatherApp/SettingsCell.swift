//
//  SettingsCell.swift
//  WeatherApp
//
//  Created by Hubert LABORDE on 22/08/2017.
//  Copyright © 2017 Hubert LABORDE. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    //MARK: - Assets
    
    /* Labels */
    
    @IBOutlet weak var contentLabel: UILabel!
    
    
    //MARK: - Override Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
