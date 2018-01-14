//
//  WeatherDTO.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 14.04.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit

/**
 * OWMWeatherDTO is used to parse the JSON response from the server
 * It is constructed in a way so that only the required information is parsed
 * This DTO therefore does not exactly mirror the server response
 */

struct OWMWeatherDTO: Codable {
    
    struct WeatherCondition: Codable {
        var identifier: Int
        var conditionName: String
        var conditionDescription: String
        var conditionIconCode: String
        
        enum CodingKeys: String, CodingKey {
            case identifier = "id"
            case conditionName = "main"
            case conditionDescription = "description"
            case conditionIconCode = "icon"
        }
    }
    
    struct AtmosphericInformation: Codable {
        var temperatureKelvin: Double
        var pressurePsi: Int
        var humidity: Int
        
        enum CodingKeys: String, CodingKey {
            case temperatureKelvin = "temp"
            case pressurePsi = "pressure"
            case humidity
        }
    }
    
    struct WindInformation: Codable {
        var windspeed: Double
        var degrees: Double
        
        enum CodingKeys: String, CodingKey {
            case windspeed = "speed"
            case degrees = "deg"
        }
    }
    
    struct CloudCoverage: Codable {
        var coverage: Int
        
        enum CodingKeys: String, CodingKey {
            case coverage = "all"
        }
    }
    
    struct DaytimeInformation: Codable {
        var sunrise: Int?
        var sunset: Int?
        
        enum CodingKeys: String, CodingKey {
            case sunrise
            case sunset
        }
    }
    
    var cityID: Int
    var cityName: String
    var weatherCondition: [WeatherCondition]
    var atmosphericInformation: AtmosphericInformation
    var windInformation: WindInformation
    var cloudCoverage: CloudCoverage
    var daytimeInformation: DaytimeInformation? // multi location weather data does not contain this information
    
    enum CodingKeys: String, CodingKey {
        case cityID = "id"
        case cityName = "name"
        case weatherCondition = "weather"
        case atmosphericInformation = "main"
        case windInformation = "wind"
        case cloudCoverage = "clouds"
        case daytimeInformation = "sys"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.cityID = try values.decode(Int.self, forKey: .cityID)
        self.cityName = try values.decode(String.self, forKey: .cityName)
        self.weatherCondition = try values.decode([WeatherCondition].self, forKey: .weatherCondition)
        self.atmosphericInformation = try values.decode(AtmosphericInformation.self, forKey: .atmosphericInformation)
        self.windInformation = try values.decode(WindInformation.self, forKey: .windInformation)
        self.cloudCoverage = try values.decode(CloudCoverage.self, forKey: .cloudCoverage)
        
        if values.contains(.daytimeInformation) {
            let daytimeInformation = try values.nestedContainer(keyedBy: DaytimeInformation.CodingKeys.self, forKey: .daytimeInformation)
            let sunrise = try daytimeInformation.decodeIfPresent(Int.self, forKey: DaytimeInformation.CodingKeys.sunrise)
            let sunset = try daytimeInformation.decodeIfPresent(Int.self, forKey: DaytimeInformation.CodingKeys.sunset)
            self.daytimeInformation = DaytimeInformation(sunrise: sunrise, sunset: sunset)
        } else {
            self.daytimeInformation = nil
        }
    }
}

struct OWMMultiWeatherDTO: Codable {
    var list: [OWMWeatherDTO]
    
    enum CodingKeys: String, CodingKey {
        case list
    }
}
