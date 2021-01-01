//
//  AppDelegate.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift
import RxFlow
import Swinject
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  // MARK: - Properties

  var window: UIWindow?
  var welcomeWindow: UIWindow?

  private var dependencyContainer: Container?
  private var flowCoordinator: FlowCoordinator?

  private var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid

  // MARK: - Functions

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()

    instantiateServices()
    instantiateApplicationUserInterface()

    runMigrationIfNeeded()

    if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
      let firebaseOptions = FirebaseOptions(contentsOfFile: filePath) {
      FirebaseApp.configure(options: firebaseOptions)
    }

    SettingsBundleTransferWorker.updateSystemSettings()

    return true
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    refreshWeatherDataIfNeeded()
  }

  func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    self.backgroundTaskId = application.beginBackgroundTask { [weak self] in
      self?.endBackgroundTask()
    }

    WeatherInformationService.shared.updatePreferredBookmark { [weak self] result in
      switch result {
      case .success:
        completionHandler(.newData)
      case .failure:
        completionHandler(.failed)
      }
      self?.endBackgroundTask()
    }
  }
}

// MARK: - Private Helper Functions

private extension AppDelegate {

  func instantiateServices() {
    PermissionsService.instantiateSharedInstance()
    BadgeService.instantiateSharedInstance()

    let dependencyContainer = Container()

    dependencyContainer.register(PreferencesService2.self) { _ in PreferencesService2() }
    dependencyContainer.register(UserLocationService2.self) { _ in UserLocationService2() }

    dependencyContainer.register(WeatherStationService2.self) { resolver in
      WeatherStationService2(dependencies: WeatherStationService2.Dependencies(
        preferencesService: resolver.resolve(PreferencesService2.self)!
      ))
    }

    dependencyContainer.register(WeatherInformationService2.self) { resolver in
      WeatherInformationService2(dependencies: WeatherInformationService2.Dependencies(
        preferencesService: resolver.resolve(PreferencesService2.self)!,
        userLocationService: resolver.resolve(UserLocationService2.self)!
      ))
    }

    self.dependencyContainer = dependencyContainer
  }

  func instantiateApplicationUserInterface() {
    let window = UIWindow(frame: UIScreen.main.bounds)
    self.window = window
    let rootFlow = RootFlow(
      rootWindow: window,
      dependencyContainer: dependencyContainer!
    )

    flowCoordinator = FlowCoordinator()
    flowCoordinator?.coordinate(
      flow: rootFlow,
      with: RootStepper()
    )
  }

  func refreshWeatherDataIfNeeded() {
    guard UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey) != nil,
      UserDefaults.standard.bool(forKey: Constants.Keys.UserDefaults.kRefreshOnAppStartKey) == true,
      let weatherInformationService = dependencyContainer?.resolve(WeatherInformationService2.self) else {
        return
    }
    _ = Completable.zip([
        weatherInformationService.createUpdateBookmarkedWeatherInformationCompletable(),
        weatherInformationService.createUpdateNearbyWeatherInformationCompletable()
      ])
      .subscribe()
  }

  func endBackgroundTask() {
    UIApplication.shared.endBackgroundTask(backgroundTaskId)
    backgroundTaskId = .invalid
  }

  func runMigrationIfNeeded() {
    guard let dependencyContainer = dependencyContainer,
      let preferencesService = dependencyContainer.resolve(PreferencesService2.self),
      let weatherInformationService = dependencyContainer.resolve(WeatherInformationService2.self) else {
        return
    }
    MigrationService(dependencies: MigrationService.Dependencies(
      preferencesService: preferencesService,
      weatherInformationService: weatherInformationService
    ))
    .runMigrationIfNeeded()
  }
}
