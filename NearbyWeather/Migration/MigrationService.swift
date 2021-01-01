//
//  MigrationService.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxOptional

extension MigrationService {
  struct Dependencies {
    let preferencesService: PreferencesService2
    let weatherInformationService: WeatherInformationService2
  }
}

final class MigrationService {
  
  // MARK: - Properties
  
  private let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: MigrationService.Dependencies) {
    self.dependencies = dependencies
  }
}

// MARK: - Functions

extension MigrationService {
  
  func runMigrationIfNeeded() {
    guard UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kMigratedToVersion230) == nil else {
      return
    }
    
    // migrate preferences
    let migratePreferencesCompletable = Observable<PreferencesManagerStoredContentsWrapper?>
      .create { handler in
        let preferencesStoredContentsWrapper = try? JsonPersistencyWorker().retrieveJsonFromFile(
          with: Constants.Keys.Storage.kPreferencesManagerStoredContentsFileName,
          andDecodeAsType: PreferencesManagerStoredContentsWrapper.self,
          fromStorageLocation: .applicationSupport
        )
        handler.on(.next(preferencesStoredContentsWrapper))
        return Disposables.create()
      }
      .take(1)
      .asSingle()
      .flatMapCompletable { [dependencies] preferencesStoredContentsWrapper -> Completable in
        guard let preferencesStoredContentsWrapper = preferencesStoredContentsWrapper else {
          // previous data does not exist or could not be read -> do not try to migrate anymore
          return Completable.create { handler in
            handler(.completed)
            return Disposables.create()
          }
        }
        return Completable.zip([
          dependencies.preferencesService.setPreferredBookmark(preferencesStoredContentsWrapper.preferredBookmark),
          dependencies.preferencesService.setAmountOfNearbyResultsOption(preferencesStoredContentsWrapper.amountOfResults),
          dependencies.preferencesService.setTemperatureUnitOption(preferencesStoredContentsWrapper.temperatureUnit),
          dependencies.preferencesService.setDimensionalUnitsOption(preferencesStoredContentsWrapper.windspeedUnit),
          dependencies.preferencesService.setSortingOrientationOption(preferencesStoredContentsWrapper.sortingOrientation)
        ])
      }
    
    // migrate weather information
    let migrateWeatherInformationCompletable = Observable<WeatherDataManagerStoredContentsWrapper?>
      .create { handler in
        let weatherInformationStoredContents = try? JsonPersistencyWorker().retrieveJsonFromFile(
          with: Constants.Keys.Storage.kWeatherDataManagerStoredContentsFileName,
          andDecodeAsType: WeatherDataManagerStoredContentsWrapper.self,
          fromStorageLocation: .documents
        )
        handler.on(.next(weatherInformationStoredContents))
        return Disposables.create()
      }
      .take(1)
      .asSingle()
      .flatMapCompletable { [dependencies] weatherInformationStoredContents -> Completable in
        guard let weatherInformationStoredContents = weatherInformationStoredContents else {
          // previous data does not exist or could not be read -> do not try to migrate anymore
          return Completable.create { handler in
            handler(.completed)
            return Disposables.create()
          }
        }
        return Completable.zip([
          dependencies.weatherInformationService.setBookmarkerWeatherInformationList(
            weatherInformationStoredContents.bookmarkedWeatherDataObjects?.compactMap { $0.weatherInformationDTO } ?? []
          ),
          dependencies.weatherInformationService.setNearbyWeatherInformationList(
            weatherInformationStoredContents.nearbyWeatherDataObject?.weatherInformationDTOs ?? []
          )
        ])
      }
    
    // execute migration
    _ = Completable
      .zip([
        migratePreferencesCompletable,
        migrateWeatherInformationCompletable
      ])
      .subscribe(onCompleted: { UserDefaults.standard.set(true, forKey: Constants.Keys.UserDefaults.kMigratedToVersion230) })
  }
}
