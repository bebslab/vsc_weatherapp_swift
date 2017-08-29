//
//  NotificationKeys.swift
//  WeatherApp
//
//  Created by Hubert LABORDE on 22/08/2017.
//  Copyright © 2017 Hubert LABORDE. All rights reserved.
//

enum NotificationKeys: String {
    case locationAuthorizationUpdated = "nearby_weather.locationAuthorizationUpdated"
    case weatherServiceUpdated_dataPullRequired = "nearby_weather.weatherServiceUpdated_dataPullRequired"
    case weatherServiceUpdated = "nearby_weather.weatherServiceUpdated"
    case apiKeyUpdated = "nearby_weather.apiKeyUpdated"
}
