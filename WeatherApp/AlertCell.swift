//
//  AlertCell.swift
//  WeatherApp
//
//  Created by Hubert LABORDE on 22/08/2017.
//  Copyright © 2017 Hubert LABORDE. All rights reserved.
//
import UIKit

class AlertCell: UITableViewCell {
    
    // MARK: - Assets
    
    /* Views */
    
    @IBOutlet weak var backgroundColorView: UIView!
    
    /* Labels */
    
    @IBOutlet weak var noticeLabel: UILabel!

    
    // MARK: - Override Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
