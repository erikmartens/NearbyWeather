//
//  SortingOrientation.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

enum SortingOrientationValue: Int, CaseIterable, Codable {
  case name
  case temperature
  case distance
}

struct SortingOrientationOption: Codable, PreferencesOption {
  static let availableOptions = [SortingOrientationOption(value: .name),
                                 SortingOrientationOption(value: .temperature),
                                 SortingOrientationOption(value: .distance)]
  
  typealias PreferencesOptionType = SortingOrientationValue
  
  private lazy var count = {
    return SortingOrientationValue.allCases.count
  }
  
  var value: SortingOrientationValue
  
  init(value: SortingOrientationValue) {
    self.value = value
  }
  
  init?(rawValue: Int) {
    guard let value = SortingOrientationValue(rawValue: rawValue) else {
      return nil
    }
    self.init(value: value)
  }
  
  var stringValue: String {
    switch value {
    case .name: return R.string.localizable.sortByName()
    case .temperature: return R.string.localizable.sortByTemperature()
    case .distance: return R.string.localizable.sortByDistance()
    }
  }
}
