//
//  DistanceSpeedUnit.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

enum DistanceVelocityUnitValue: Int, CaseIterable, Codable {
  case metric
  case imperial
}

struct DimensionalUnitsOption: Codable, PreferencesOption {
  static let availableOptions = [DimensionalUnitsOption(value: .metric),
                                 DimensionalUnitsOption(value: .imperial)]
  
  typealias PreferencesOptionType = DistanceVelocityUnitValue
  
  private lazy var count = {
    return DistanceVelocityUnitValue.allCases.count
  }()
  
  var value: DistanceVelocityUnitValue
  
  init(value: DistanceVelocityUnitValue) {
    self.value = value
  }
  
  init?(rawValue: Int) {
    guard let value = DistanceVelocityUnitValue(rawValue: rawValue) else {
      return nil
    }
    self.init(value: value)
  }
  
  var stringValue: String {
    switch value {
    case .metric:
      return R.string.localizable.metric()
    case .imperial:
      return R.string.localizable.imperial()
    }
  }
}
