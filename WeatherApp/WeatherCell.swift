//
//  LocationWeatherCell.swift
//  WeatherApp
//
//  Created by Hubert LABORDE on 22/08/2017.
//  Copyright © 2017 Hubert LABORDE. All rights reserved.
//

import UIKit

class WeatherCell: UITableViewCell {
    
    //MARK: - Assets
    
    /* Views */
    
    @IBOutlet weak var backgroundColorView: UIView!
    
    /* Labels */
    
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cloudCoverLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windspeedLabel: UILabel!
    
    
    //MARK: - Override Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
