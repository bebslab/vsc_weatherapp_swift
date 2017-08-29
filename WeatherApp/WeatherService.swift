//
//  Weather.swift
//  WeatherApp
//
//  Created by Hubert LABORDE on 22/08/2017.
//  Copyright © 2017 Hubert LABORDE. All rights reserved.
//

import UIKit
import Alamofire

public enum SortingOrientation: Int {
    case byWindSpeed
    case byTemperature
}

public class TemperatureUnit {
    
    static let count = 3
    
    var value: TemperatureUnitValue
    
    init(value: TemperatureUnitValue) {
        self.value = value
    }
    
    convenience init(rawValue: Int) {
        self.init(value: TemperatureUnitValue(rawValue: rawValue)!)
    }
    
    enum TemperatureUnitValue: Int {
        case celsius
        case fahrenheit
        case kelvin
    }
    
    var stringValue: String {
        switch value {
        case .celsius: return "Celsius"
        case .fahrenheit: return "Fahrenheit"
        case .kelvin: return "Kelvin"
        }
    }
}

public class AmountResults {
    
    static let count = 1
    
    var value: AmountResultsValue
    
    init(value: AmountResultsValue) {
        self.value = value
    }
    
    convenience init(rawValue: Int) {
        self.init(value: AmountResultsValue(rawValue: rawValue)!)
    }
    
    enum AmountResultsValue: Int {
        case sixteen
    }
    
    var integerValue: Int {
        switch value {
        case .sixteen: return 16
        }
    }
}

class WeatherService: NSObject, NSCoding {
    
    // MARK: - Public Assets
    
    public static var current: WeatherService!
    
    
    // MARK: - Private Assets
    
    private static let openWeather_Forecast = "http://api.openweathermap.org/data/2.5/forecast"
    
    
    // MARK: - Properties
    
    public var temperatureUnit: TemperatureUnit {
        didSet {
            WeatherService.storeService()
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.weatherServiceUpdated.rawValue), object: self)
        }
    }
    public var favoritedLocation: String {
        didSet {
            WeatherService.storeService()
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.weatherServiceUpdated_dataPullRequired.rawValue), object: self)
        }
    }
    public var amountResults: Int {
        didSet {
            WeatherService.storeService()
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.weatherServiceUpdated_dataPullRequired.rawValue), object: self)
        }
    }
    
    public var multiLocationWeatherData: [WeatherDTO]
    
    
    // MARK: - Initialization
    
    private init(favoritedLocation: String, amountResults: Int) {
        self.temperatureUnit = TemperatureUnit(value: .fahrenheit)
        self.favoritedLocation = favoritedLocation
        self.amountResults = amountResults
        
        self.multiLocationWeatherData = [WeatherDTO]()
        
        super.init()
    }
    
    internal required convenience init?(coder aDecoder: NSCoder) {
        let tempUnit = aDecoder.decodeInteger(forKey: PropertyKey.temperatureUnitKey)
        let favorite = aDecoder.decodeObject(forKey: PropertyKey.favoritedLocationKey) as! String
        let amount = aDecoder.decodeInteger(forKey: PropertyKey.amountResultsKey)
        let multiLocationWeatherData = aDecoder.decodeObject(forKey: PropertyKey.multiLocationWeatherKey) as! [WeatherDTO]
        
        self.init(favoritedLocation: favorite, amountResults: amount)
        self.temperatureUnit = TemperatureUnit(rawValue: tempUnit)
        self.amountResults = amount
        self.multiLocationWeatherData = multiLocationWeatherData
    }
    
    
    // MARK: - Public Properties & Methods
    
    public static func attachPersistentObject() {
        if let previousService: WeatherService = WeatherService.loadService() {
            WeatherService.current = previousService
        } else {
            WeatherService.current = WeatherService(favoritedLocation: "Paris", amountResults: 16)
        }
    }
    
    public func fetchData(success: @escaping ((Void) -> Void), failureType: @escaping (FailureHandler)) {
        let dataQueue = DispatchQueue(label: "weatherapp.weather_data_fetch")
        dataQueue.async {
            
            self.fetchMultiWeatherData(success: { (data) in
                self.multiLocationWeatherData = data
                success()
            }, failureType: {(failure, _) in
                failure.action()
            })
            
            DispatchQueue.main.async(execute: {
                WeatherService.storeService()
                NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.weatherServiceUpdated.rawValue), object: self)
                success()
            })
        }
    }
    
    public func sortDataBy(orientation: SortingOrientation) {
        switch orientation {
        case .byWindSpeed: multiLocationWeatherData.sort() { $0.windspeed < $1.windspeed }
        case .byTemperature: multiLocationWeatherData.sort() { $0.rawTemperature > $1.rawTemperature }
        }
        
    }
    
    
    // MARK: - Private Helper Methods
    
    /* Internal Storage Helpers*/
    
    private static func loadService() -> WeatherService? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: WeatherService.ArchiveURL.path) as? WeatherService
    }
    
    private static func storeService() {
        _ = NSKeyedArchiver.archiveRootObject(WeatherService.current, toFile: WeatherService.ArchiveURL.path)
    }
    
    /* Data Retrieval via Network */
    
    private func fetchMultiWeatherData(success: @escaping ([WeatherDTO]) -> Void , failureType: @escaping (FailureHandler)) {
        guard let apiKey = UserDefaults.standard.value(forKey: "weatherappOpenWeatherMapApiKey") else {
            return failureType(FailureReason.NotFound, NSError(domain: "", code: 401, userInfo: nil))
            
        }
        var requestedCity: String = self.favoritedLocation.replacingOccurrences(of: " ", with: "")
        requestedCity = self.favoritedLocation.folding(options: .diacriticInsensitive, locale: .current)

        
        let url:String = "\(WeatherService.openWeather_Forecast)/daily?q=\(requestedCity)&mode=json&cnt=\(amountResults)&APPID=\(apiKey)"
        
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON {response in
                if (response.result.isSuccess) {
                    let data = response.data
                    if !(data?.isEmpty)! {
                        success(self.extractMultiLocation(weatherData: data!))
                    }
                } else {
                    print("! error has occured: \(String(describing: response.error))")
                    failureType(FailureReason.NotFound, response.error! as NSError)
                }
        }
        
        
    }
    
    private func extractMultiLocation(weatherData json: Data) -> [WeatherDTO] {
        do {
            let rawData = try JSONSerialization.jsonObject(with: json, options: .mutableContainers) as! [String: AnyObject]
            let extractedData = rawData["list"]! as? [[String: AnyObject]]
            
            var multiLocationData = [WeatherDTO]()
            
            guard "200" == rawData["cod"]! as! String else {
                return [WeatherDTO]()
            }
            
            for entry in extractedData! {
                let condition = determineWeatherConditionSymbol(fromWeathercode: ((entry["weather"] as! NSArray)[0] as! [String: AnyObject])["id"]! as! Int)
                let weather = entry["weather"]! as? [[String: AnyObject]]
                var description:String = ""
                
                for entry in weather! {
                    description = entry["description"]! as! String
                }
                let date = convertToDate(timeInterval: entry["dt"]! as! Double)
                
                let title = date + ": " + description
                let rawTemperature = entry["temp"]!["max"]!! as! Double
                let cloudCoverage = entry["clouds"]! as! Double
                let humidity = entry["humidity"]! as! Double
                let windspeed = entry["speed"]! as! Double
                
                let weatherDTO = WeatherDTO(condition: condition, cityName: title, rawTemperature: rawTemperature, cloudCoverage: cloudCoverage, humidity: humidity, windspeed: windspeed)
                multiLocationData.append(weatherDTO)
            }
            //remove the first day element
            //multiLocationData.remove(at: 0)
            return multiLocationData
        }
        catch let jsonError as NSError {
            print("JSON error description: \(jsonError.description)")
            return [WeatherDTO]()
        }
    }
    
    func convertToDate(timeInterval: Double) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current //Set timezone that you want
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "EEE d MMM" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    /* Data Display Helpers */
    
    private func determineWeatherConditionSymbol(fromWeathercode: Int) -> String {
        switch fromWeathercode {
        case let x where (x >= 200 && x <= 202) || (x >= 230 && x <= 232):
            return "⛈"
        case let x where x >= 210 && x <= 211:
            return "🌩"
        case let x where x >= 212 && x <= 221:
            return "⚡️"
        case let x where x >= 300 && x <= 321:
            return "🌦"
        case let x where x >= 500 && x <= 531:
            return "🌧"
        case let x where x >= 600 && x <= 622:
            return "🌨"
        case let x where x >= 701 && x <= 771:
            return "🌫"
        case let x where x == 781 || x >= 958:
            return "🌪"
        case let x where x == 800:
            //Simulate day/night mode for clear skies condition -> sunset @ 18:00, sunrise @ 07:00
            let currentDateFormatter: DateFormatter = DateFormatter()
            currentDateFormatter.dateFormat = "ddMMyyyy"
            let currentDateString: String = currentDateFormatter.string(from: Date())
            
            let zeroHourDateFormatter: DateFormatter = DateFormatter()
            zeroHourDateFormatter.dateFormat = "ddMMyyyyHHmmss"
            let zeroHourDate = zeroHourDateFormatter.date(from: (currentDateString + "000000"))!
            
            if Date().timeIntervalSince(zeroHourDate) > 64800 || Date().timeIntervalSince(zeroHourDate) < 25200 {
                return "✨"
            }
            else {
                return "☀️"
            }
        case let x where x == 801:
            return "🌤"
        case let x where x == 802:
            return "⛅️"
        case let x where x == 803:
            return "🌥"
        case let x where x == 804:
            return "☁️"
        case let x where x >= 952 && x <= 958:
            return "💨"
        default:
            return "☀️"
        }
    }
    
    
    // MARK: - NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(temperatureUnit.value.rawValue, forKey: PropertyKey.temperatureUnitKey)
        aCoder.encode(favoritedLocation, forKey: PropertyKey.favoritedLocationKey)
        aCoder.encode(amountResults, forKey: PropertyKey.amountResultsKey)
        aCoder.encode(multiLocationWeatherData, forKey: PropertyKey.multiLocationWeatherKey)
    }
    
    struct PropertyKey {
        static let temperatureUnitKey = "temperatureUnit"
        static let favoritedLocationKey = "favoritedLocation"
        static let amountResultsKey = "chosenAmountResults"
        static let multiLocationWeatherKey = "multiLocationWeatherData"
    }
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("nearby_weather.weather_service")
}
