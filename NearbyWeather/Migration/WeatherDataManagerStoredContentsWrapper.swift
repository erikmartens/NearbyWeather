//
//  WeatherDataManagerStoredContentsWrapper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct WeatherDataManagerStoredContentsWrapper: Codable {
  var bookmarkedLocations: [WeatherStationDTO]
  var bookmarkedWeatherDataObjects: [WeatherDataContainer]?
  var nearbyWeatherDataObject: BulkWeatherDataContainer?
}
