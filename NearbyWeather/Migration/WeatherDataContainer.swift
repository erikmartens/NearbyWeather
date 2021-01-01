//
//  WeatherDataContainer.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

/// This value type represents single location data.
/// Each WeatherInformationDTO is fetched indvidually and therefore needs its own
/// associated ErrorDataDTO. This is because each download may fail on it's own
/// while other information may still be representable.
struct WeatherDataContainer: Codable {
  var locationId: Int
  var errorDataDTO: WeatherInformationErrorDTO?
  var weatherInformationDTO: WeatherInformationDTO?
}
