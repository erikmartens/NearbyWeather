//
//  PreferencesManagerStoredContentsWrapper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct PreferencesManagerStoredContentsWrapper: Codable {
  var preferredBookmark: PreferredBookmarkOption
  var amountOfResults: AmountOfResultsOption
  var temperatureUnit: TemperatureUnitOption
  var windspeedUnit: DimensionalUnitsOption
  var sortingOrientation: SortingOrientationOption
}
