//
//  AmountOfResults.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

enum AmountOfResultsValue: Int, CaseIterable, Codable {
  case ten = 10
  case twenty = 20
  case thirty = 30
  case forty = 40
  case fifty = 50
}

struct AmountOfResultsOption: Codable, PreferencesOption {
  
  static let availableOptions = [AmountOfResultsOption(value: .ten),
                                 AmountOfResultsOption(value: .twenty),
                                 AmountOfResultsOption(value: .thirty),
                                 AmountOfResultsOption(value: .forty),
                                 AmountOfResultsOption(value: .fifty)]
  
  typealias PreferencesOptionType = AmountOfResultsValue
  
  private lazy var count = {
    return AmountOfResultsValue.allCases.count
  }()
  
  var value: AmountOfResultsValue
  
  init(value: AmountOfResultsValue) {
    self.value = value
  }
  
 init?(rawValue: Int) {
    guard let value = AmountOfResultsValue(rawValue: rawValue) else {
      return nil
    }
    self.init(value: value)
  }
  
  var stringValue: String {
    value.rawValue.append(contentsOf: R.string.localizable.results(), delimiter: .space)
  }
  
  var integerValue: Int {
    value.rawValue
  }
  
  var imageValue: UIImage? {
    switch value {
    case .ten:
      return R.image.ten()
    case .twenty:
      return R.image.twenty()
    case .thirty:
      return R.image.thirty()
    case .forty:
      return R.image.forty()
    case .fifty:
      return R.image.fifty()
    }
  }
}
