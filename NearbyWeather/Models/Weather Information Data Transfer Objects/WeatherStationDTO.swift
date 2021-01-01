//
//  OpenWeatherMapCityDTO.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 07.01.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation
import FMDB

struct WeatherStationDTO: Codable, Equatable {
  
  static func == (lhs: WeatherStationDTO, rhs: WeatherStationDTO) -> Bool {
    return lhs.identifier == rhs.identifier
  }
  
  var identifier: Int
  var name: String
  var state: String?
  var country: String
  var coordinates: Coordinates
  
  enum CodingKeys: String, CodingKey {
    case identifier = "id"
    case name
    case state
    case country
    case coordinates = "coord"
  }
  
  init(identifier: Int, name: String, state: String, country: String, coordinates: Coordinates) {
    self.identifier = identifier
    self.name = name
    self.state = state
    self.country = country
    self.coordinates = coordinates
  }
  
  init?(from resultSet: FMResultSet) {
    guard let id = resultSet.string(forColumn: "id"),
      let identifier = Int(id),
      let state = resultSet.string(forColumn: "state"),
      let name = resultSet.string(forColumn: "name"),
      let country = resultSet.string(forColumn: "country") else {
        return nil
    }
    let latitude = resultSet.double(forColumn: "latitude")
    let longitude = resultSet.double(forColumn: "longitude")
    
    self.identifier = identifier
    self.name = name
    self.state = !state.isEmpty ? state : nil
    self.country = country
    self.coordinates = Coordinates(latitude: latitude, longitude: longitude)
  }
}

struct Coordinates: Codable {
  var latitude: Double
  var longitude: Double
  
  enum CodingKeys: String, CodingKey {
    case latitude = "lat"
    case longitude = "lon"
  }
}
