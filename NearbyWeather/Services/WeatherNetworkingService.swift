//
//  NetworkingService.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 10.02.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import Foundation
import Alamofire

enum NetworkingReachabilityStatus {
  case unknown
  case disconnected
  case connected
}

final class WeatherNetworkingService {

  private lazy var weatherFetchQueue: DispatchQueue = {
    DispatchQueue(label: Constants.Labels.DispatchQueues.kWeatherFetchQueue, qos: .userInitiated, attributes: [.concurrent])
  }()

  // MARK: - Public Assets

  static var shared: WeatherNetworkingService!

  // MARK: - Properties

  private let reachabilityManager: NetworkReachabilityManager?
  private(set) var reachabilityStatus: NetworkingReachabilityStatus

  private var apiKey: String? {
    UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey) as? String
  }

  // MARK: - Initialization

  private init() {
    reachabilityManager = NetworkReachabilityManager()
    reachabilityStatus = .unknown

    beginListeningNetworkReachability()
  }

  deinit {
    reachabilityManager?.stopListening()
  }

  // MARK: - Private Methods

  func beginListeningNetworkReachability() {
    reachabilityManager?.listener = { [weak self] status in
      switch status {
      case .unknown: self?.reachabilityStatus = .unknown
      case .notReachable: self?.reachabilityStatus = .disconnected
      case .reachable(.ethernetOrWiFi), .reachable(.wwan): self?.reachabilityStatus = .connected
      }
      NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kNetworkReachabilityChanged),
                                      object: nil)
    }
    reachabilityManager?.startListening()
  }

  // MARK: - Public Methods

  static func instantiateSharedInstance() {
    shared = WeatherNetworkingService()
  }

  func fetchWeatherInformationForStation(withIdentifier identifier: Int, completionHandler: @escaping ((WeatherDataContainer) -> Void)) {

    guard let apiKey = self.apiKey else {
      let errorDataDTO = WeatherInformationErrorDTO(errorType: WeatherInformationErrorDTO.ErrorType(value: .malformedUrlError), httpStatusCode: nil)
      return completionHandler(WeatherDataContainer(locationId: identifier, errorDataDTO: errorDataDTO, weatherInformationDTO: nil))
    }

    Alamofire
      .request(
        Constants.Urls.kOpenWeatherMapSingleStationtDataRequestUrl(with: apiKey, stationIdentifier: identifier),
        method: .get,
        parameters: nil,
        encoding: JSONEncoding.default,
        headers: nil
    )
      .responseData(queue: weatherFetchQueue) { [weak self] response in
        guard let self = self,
          let data = response.result.value,
          response.result.error == nil else {
            let errorType = (response.response?.statusCode == 401) ? WeatherInformationErrorDTO.ErrorType(value: .unrecognizedApiKeyError) : WeatherInformationErrorDTO.ErrorType(value: .httpError)
            let errorDataDTO = WeatherInformationErrorDTO(errorType: errorType, httpStatusCode: response.response?.statusCode)
            return completionHandler(WeatherDataContainer(locationId: identifier, errorDataDTO: errorDataDTO, weatherInformationDTO: nil))
        }
        completionHandler(self.extractWeatherInformation(data, identifier: identifier))
    }
  }

  func fetchBulkWeatherInformation(completionHandler: @escaping (BulkWeatherDataContainer) -> Void) {
    guard let currentLatitude = UserLocationService.shared.currentLatitude, let currentLongitude = UserLocationService.shared.currentLongitude else {
      let errorDataDTO = WeatherInformationErrorDTO(errorType: WeatherInformationErrorDTO.ErrorType(value: .locationUnavailableError), httpStatusCode: nil)
      return completionHandler(BulkWeatherDataContainer(errorDataDTO: errorDataDTO, weatherInformationDTOs: nil))
    }

    guard let apiKey = self.apiKey else {
      let errorDataDTO = WeatherInformationErrorDTO(errorType: WeatherInformationErrorDTO.ErrorType(value: .malformedUrlError), httpStatusCode: nil)
      return completionHandler(BulkWeatherDataContainer(errorDataDTO: errorDataDTO, weatherInformationDTOs: nil))
    }

    Alamofire
      .request(
        Constants.Urls.kOpenWeatherMapMultiStationtDataRequestUrl(with: apiKey, currentLatitude: currentLatitude, currentLongitude: currentLongitude),
        method: .get,
        parameters: nil,
        encoding: JSONEncoding.default,
        headers: nil
    )
      .responseData(queue: weatherFetchQueue) { [weak self] response in
        guard let self = self,
          let data = response.result.value,
          response.result.error == nil else {
            let errorType = (response.response?.statusCode == 401) ? WeatherInformationErrorDTO.ErrorType(value: .unrecognizedApiKeyError) : WeatherInformationErrorDTO.ErrorType(value: .httpError)
            let errorDataDTO = WeatherInformationErrorDTO(errorType: errorType, httpStatusCode: response.response?.statusCode)
            return completionHandler(BulkWeatherDataContainer(errorDataDTO: errorDataDTO, weatherInformationDTOs: nil))
        }
        completionHandler(self.extractBulkWeatherInformation(data))
    }
  }

  // MARK: - Private Helpers

  private func extractWeatherInformation(_ data: Data, identifier: Int) -> WeatherDataContainer {
    guard let weatherInformationDTO = try? JSONDecoder().decode(WeatherInformationDTO.self, from: data) else {
      printDebugMessage(
        domain: String(describing: self),
        message: "NetworkingService: Error while decoding single-location-data to json",
        type: .error
      )
      let errorDataDTO = WeatherInformationErrorDTO(errorType: WeatherInformationErrorDTO.ErrorType(value: .jsonSerializationError), httpStatusCode: nil)
      return WeatherDataContainer(locationId: identifier, errorDataDTO: errorDataDTO, weatherInformationDTO: nil)
    }
    return WeatherDataContainer(locationId: identifier, errorDataDTO: nil, weatherInformationDTO: weatherInformationDTO)
  }

  private func extractBulkWeatherInformation(_ data: Data) -> BulkWeatherDataContainer {
    guard let multiWeatherData = try? JSONDecoder().decode(WeatherInformationArrayWrapper.self, from: data) else {
      printDebugMessage(
        domain: String(describing: self),
        message: "NetworkingService: Error while decoding multi-location-data to json",
        type: .error
      )
      let errorDataDTO = WeatherInformationErrorDTO(errorType: WeatherInformationErrorDTO.ErrorType(value: .jsonSerializationError), httpStatusCode: nil)
      return BulkWeatherDataContainer(errorDataDTO: errorDataDTO, weatherInformationDTOs: nil)
    }
    return BulkWeatherDataContainer(errorDataDTO: nil, weatherInformationDTOs: multiWeatherData.list)
  }
}
