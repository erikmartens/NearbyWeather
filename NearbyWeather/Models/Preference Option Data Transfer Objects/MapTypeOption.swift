//
//  MapTypeOption.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import MapKit

enum MapTypeValue: Int, CaseIterable, Codable {
  case standard
  case satellite
  case hybrid
  
  var mkMapTypeOption: MKMapType {
    switch self {
    case .standard:
      return .standard
    case .satellite:
      return .satellite
    case .hybrid:
      return .hybrid
    }
  }
  
  var title: String {
    switch self {
    case .standard:
      return R.string.localizable.map_type_standard()
    case .satellite:
      return R.string.localizable.map_type_satellite()
    case .hybrid:
      return R.string.localizable.map_type_hybrid()
    }
  }
}

struct MapTypeOption: Codable, PreferencesOption {
  static let availableOptions = [MapTypeOption(value: .standard),
                                 MapTypeOption(value: .satellite),
                                 MapTypeOption(value: .hybrid)]
  
  typealias PreferencesOptionType = MapTypeValue
  
  private lazy var count = {
    MapTypeValue.allCases.count
  }()
  
  var value: MapTypeValue
  
  init(value: MapTypeValue) {
    self.value = value
  }
  
  init?(rawValue: Int) {
    guard let value = MapTypeValue(rawValue: rawValue) else {
      return nil
    }
    self.init(value: value)
  }
  
  var stringValue: String {
    value.title
  }
}
