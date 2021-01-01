//
//  Weather.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import MapKit
import Alamofire

enum UpdateStatus {
  case success
  case failure
}

final class WeatherInformationService {
  
  private lazy var fetchWeatherDataBackgroundQueue: DispatchQueue = {
    DispatchQueue(label: Constants.Labels.DispatchQueues.kFetchWeatherDataBackgroundQueue,
                  qos: .userInitiated,
                  autoreleaseFrequency: .inherit,
                  target: nil)
  }()
  
  private static let weatherServiceBackgroundQueue = DispatchQueue(
    label: Constants.Labels.DispatchQueues.kWeatherServiceBackgroundQueue,
    qos: .utility,
    attributes: [.concurrent],
    autoreleaseFrequency: .inherit,
    target: nil
  )
  
  // MARK: - Public Assets
  
  static var shared: WeatherInformationService!
  
  var hasDisplayableData: Bool {
    
    return bookmarkedWeatherDataObjects?.first { $0.errorDataDTO != nil } != nil
      || bookmarkedWeatherDataObjects?.first { $0.weatherInformationDTO != nil } != nil
      || nearbyWeatherDataObject?.errorDataDTO != nil
      || nearbyWeatherDataObject?.weatherInformationDTOs != nil
  }
  
  var hasDisplayableWeatherData: Bool {
    return bookmarkedWeatherDataObjects?.first { $0.weatherInformationDTO != nil } != nil
      || nearbyWeatherDataObject?.weatherInformationDTOs != nil
  }
  
  var apiKeyUnauthorized: Bool {
    return ((bookmarkedWeatherDataObjects?.first { $0.errorDataDTO?.httpStatusCode == 401 }) != nil)
      || nearbyWeatherDataObject?.errorDataDTO?.httpStatusCode == 401
  }
  
  // MARK: - Properties
  
  var bookmarkedLocations: [WeatherStationDTO] {
    didSet {
      update(withCompletionHandler: nil)
      sortBookmarkedLocationWeatherData()
      WeatherInformationService.storeData()
    }
  }
  var preferredBookmarkData: WeatherInformationDTO? {
    let preferredBookmarkId = PreferencesDataService.shared.preferredBookmark.value
    return WeatherInformationService.shared.bookmarkedWeatherDataObjects?.first(where: { $0.locationId == preferredBookmarkId })?.weatherInformationDTO
  }
  private(set) var bookmarkedWeatherDataObjects: [WeatherDataContainer]?
  private(set) var nearbyWeatherDataObject: BulkWeatherDataContainer?
  
  private var locationAuthorizationObserver: NSObjectProtocol!
  private var sortingOrientationChangedObserver: NSObjectProtocol!
  
  // MARK: - Initialization
  
  private init(bookmarkedLocations: [WeatherStationDTO]) {
    self.bookmarkedLocations = bookmarkedLocations
    
    locationAuthorizationObserver = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil, using: { [unowned self] _ in
      self.discardLocationBasedWeatherDataIfNeeded()
    })
    sortingOrientationChangedObserver = NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kSortingOrientationPreferenceChanged), object: nil, queue: nil, using: { [unowned self] _ in
      self.sortNearbyLocationWeatherData()
    })
  }
  
  deinit {
    if let locationAuthorizationObserver = locationAuthorizationObserver {
      NotificationCenter.default.removeObserver(locationAuthorizationObserver, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    if let sortingOrientationChangedObserver = sortingOrientationChangedObserver {
      NotificationCenter.default.removeObserver(sortingOrientationChangedObserver, name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kSortingOrientationPreferenceChanged), object: nil)
    }
  }
  
  // MARK: - Public Properties & Methods
  
  static func instantiateSharedInstance() {
    shared = WeatherInformationService.loadData() ?? WeatherInformationService(bookmarkedLocations: [Constants.Mocks.WeatherStationDTOs.kDefaultBookmarkedLocation])
  }
  
  func update(withCompletionHandler completionHandler: ((UpdateStatus) -> Void)?) {
    guard WeatherNetworkingService.shared.reachabilityStatus == .connected else {
      completionHandler?(.failure)
      return
    }
    
    fetchWeatherDataBackgroundQueue.async {
      let dispatchGroup = DispatchGroup()
      
      var bookmarkedWeatherDataObjects = [WeatherDataContainer]()
      var nearbyWeatherDataObject: BulkWeatherDataContainer?
      
      if self.bookmarkedLocations.isEmpty {
        self.bookmarkedWeatherDataObjects = []
      } else {
        self.bookmarkedLocations.forEach { location in
          dispatchGroup.enter()
          WeatherNetworkingService.shared.fetchWeatherInformationForStation(withIdentifier: location.identifier, completionHandler: { weatherDataContainer in
            bookmarkedWeatherDataObjects.append(weatherDataContainer)
            dispatchGroup.leave()
          })
        }
      }
      
      dispatchGroup.enter()
      WeatherNetworkingService.shared.fetchBulkWeatherInformation(completionHandler: { weatherData in
        nearbyWeatherDataObject = weatherData
        dispatchGroup.leave()
      })
      
      let waitResult = dispatchGroup.wait(timeout: .now() + 60.0)
      if waitResult == .timedOut {
        completionHandler?(.failure) // todo: notify user
        return
      }
      
      // do not publish refresh if not data was loaded
      if bookmarkedWeatherDataObjects.isEmpty && nearbyWeatherDataObject == nil {
        return
      }
      
      // only override previous record if there is any new data
      if !bookmarkedWeatherDataObjects.isEmpty {
        self.bookmarkedWeatherDataObjects = bookmarkedWeatherDataObjects
        self.sortBookmarkedLocationWeatherData()
      }
      if nearbyWeatherDataObject != nil {
        self.nearbyWeatherDataObject = nearbyWeatherDataObject
        self.sortNearbyLocationWeatherData()
      }
      
      WeatherInformationService.storeData()
      DispatchQueue.main.async {
        UserDefaults.standard.set(Date(), forKey: Constants.Keys.UserDefaults.kWeatherDataLastRefreshDateKey)
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kWeatherServiceDidUpdate), object: self)
        BadgeService.shared.updateBadge()
        completionHandler?(.success)
      }
    }
  }
  
  func updatePreferredBookmark(withCompletionHandler completionHandler: @escaping ((UpdateStatus) -> Void)) {
    guard let preferredBookmarkId = PreferencesDataService.shared.preferredBookmark.value,
      WeatherNetworkingService.shared.reachabilityStatus == .connected else {
        completionHandler(.failure)
        return
    }
    
    fetchWeatherDataBackgroundQueue.async {
      let dispatchGroup = DispatchGroup()
      
      var preferredBookmarkWeatherData: WeatherDataContainer?
      dispatchGroup.enter()
      WeatherNetworkingService.shared.fetchWeatherInformationForStation(withIdentifier: preferredBookmarkId, completionHandler: { weatherDataContainer in
        preferredBookmarkWeatherData = weatherDataContainer
        dispatchGroup.leave()
      })
      
      let waitResult = dispatchGroup.wait(timeout: .now() + 60.0)
      if waitResult == .timedOut {
        completionHandler(.failure)
        return
      }
      
      guard let unwrappedPreferredBookmarkWeatherData = preferredBookmarkWeatherData else {
        completionHandler(.failure)
        return
      }
      
      if let bookmarkIndex = self.bookmarkedWeatherDataObjects?.firstIndex(where: { $0.locationId == unwrappedPreferredBookmarkWeatherData.locationId }) {
        self.bookmarkedWeatherDataObjects?[bookmarkIndex] = unwrappedPreferredBookmarkWeatherData
      } else {
        self.bookmarkedWeatherDataObjects?.append(unwrappedPreferredBookmarkWeatherData)
      }
      self.sortBookmarkedLocationWeatherData()
      
      WeatherInformationService.storeData()
      DispatchQueue.main.async {
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kWeatherServiceDidUpdate), object: nil)
        BadgeService.shared.updateBadge()
        completionHandler(.success)
      }
    }
  }
  
  func weatherDTO(forIdentifier identifier: Int) -> WeatherInformationDTO? {
    if let bookmarkedLocationMatch = bookmarkedWeatherDataObjects?.first(where: {
      return $0.weatherInformationDTO?.cityID == identifier
    }), let weatherDTO = bookmarkedLocationMatch.weatherInformationDTO {
      return weatherDTO
    }
    
    if let nearbyLocationMatch = nearbyWeatherDataObject?.weatherInformationDTOs?.first(where: { weatherDTO in
      return weatherDTO.cityID == identifier
    }) {
      return nearbyLocationMatch
    }
    return nil
  }
  
  // MARK: - Private Helper Methods
  
  private func sortBookmarkedLocationWeatherData() {
    let result: [WeatherDataContainer]?
    result = bookmarkedWeatherDataObjects?.sorted { weatherDataObject0, weatherDataObject1 in
      guard let correspondingLocation0 = bookmarkedLocations.first(where: { return weatherDataObject0.locationId == $0.identifier }),
        let correspondingLocation1 = bookmarkedLocations.first(where: { return weatherDataObject1.locationId == $0.identifier }),
        let index0 = bookmarkedLocations.firstIndex(of: correspondingLocation0),
        let index1 = bookmarkedLocations.firstIndex(of: correspondingLocation1) else {
          return false
      }
      return index0 < index1
    }
    guard let sortedResult = result else { return }
    bookmarkedWeatherDataObjects = sortedResult
  }
  
  private func sortNearbyLocationWeatherData() {
    let result: [WeatherInformationDTO]?
    switch PreferencesDataService.shared.sortingOrientation.value {
    case .name:
      result = nearbyWeatherDataObject?.weatherInformationDTOs?.sorted { $0.cityName < $1.cityName }
    case .temperature:
      result = nearbyWeatherDataObject?.weatherInformationDTOs?.sorted {
        guard let lhsTemperature = $0.atmosphericInformation.temperatureKelvin else {
          return false
        }
        guard let rhsTemperature = $1.atmosphericInformation.temperatureKelvin else {
          return true
        }
        return lhsTemperature > rhsTemperature
      }
    case .distance:
      guard UserLocationService.shared.locationPermissionsGranted,
        let currentLocation = UserLocationService.shared.currentLocation else {
          return
      }
      result = nearbyWeatherDataObject?.weatherInformationDTOs?.sorted {
        guard let lhsLatitude = $0.coordinates.latitude, let lhsLongitude = $0.coordinates.longitude else {
          return false
        }
        guard let rhsLatitude = $1.coordinates.latitude, let rhsLongitude = $1.coordinates.longitude else {
          return true
        }
        let lhsLocation = CLLocation(latitude: lhsLatitude, longitude: lhsLongitude)
        let rhsLocation = CLLocation(latitude: rhsLatitude, longitude: rhsLongitude)
        return lhsLocation.distance(from: currentLocation) < rhsLocation.distance(from: currentLocation)
      }
    }
    guard let sortedResult = result else { return }
    self.nearbyWeatherDataObject?.weatherInformationDTOs = sortedResult
  }
  
  /* NotificationCenter Notifications */
  
  @objc private func discardLocationBasedWeatherDataIfNeeded() {
    if !UserLocationService.shared.locationPermissionsGranted {
      nearbyWeatherDataObject = nil
      WeatherInformationService.storeData()
      NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kWeatherServiceDidUpdate), object: nil)
    }
  }
}

extension WeatherInformationService: JsonPersistencyProtocol {
  
  typealias StorageEntity = WeatherInformationService
  
  static func loadData() -> WeatherInformationService? {
    guard let weatherDataManagerStoredContents = try? JsonPersistencyWorker().retrieveJsonFromFile(
      with: Constants.Keys.Storage.kWeatherDataManagerStoredContentsFileName,
      andDecodeAsType: WeatherDataManagerStoredContentsWrapper.self,
      fromStorageLocation: .documents
      ) else {
        return nil
    }
    
    let weatherService = WeatherInformationService(bookmarkedLocations: weatherDataManagerStoredContents.bookmarkedLocations)
    weatherService.bookmarkedWeatherDataObjects = weatherDataManagerStoredContents.bookmarkedWeatherDataObjects
    weatherService.nearbyWeatherDataObject = weatherDataManagerStoredContents.nearbyWeatherDataObject
    
    return weatherService
  }
  
  static func storeData() {
    let dispatchSemaphore = DispatchSemaphore(value: 1)
    
    dispatchSemaphore.wait()
    weatherServiceBackgroundQueue.async {
      let weatherDataManagerStoredContents = WeatherDataManagerStoredContentsWrapper(
        bookmarkedLocations: WeatherInformationService.shared.bookmarkedLocations,
        bookmarkedWeatherDataObjects: WeatherInformationService.shared.bookmarkedWeatherDataObjects,
        nearbyWeatherDataObject: WeatherInformationService.shared.nearbyWeatherDataObject
      )
      try? JsonPersistencyWorker().storeJson(
        for: weatherDataManagerStoredContents,
        inFileWithName: Constants.Keys.Storage.kWeatherDataManagerStoredContentsFileName,
        toStorageLocation: .documents
      )
      dispatchSemaphore.signal()
    }
  }
}
