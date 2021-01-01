//
//  ListWeatherInformationTableCellViewModel.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxSwift
import RxCocoa

extension WeatherListInformationTableViewCellViewModel {
  
  struct Dependencies {
    let weatherInformationIdentity: PersistencyModelIdentity
    let weatherInformationService: WeatherInformationService2
    let userPreferencesService: PreferencesService2
  }
}

final class WeatherListInformationTableViewCellViewModel: NSObject, BaseCellViewModel {
  
  // MARK: - Properties
  
  private let dependencies: Dependencies

  // MARK: - Events
  
  let cellModelDriver: Driver<WeatherListInformationTableViewCellModel>

  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    
    self.cellModelDriver = Self.createDataSourceObserver(with: dependencies)
  }
}

// MARK: - Observations

private extension WeatherListInformationTableViewCellViewModel {
  
  static func createDataSourceObserver(with dependencies: Dependencies) -> Driver<WeatherListInformationTableViewCellModel> {
    dependencies.userPreferencesService
      .createPreferredListTypeOptionObservable()
      .flatMapLatest { [dependencies] listTypeOption -> Observable<PersistencyModel<WeatherInformationDTO>?> in
        switch listTypeOption.value {
        case .bookmarked:
          return dependencies.weatherInformationService
            .createBookmarkedWeatherInformationObservable(for: dependencies.weatherInformationIdentity.identifier)
        case .nearby:
          return dependencies.weatherInformationService
            .createNearbyWeatherInformationObservable(for: dependencies.weatherInformationIdentity.identifier)
        }
      }
      .map { $0?.entity }
      .errorOnNil()
      .map { weatherInformation -> WeatherListInformationTableViewCellModel in
        WeatherListInformationTableViewCellModel(
          weatherConditionSymbol: ConversionWorker.weatherConditionSymbol(
            fromWeatherCode: weatherInformation.weatherCondition.first?.identifier,
            isDayTime: ConversionWorker.isDayTime(for: weatherInformation.daytimeInformation, coordinates: weatherInformation.coordinates)
          ),
          temperature: ConversionWorker.temperatureDescriptor(
            forTemperatureUnit: PreferencesDataService.shared.temperatureUnit, // TODO observe user preference service 2
            fromRawTemperature: weatherInformation.atmosphericInformation.temperatureKelvin
          ),
          cloudCoverage: weatherInformation.cloudCoverage.coverage?.append(contentsOf: "%", delimiter: .none),
          humidity: weatherInformation.atmosphericInformation.humidity?.append(contentsOf: "%", delimiter: .none),
          windspeed: ConversionWorker.windspeedDescriptor(
            forDistanceSpeedUnit: PreferencesDataService.shared.distanceSpeedUnit, // TODO
            forWindspeed: weatherInformation.windInformation.windspeed
          ),
          backgroundColor: .clear // TODO
          // TODO border
        )
      }
      .asDriver(onErrorJustReturn: WeatherListInformationTableViewCellModel())
  }
}
