//
//  ConversionService.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 09.01.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation
import MapKit
import APTimeZones

final class ConversionWorker {
  
  static func weatherConditionSymbol(fromWeatherCode code: Int?, isDayTime: Bool?) -> String {
    guard let code = code else {
      return "❓"
    }
    switch code {
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
    case let x where x >= 600 && x <= 602:
      return "☃️"
    case let x where x >= 603 && x <= 622:
      return "🌨"
    case let x where x >= 701 && x <= 771:
      return "🌫"
    case let x where x == 781 || x == 900:
      return "🌪"
    case let x where x == 800:
      return (isDayTime ?? false) ? "☀️" : "🌕"
    case let x where x == 801:
      return "🌤"
    case let x where x == 802:
      return "⛅️"
    case let x where x == 803:
      return "🌥"
    case let x where x == 804:
      return "☁️"
    case let x where x >= 952 && x <= 956 || x == 905:
      return "🌬"
    case let x where x >= 957 && x <= 961 || x == 771:
      return "💨"
    case let x where x == 901 || x == 902 || x == 962:
      return "🌀"
    case let x where x == 903:
      return "❄️"
    case let x where x == 904:
      return "🌡"
    case let x where x == 962:
      return "🌋"
    default:
      return "❓"
    }
  }
  
  static func temperatureIntValue(forTemperatureUnit temperatureUnit: TemperatureUnitOption, fromRawTemperature rawTemperature: Double) -> Int? {
    let adjustedTemp: Double
    switch temperatureUnit.value {
    case .celsius:
      adjustedTemp = rawTemperature - 273.15
    case . fahrenheit:
      adjustedTemp = rawTemperature * (9/5) - 459.67
    case .kelvin:
      adjustedTemp = rawTemperature
    }
    
    guard !adjustedTemp.isNaN && adjustedTemp.isFinite else { return nil }
    return Int(adjustedTemp.rounded())
  }
  
  static func temperatureDescriptor(forTemperatureUnit temperatureUnit: TemperatureUnitOption, fromRawTemperature rawTemperature: Double?) -> String? {
    guard let rawTemperature = rawTemperature else {
      return nil
    }
    switch temperatureUnit.value {
    case .celsius:
      return String(format: "%.02f", rawTemperature - 273.15).append(contentsOf: "°C", delimiter: .none)
    case . fahrenheit:
      return String(format: "%.02f", rawTemperature * (9/5) - 459.67).append(contentsOf: "°F", delimiter: .none)
    case .kelvin:
      return String(format: "%.02f", rawTemperature).append(contentsOf: "°K", delimiter: .none)
    }
  }
  
  static func windspeedDescriptor(forDistanceSpeedUnit distanceSpeedUnit: DimensionalUnitsOption, forWindspeed windspeed: Double?) -> String? {
    guard let windspeed = windspeed else {
      return nil
    }
    switch distanceSpeedUnit.value {
    case .metric:
      return String(format: "%.02f", windspeed).append(contentsOf: R.string.localizable.kph(), delimiter: .space)
    case .imperial:
      return String(format: "%.02f", windspeed / 1.609344).append(contentsOf: R.string.localizable.mph(), delimiter: .space)
    }
  }
  
  static func distanceDescriptor(forDistanceSpeedUnit distanceSpeedUnit: DimensionalUnitsOption, forDistanceInMetres distance: Double) -> String {
    switch distanceSpeedUnit.value {
    case .metric:
      return String(format: "%.02f", distance/1000).append(contentsOf: R.string.localizable.km(), delimiter: .space)
    case .imperial:
      return String(format: "%.02f", distance/1609.344).append(contentsOf: R.string.localizable.mi(), delimiter: .space)
    }
  }
  
  static func windDirectionDescriptor(forWindDirection degrees: Double) -> String {
    return String(format: "%.02f", degrees).append(contentsOf: "°", delimiter: .none)
  }
  
  static func isDayTime(for dayTimeInformation: WeatherInformationDTO.DaytimeInformation?, coordinates: WeatherInformationDTO.Coordinates) -> Bool? {
    
    guard let sunrise =  dayTimeInformation?.sunrise,
      let sunset =  dayTimeInformation?.sunset,
      let latitude = coordinates.latitude,
      let longitude = coordinates.longitude else {
        return nil
    }
    
    let location = CLLocation(latitude: latitude, longitude: longitude)
    
    var calendar = Calendar.current
    calendar.timeZone = location.timeZone()
    
    let currentTimeDateComponents = calendar.dateComponents([.hour, .minute], from: Date())
    let sunriseDate = Date(timeIntervalSince1970: sunrise)
    let sunriseDateComponents = calendar.dateComponents([.hour, .minute], from: sunriseDate)
    let sunsetDate = Date(timeIntervalSince1970: sunset)
    let sunsetDateComponents = calendar.dateComponents([.hour, .minute], from: sunsetDate)
    
    guard let currentTimeDateComponentHour = currentTimeDateComponents.hour,
      let currentTimeDateComponentMinute = currentTimeDateComponents.minute,
      let sunriseDateComponentHour = sunriseDateComponents.hour,
      let sunriseDateComponentMinute = sunriseDateComponents.minute,
      let sunsetDateComponentHour = sunsetDateComponents.hour,
      let sunsetDateComponentMinute = sunsetDateComponents.minute else {
        return nil
    }
    
    return ((currentTimeDateComponentHour == sunriseDateComponentHour
      && currentTimeDateComponentMinute >= sunriseDateComponentMinute)
      || currentTimeDateComponentHour > sunriseDateComponentHour)
      && ((currentTimeDateComponentHour == sunsetDateComponentHour
        && currentTimeDateComponentMinute <= sunsetDateComponentMinute)
        || currentTimeDateComponentHour < sunsetDateComponentHour)
  }
  
  static func countryName(for countryCode: String) -> String? {
    Locale.current.localizedString(forRegionCode: countryCode)
  }
  
  static func usStateName(for stateCode: String) -> String? {
    UnitedStatesOfAmericaStatesList.statesDictionary[stateCode]
  }
}
