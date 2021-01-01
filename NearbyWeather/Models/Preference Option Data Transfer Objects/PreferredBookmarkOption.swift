//
//  PreferredBookmark.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct PreferredBookmarkOption: Codable, PreferencesOption {
  typealias WrappedEnumType = Int?
  
  var value: Int?
  
  init(value: Int?) {
    self.value = value
  }
  
  init?(rawValue: Int) {
    return nil
  }
  
  var stringValue: String {
    let bookmarkedLocation = WeatherInformationService.shared.bookmarkedLocations.first(where: { $0.identifier == value })
    return bookmarkedLocation?.name ?? R.string.localizable.none()
  }
}
