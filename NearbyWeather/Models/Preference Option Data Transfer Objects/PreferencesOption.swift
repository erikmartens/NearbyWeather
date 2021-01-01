//
//  PreferencesOption.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

protocol PreferencesOption {
  associatedtype PreferencesOptionType
  var value: PreferencesOptionType { get set }
  init(value: PreferencesOptionType)
  init?(rawValue: Int)
  var stringValue: String { get }
}
