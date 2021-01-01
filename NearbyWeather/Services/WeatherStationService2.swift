//
//  WeatherStationService2.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 30.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import FMDB
import RxSwift
import RxOptional

extension WeatherStationService2 {
  struct Dependencies {
    let preferencesService: PreferencesService2
  }
}

final class WeatherStationService2 {
  
  // MARK: - Assets
  
  private lazy var persistencyWorker: RealmPersistencyWorker = {
    try! RealmPersistencyWorker(
      storageLocation: .documents,
      dataBaseFileName: "WeatherStationServiceDataBase"
    )
  }()
  
  private lazy var lookupWorker: FMDatabaseQueue = {
    FMDatabaseQueue(
      path: R.file.locationsSQLiteSqlite()!.path
    )!
  }()
  
  private static func lookupQuery(for searchTerm: String) -> String {
    "SELECT * FROM locations l WHERE (lower(name) LIKE '%\(searchTerm.lowercased())%') ORDER BY l.name, l.country"
  }
  
  private static let weatherStationBookmarkCollection = "/weather_station/bookmarked/"
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: WeatherStationService2.Dependencies) {
    self.dependencies = dependencies
  }
}

// MARK: - Weather Station Lookup

protocol WeatherStationLookup {
  func createWeatherStationsLookupObservable(for searchTerm: String) -> Observable<[WeatherStationDTO]>
}

extension WeatherStationService2: WeatherStationLookup {
  
  func createWeatherStationsLookupObservable(for searchTerm: String) -> Observable<[WeatherStationDTO]> {
    Observable<[WeatherStationDTO]?>
      .create { [lookupWorker] subscriber in
        lookupWorker.inDatabase { database in
          guard let result = try? database.executeQuery(Self.lookupQuery(for: searchTerm), values: nil) else {
            subscriber.on(.next(nil))
            return
          }
          var retrievedStations = [WeatherStationDTO]()
          while result.next() {
            if let station = WeatherStationDTO(from: result) {
              retrievedStations.append(station)
            }
          }
          subscriber.on(.next(retrievedStations))
        }
        return Disposables.create()
      }
      .replaceNilWith([])
      .flatMapLatest { [dependencies] weatherStationDtos -> Observable<[WeatherStationDTO]> in
        dependencies.preferencesService
          .createBookmarkedStationsObservable()
          .map { bookmarkedWeatherStations in
            weatherStationDtos.filter { !bookmarkedWeatherStations.contains($0) }
          }
      }
      .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
  }
}
