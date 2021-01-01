//
//  WeatherDataDTO.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 14.04.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import CoreLocation

/**
 * OWMWeatherDTO is used to parse the JSON response from the server
 * It is constructed in a way so that only the required information is parsed
 * This DTO therefore does not exactly mirror the server response
 */

struct WeatherInformationListDTO: Codable {
  var list: [WeatherInformationDTO]
  
  enum CodingKeys: String, CodingKey {
    case list
  }
}

struct WeatherInformationDTO: Codable {
  
  struct Coordinates: Codable {
    var latitude: Double?
    var longitude: Double?
    
    enum CodingKeys: String, CodingKey {
      case latitude = "lat"
      case longitude = "lon"
    }
    
    init(from decoder: Decoder) {
      let values = try? decoder.container(keyedBy: CodingKeys.self)
      
      latitude = try? values?.decodeIfPresent(Double.self, forKey: .latitude)
      longitude = try? values?.decodeIfPresent(Double.self, forKey: .longitude)
    }
  }
  
  struct WeatherCondition: Codable {
    var identifier: Int?
    var conditionName: String?
    var conditionDescription: String?
    var conditionIconCode: String?
    
    enum CodingKeys: String, CodingKey {
      case identifier = "id"
      case conditionName = "main"
      case conditionDescription = "description"
      case conditionIconCode = "icon"
    }
    
    init(from decoder: Decoder) {
      let values = try? decoder.container(keyedBy: CodingKeys.self)
      
      identifier = try? values?.decodeIfPresent(Int.self, forKey: .identifier)
      conditionName = try? values?.decodeIfPresent(String.self, forKey: .conditionName)
      conditionDescription = try? values?.decodeIfPresent(String.self, forKey: .conditionDescription)
      conditionIconCode = try? values?.decodeIfPresent(String.self, forKey: .conditionIconCode)
    }
  }
  
  struct AtmosphericInformation: Codable {
    var temperatureKelvin: Double?
    var pressurePsi: Double?
    var humidity: Double?
    
    enum CodingKeys: String, CodingKey {
      case temperatureKelvin = "temp"
      case pressurePsi = "pressure"
      case humidity
    }
    
    init(from decoder: Decoder) {
      let values = try? decoder.container(keyedBy: CodingKeys.self)
      
      temperatureKelvin = try? values?.decodeIfPresent(Double.self, forKey: .temperatureKelvin)
      pressurePsi = try? values?.decodeIfPresent(Double.self, forKey: .pressurePsi)
      humidity = try? values?.decodeIfPresent(Double.self, forKey: .humidity)
    }
  }
  
  struct WindInformation: Codable {
    var windspeed: Double?
    var degrees: Double?
    
    enum CodingKeys: String, CodingKey {
      case windspeed = "speed"
      case degrees = "deg"
    }
    
    init(from decoder: Decoder) {
      let values = try? decoder.container(keyedBy: CodingKeys.self)
      
      windspeed = try? values?.decodeIfPresent(Double.self, forKey: .windspeed)
      degrees = try? values?.decodeIfPresent(Double.self, forKey: .degrees)
    }
  }
  
  struct CloudCoverage: Codable {
    var coverage: Double?
    
    enum CodingKeys: String, CodingKey {
      case coverage = "all"
    }
    
    init(from decoder: Decoder) {
      let values = try? decoder.container(keyedBy: CodingKeys.self)
      
      coverage = try? values?.decodeIfPresent(Double.self, forKey: .coverage)
    }
  }
  
  struct DaytimeInformation: Codable {
    /// multi location weather data does not contain this information
    
    var sunrise: Double?
    var sunset: Double?
    
    enum CodingKeys: String, CodingKey {
      case sunrise
      case sunset
    }
    
    init(from decoder: Decoder) {
      let values = try? decoder.container(keyedBy: CodingKeys.self)
      
      sunrise = try? values?.decodeIfPresent(Double.self, forKey: .sunrise)
      sunset = try? values?.decodeIfPresent(Double.self, forKey: .sunset)
    }
  }
  
  var cityID: Int
  var cityName: String
  var coordinates: Coordinates
  var weatherCondition: [WeatherCondition]
  var atmosphericInformation: AtmosphericInformation
  var windInformation: WindInformation
  var cloudCoverage: CloudCoverage
  var daytimeInformation: DaytimeInformation
  
  enum CodingKeys: String, CodingKey {
    case cityID = "id"
    case cityName = "name"
    case coordinates = "coord"
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
    self.coordinates = try values.decode(Coordinates.self, forKey: .coordinates)
    self.weatherCondition = try values.decode([WeatherCondition].self, forKey: .weatherCondition)
    self.atmosphericInformation = try values.decode(AtmosphericInformation.self, forKey: .atmosphericInformation)
    self.windInformation = try values.decode(WindInformation.self, forKey: .windInformation)
    self.cloudCoverage = try values.decode(CloudCoverage.self, forKey: .cloudCoverage)
    self.daytimeInformation = try values.decode(DaytimeInformation.self, forKey: .daytimeInformation)
  }
}
