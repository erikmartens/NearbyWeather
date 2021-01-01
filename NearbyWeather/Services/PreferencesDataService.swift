//
//  PreferencesManager.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 11.02.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import MapKit

protocol StoredPreferencesProvider {
  var preferredBookmark: PreferredBookmarkOption { get set }
  var amountOfResults: AmountOfResultsOption { get set }
  var temperatureUnit: TemperatureUnitOption { get set }
  var distanceSpeedUnit: DimensionalUnitsOption { get set }
  var sortingOrientation: SortingOrientationOption { get set }
}

protocol InMemoryPreferencesProvider {
  var preferredListType: ListTypeValue { get set }
  var preferredMapType: MKMapType { get set }
}

final class PreferencesDataService: StoredPreferencesProvider, InMemoryPreferencesProvider {
  
  private static let preferencesManagerBackgroundQueue = DispatchQueue(
    label: Constants.Labels.DispatchQueues.kPreferencesManagerBackgroundQueue,
    qos: .utility,
    attributes: [.concurrent],
    autoreleaseFrequency: .inherit,
    target: nil
  )
  
  // MARK: - Public Assets
  
  static var shared: PreferencesDataService!
  
  // MARK: - Properties
  
  private var locationAuthorizationObserver: NSObjectProtocol!
  
  // MARK: - Initialization
  
  private init(preferredBookmark: PreferredBookmarkOption, amountOfResults: AmountOfResultsOption, temperatureUnit: TemperatureUnitOption, windspeedUnit: DimensionalUnitsOption, sortingOrientation: SortingOrientationOption) {
    self.preferredBookmark = preferredBookmark
    self.amountOfResults = amountOfResults
    self.temperatureUnit = temperatureUnit
    self.distanceSpeedUnit = windspeedUnit
    self.sortingOrientation = sortingOrientation
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Public Properties & Methods
  
  static func instantiateSharedInstance() {
    shared = PreferencesDataService.loadData() ?? PreferencesDataService(preferredBookmark: PreferredBookmarkOption(value: .none),
                                                                         amountOfResults: AmountOfResultsOption(value: .ten),
                                                                         temperatureUnit: TemperatureUnitOption(value: .celsius),
                                                                         windspeedUnit: DimensionalUnitsOption(value: .metric),
                                                                         sortingOrientation: SortingOrientationOption(value: .name))
  }
  
  // MARK: - Stored Preferences
  
  var preferredBookmark: PreferredBookmarkOption {
    didSet {
      BadgeService.shared.updateBadge()
      PreferencesDataService.storeData()
    }
  }
  
  var amountOfResults: AmountOfResultsOption {
    didSet {
      WeatherInformationService.shared.update(withCompletionHandler: nil)
      PreferencesDataService.storeData()
    }
  }
  
  var temperatureUnit: TemperatureUnitOption {
    didSet {
      BadgeService.shared.updateBadge()
      PreferencesDataService.storeData()
    }
  }
  
  var distanceSpeedUnit: DimensionalUnitsOption {
    didSet {
      PreferencesDataService.storeData()
    }
  }
  
  var sortingOrientation: SortingOrientationOption {
    didSet {
      NotificationCenter.default.post(
        name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kSortingOrientationPreferenceChanged),
        object: nil
      )
      PreferencesDataService.storeData()
    }
  }
  
  // MARK: - In Memory Preferences
  
  var preferredListType: ListTypeValue = .bookmarked
  
  var preferredMapType: MKMapType = .standard
}

extension PreferencesDataService: JsonPersistencyProtocol {
  
  typealias StorageEntity = PreferencesDataService
  
  static func loadData() -> PreferencesDataService? {
    guard let preferencesManagerStoredContentsWrapper = try? JsonPersistencyWorker().retrieveJsonFromFile(
      with: Constants.Keys.Storage.kPreferencesManagerStoredContentsFileName,
      andDecodeAsType: PreferencesManagerStoredContentsWrapper.self,
      fromStorageLocation: .applicationSupport
      ) else {
        return nil
    }
    
    return PreferencesDataService(
      preferredBookmark: preferencesManagerStoredContentsWrapper.preferredBookmark,
      amountOfResults: preferencesManagerStoredContentsWrapper.amountOfResults,
      temperatureUnit: preferencesManagerStoredContentsWrapper.temperatureUnit,
      windspeedUnit: preferencesManagerStoredContentsWrapper.windspeedUnit,
      sortingOrientation: preferencesManagerStoredContentsWrapper.sortingOrientation
    )
  }
  
  static func storeData() {
    let dispatchSemaphore = DispatchSemaphore(value: 1)
    
    dispatchSemaphore.wait()
    preferencesManagerBackgroundQueue.async {
      let preferencesManagerStoredContentsWrapper = PreferencesManagerStoredContentsWrapper(
        preferredBookmark: PreferencesDataService.shared.preferredBookmark,
        amountOfResults: PreferencesDataService.shared.amountOfResults,
        temperatureUnit: PreferencesDataService.shared.temperatureUnit,
        windspeedUnit: PreferencesDataService.shared.distanceSpeedUnit,
        sortingOrientation: PreferencesDataService.shared.sortingOrientation
      )
      try? JsonPersistencyWorker().storeJson(
        for: preferencesManagerStoredContentsWrapper,
        inFileWithName: Constants.Keys.Storage.kPreferencesManagerStoredContentsFileName,
        toStorageLocation: .applicationSupport
      )
      dispatchSemaphore.signal()
    }
  }
}
