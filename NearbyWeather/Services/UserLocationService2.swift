//
//  UserLocationService2.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 30.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCoreLocation

enum UserLocationServiceError: String, Error {
  
  var domain: String {
    "UserLocationService"
  }
  
  case authorizationError = "Trying access the user location, but sufficient authorization was not granted."
}

final class UserLocationService2 {
  
  // MARK: - Properties
  
  private let locationManager: CLLocationManager
  
  // MARK: - Initialization
  
  init() {
    locationManager = CLLocationManager()
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
  }
}

extension UserLocationService2 {
  
  private static func authorizationStatusIsSufficient(_ authorizationStatus: CLAuthorizationStatus) -> Bool {
    switch authorizationStatus {
    case .notDetermined, .restricted, .denied:
      return false
    case .authorizedWhenInUse, .authorizedAlways:
      return true
    @unknown default:
      return false
    }
  }
  
  func createDidUpdateLocationObservable() -> Observable<CLLocation> {
   createAuthorizationStatusObservable()
      .map { if !$0 { throw UserLocationServiceError.authorizationError } }
      .flatMapLatest { [locationManager] in
        locationManager.rx
          .location
          .errorOnNil()
      }
      .do(onSubscribe: { [locationManager] in locationManager.startUpdatingLocation() },
          onDispose: { [locationManager] in locationManager.stopUpdatingLocation() })
  }
  
  func createAuthorizationStatusSingle() -> Single<Bool> {
    Single
      .just(CLLocationManager.authorizationStatus())
      .map { Self.authorizationStatusIsSufficient($0) }
  }
  
  func createAuthorizationStatusObservable() -> Observable<Bool> {
    locationManager.rx
      .didChangeAuthorization
      .map { $0.status }
      .startWith(CLLocationManager.authorizationStatus())
      .map { Self.authorizationStatusIsSufficient($0) }
  }
}
