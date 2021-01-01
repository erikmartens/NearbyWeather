//
//  PreferencesService2.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 02.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxOptional

final class PreferencesService2 {
  
  // MARK: - Assets
  
  private lazy var persistencyWorker: RealmPersistencyWorker = {
    try! RealmPersistencyWorker(
      storageLocation: .documents,
      dataBaseFileName: "PreferencesServiceDataBase"
    )
  }()
  
  private static let amountOfNearbyResultsOptionCollection = "/general_preferences/amount_of_results/"
  private static let amountOfNearbyResultsOptionIdentifier = "default"
  private static let temperatureUnitOptionCollection = "/general_preferences/temperature_unit/"
  private static let temperatureUnitOptionIdentifier = "default"
  private static let dimensionalUnitOptionCollection = "/general_preferences/dimensional_unit/"
  private static let dimensionalUnitOptionIdentifier = "default"
  private static let sortingOrientationOptionCollection = "/general_preferences/sorting_orientation/"
  private static let sortingOrientationOptionIdentifier = "default"
  private static let preferredListTypeOptionCollection = "/general_preferences/preferred_list_type/"
  private static let preferredListTypeOptionIdentifier = "default"
  private static let preferredMapTypeOptionCollection = "/general_preferences/preferred_map_type/"
  private static let preferredMapTypeOptionIdentifier = "default"
  
  private static let weatherStationBookmarksCollection = "/weather_station/bookmarks/"
  private static let weatherStationBookmarksSortingCollection = "/weather_station/bookmarks_sorting/"
  private static let weatherStationBookmarksSortingIdentifier = "default"
  private static let weatherStationPreferredBookmarkCollection = "/weather_station/preferred_bookmark/"
  private static let weatherStationPreferredBookmarkIdentifier = "default"
  
  // MARK: - Properties
  
  // MARK: - Initialization
}

// MARK: - General Preference Setting

protocol GeneralPreferenceSetting {
  func setAmountOfNearbyResultsOption(_ option: AmountOfResultsOption) -> Completable
  func getAmountOfNearbyResultsOption() -> Observable<AmountOfResultsOption>
  
  func setTemperatureUnitOption(_ option: TemperatureUnitOption) -> Completable
  func getTemperatureUnitOption() -> Observable<TemperatureUnitOption>
  
  func setDimensionalUnitsOption(_ option: DimensionalUnitsOption) -> Completable
  func getDimensionalUnitsOption() -> Observable<DimensionalUnitsOption>
  
  func setSortingOrientationOption(_ option: SortingOrientationOption) -> Completable
  func getSortingOrientationOption() -> Observable<SortingOrientationOption>

  func setPreferredListTypeOption(_ option: ListTypeOption) -> Completable
  func createPreferredListTypeOptionObservable() -> Observable<ListTypeOption>
  
  func setPreferredMapTypeOption(_ option: MapTypeOption) -> Completable
  func getPreferredMapTypeOption() -> Observable<MapTypeOption>
}

extension PreferencesService2: GeneralPreferenceSetting {
  
  func setAmountOfNearbyResultsOption(_ option: AmountOfResultsOption) -> Completable {
    Single
      .just(option)
      .map {
        PersistencyModel<AmountOfResultsOption>(identity: PersistencyModelIdentity(collection: Self.amountOfNearbyResultsOptionCollection,
                                                                                   identifier: Self.amountOfNearbyResultsOptionIdentifier),
                                                entity: $0)
      }
      .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResource($0, type: AmountOfResultsOption.self) }
  }
  
  func getAmountOfNearbyResultsOption() -> Observable<AmountOfResultsOption> {
    persistencyWorker
      .observeResource(with: PersistencyModelIdentity(collection: Self.amountOfNearbyResultsOptionCollection,
                                                      identifier: Self.amountOfNearbyResultsOptionIdentifier),
                       type: AmountOfResultsOption.self)
      .map { $0?.entity }
      .replaceNilWith(AmountOfResultsOption(value: .ten)) // default value
  }
  
  func setTemperatureUnitOption(_ option: TemperatureUnitOption) -> Completable {
    Single
      .just(option)
      .map {
        PersistencyModel<TemperatureUnitOption>(identity: PersistencyModelIdentity(collection: Self.temperatureUnitOptionCollection,
                                                                                   identifier: Self.temperatureUnitOptionIdentifier),
                                                entity: $0)
    }
    .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResource($0, type: TemperatureUnitOption.self) }
  }
  
  func getTemperatureUnitOption() -> Observable<TemperatureUnitOption> {
    persistencyWorker
      .observeResource(with: PersistencyModelIdentity(collection: Self.temperatureUnitOptionCollection,
                                                      identifier: Self.temperatureUnitOptionIdentifier),
                       type: TemperatureUnitOption.self)
      .map { $0?.entity }
      .replaceNilWith(TemperatureUnitOption(value: .celsius)) // default value
  }
  
  func setDimensionalUnitsOption(_ option: DimensionalUnitsOption) -> Completable {
    Single
      .just(option)
      .map {
        PersistencyModel<DimensionalUnitsOption>(identity: PersistencyModelIdentity(collection: Self.dimensionalUnitOptionCollection,
                                                                                    identifier: Self.dimensionalUnitOptionIdentifier),
                                                 entity: $0)
      }
      .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResource($0, type: DimensionalUnitsOption.self) }
  }
  
  func getDimensionalUnitsOption() -> Observable<DimensionalUnitsOption> {
    persistencyWorker
      .observeResource(with: PersistencyModelIdentity(collection: Self.dimensionalUnitOptionCollection,
                                                      identifier: Self.dimensionalUnitOptionIdentifier),
                       type: DimensionalUnitsOption.self)
      .map { $0?.entity }
      .replaceNilWith(DimensionalUnitsOption(value: .metric)) // default value
  }
  
  func setSortingOrientationOption(_ option: SortingOrientationOption) -> Completable {
    Single
      .just(option)
      .map {
        PersistencyModel<SortingOrientationOption>(identity: PersistencyModelIdentity(collection: Self.sortingOrientationOptionCollection,
                                                                                      identifier: Self.sortingOrientationOptionIdentifier),
                                                   entity: $0)
      }
      .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResource($0, type: SortingOrientationOption.self) }
  }
  
  func getSortingOrientationOption() -> Observable<SortingOrientationOption> {
    persistencyWorker
      .observeResource(with: PersistencyModelIdentity(collection: Self.sortingOrientationOptionCollection,
                                                      identifier: Self.sortingOrientationOptionIdentifier),
                       type: SortingOrientationOption.self)
      .map { $0?.entity }
      .replaceNilWith(SortingOrientationOption(value: .name)) // default value
  }
  
  func setPreferredListTypeOption(_ option: ListTypeOption) -> Completable {
    Single
      .just(option)
      .map {
        PersistencyModel<ListTypeOption>(identity: PersistencyModelIdentity(collection: Self.preferredListTypeOptionCollection,
                                                                            identifier: Self.preferredListTypeOptionIdentifier),
                                         entity: $0)
      }
      .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResource($0, type: ListTypeOption.self) }
  }
  
  func createPreferredListTypeOptionObservable() -> Observable<ListTypeOption> {
    persistencyWorker
      .observeResource(with: PersistencyModelIdentity(collection: Self.preferredListTypeOptionCollection,
                                                      identifier: Self.preferredListTypeOptionIdentifier),
                       type: ListTypeOption.self)
      .map { $0?.entity }
      .replaceNilWith(ListTypeOption(value: .nearby)) // default value
  }
  
  func setPreferredMapTypeOption(_ option: MapTypeOption) -> Completable {
    Single
      .just(option)
      .map {
        PersistencyModel<MapTypeOption>(identity: PersistencyModelIdentity(collection: Self.preferredMapTypeOptionCollection,
                                                                           identifier: Self.preferredMapTypeOptionIdentifier),
                                        entity: $0)
      }
      .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResource($0, type: MapTypeOption.self) }
  }
  
  func getPreferredMapTypeOption() -> Observable<MapTypeOption> {
    persistencyWorker
      .observeResource(with: PersistencyModelIdentity(collection: Self.preferredMapTypeOptionCollection,
                                                      identifier: Self.preferredMapTypeOptionCollection),
                       type: MapTypeOption.self)
      .map { $0?.entity }
      .replaceNilWith(MapTypeOption(value: .standard)) // default value
  }
}

// MARK: - Weather Station Bookmarking

protocol WeatherStationBookmarkSetting {
  func addBookmark(_ weatherStationDto: WeatherStationDTO) -> Completable
  func removeBookmark(_ weatherStationDto: WeatherStationDTO) -> Completable
  func createBookmarkedStationsObservable() -> Observable<[WeatherStationDTO]>
  
  func setBookmarksSorting(_ sorting: [String: Int]) -> Completable
  func getBookmarksSorting() -> Observable<[String: Int]?>
  
  func setPreferredBookmark(_ weatherStationDto: PreferredBookmarkOption) -> Completable
  func clearPreferredBookmark() -> Completable
  func createPreferredBookmarkObservable() -> Observable<PreferredBookmarkOption?>
}

extension PreferencesService2: WeatherStationBookmarkSetting {
  
  func addBookmark(_ weatherStationDto: WeatherStationDTO) -> Completable {
    Single
      .just(weatherStationDto)
      .map {
        PersistencyModel<WeatherStationDTO>(identity: PersistencyModelIdentity(collection: Self.weatherStationBookmarksCollection,
                                                                               identifier: String($0.identifier)),
                                            entity: $0)
    }
    .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResource($0, type: WeatherStationDTO.self) }
  }
  
  func removeBookmark(_ weatherStationDto: WeatherStationDTO) -> Completable {
    Single
      .just(weatherStationDto.identifier)
      .map { PersistencyModelIdentity(collection: Self.weatherStationBookmarksCollection, identifier: String($0)) }
      .flatMapCompletable { [persistencyWorker] in persistencyWorker.deleteResource(with: $0) }
  }
  
  func setBookmarksSorting(_ sorting: [String: Int]) -> Completable {
    Single
      .just(sorting)
      .map {
        PersistencyModel(identity: PersistencyModelIdentity(collection: Self.weatherStationBookmarksSortingCollection,
                                                            identifier: Self.weatherStationBookmarksSortingIdentifier),
                         entity: $0)
    }
    .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResource($0, type: [String: Int].self) }
  }
  
  func getBookmarksSorting() -> Observable<[String: Int]?> {
    persistencyWorker
      .observeResource(with: PersistencyModelIdentity(collection: Self.weatherStationBookmarksSortingCollection,
                                                      identifier: Self.weatherStationBookmarksSortingIdentifier),
                       type: [String: Int].self)
      .map { $0?.entity }
  }
  
  func createBookmarkedStationsObservable() -> Observable<[WeatherStationDTO]> {
    persistencyWorker
      .observeResources(in: Self.weatherStationBookmarksCollection, type: WeatherStationDTO.self)
      .map { $0.map { $0.entity } }
  }
  
  func setPreferredBookmark(_ weatherStationDto: PreferredBookmarkOption) -> Completable {
    Single
      .just(weatherStationDto)
      .map {
        PersistencyModel(identity: PersistencyModelIdentity(collection: Self.weatherStationPreferredBookmarkCollection,
                                                            identifier: Self.weatherStationPreferredBookmarkIdentifier),
                         entity: $0)
      }
      .flatMapCompletable { [persistencyWorker] in persistencyWorker.saveResource($0, type: PreferredBookmarkOption.self) }
  }
  
  func clearPreferredBookmark() -> Completable {
    persistencyWorker
      .deleteResource(with: PersistencyModelIdentity(collection: Self.weatherStationPreferredBookmarkCollection,
                                                     identifier: Self.weatherStationPreferredBookmarkIdentifier))
  }
  
  func createPreferredBookmarkObservable() -> Observable<PreferredBookmarkOption?> {
    persistencyWorker
      .observeResources(in: Self.weatherStationPreferredBookmarkCollection, type: PreferredBookmarkOption.self)
      .map { $0.first }
      .errorOnNil()
      .map { $0.entity }
      .catchErrorJustReturn(nil)
  }
}
