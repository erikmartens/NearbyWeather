//
//  BulkWeatherDataContainer.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

/// This value type represents bulk location data.
/// It contains multiple WeatherInformationDTOs but only one associated ErrorDataDTO
/// This is because the fetch either succeeds as a whole or not at all.
struct BulkWeatherDataContainer: Codable {
  var errorDataDTO: WeatherInformationErrorDTO?
  var weatherInformationDTOs: [WeatherInformationDTO]?
}
