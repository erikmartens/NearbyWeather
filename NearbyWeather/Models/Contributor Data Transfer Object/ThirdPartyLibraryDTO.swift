//
//  ThirdPartyLibraryDTO.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 29.10.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct ThirdPartyLibraryArrayWrapper: Codable {
  var elements: [ThirdPartyLibraryDTO]
}

struct ThirdPartyLibraryDTO: Codable {
  var name: String
  var urlString: String
}
