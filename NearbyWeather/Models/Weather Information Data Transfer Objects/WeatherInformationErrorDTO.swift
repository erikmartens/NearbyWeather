//
//  ErrorDataDTO.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 12.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

struct WeatherInformationErrorDTO: Codable {
  var errorType: ErrorType
  var httpStatusCode: Int?
  
  struct ErrorType: Codable {
    
    lazy var count = ErrorTypeWrappedEnum.allCases.count
    
    var value: ErrorTypeWrappedEnum
    
    init(value: ErrorTypeWrappedEnum) {
      self.value = value
    }
    
    init?(rawValue: Int) {
      guard let value = ErrorTypeWrappedEnum(rawValue: rawValue) else {
        return nil
      }
      self.init(value: value)
    }
    
    enum ErrorTypeWrappedEnum: Int, CaseIterable, Codable {
      case httpError
      case requestTimOutError
      case malformedUrlError
      case unparsableResponseError
      case jsonSerializationError
      case unrecognizedApiKeyError
      case locationUnavailableError
      case locationAccessDenied
    }
  }
}
