//
//  ListWeatherInformationTableCellModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

struct WeatherListInformationTableViewCellModel {
  let weatherConditionSymbol: String?
  let temperature: String?
  let cloudCoverage: String?
  let humidity: String?
  let windspeed: String?
  let backgroundColor: UIColor?
  
  init(
    weatherConditionSymbol: String? = nil,
    temperature: String? = nil,
    cloudCoverage: String? = nil,
    humidity: String? = nil,
    windspeed: String? = nil,
    backgroundColor: UIColor? = nil
  ) {
    self.weatherConditionSymbol = weatherConditionSymbol
    self.temperature = temperature
    self.cloudCoverage = cloudCoverage
    self.humidity = humidity
    self.windspeed = windspeed
    self.backgroundColor = backgroundColor
  }
}
