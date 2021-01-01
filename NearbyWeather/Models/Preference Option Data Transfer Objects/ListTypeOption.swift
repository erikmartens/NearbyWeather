//
//  ListTypeOption.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

enum ListTypeValue: Int, CaseIterable, Codable {
  case bookmarked
  case nearby
  
  var title: String {
    switch self {
    case .bookmarked:
      return R.string.localizable.bookmarked()
    case .nearby:
      return R.string.localizable.nearby()
    }
  }
}

struct ListTypeOption: Codable, PreferencesOption {
  
  static let availableOptions = [ListTypeOption(value: .bookmarked),
                                 ListTypeOption(value: .nearby)]
  
  typealias PreferencesOptionType = ListTypeValue
  
  private lazy var count = {
    ListTypeValue.allCases.count
  }()
  
  var value: ListTypeValue
  
  init(value: ListTypeValue) {
    self.value = value
  }
  
  init?(rawValue: Int) {
    guard let value = ListTypeValue(rawValue: rawValue) else {
      return nil
    }
    self.init(value: value)
  }
  
  var stringValue: String {
    value.title
  }
}
