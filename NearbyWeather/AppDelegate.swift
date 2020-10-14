//
//  AppDelegate.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxFlow
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  // MARK: - Properties
  
  var window: UIWindow?
  var welcomeWindow: UIWindow?
  
  private var flowCoordinator: FlowCoordinator?
  
  private var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid
  
  // MARK: - Functions
    
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    instantiateServices()
    instantiateApplicationUserInterface()
    
    if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
      let firebaseOptions = FirebaseOptions(contentsOfFile: filePath) {
      FirebaseApp.configure(options: firebaseOptions)
    }
    
    SettingsBundleTransferService.shared.updateSystemSettings()
  
    return true
  }
  
  /// Allows to deal with 3D-Touch actions.
  /// Triggers the handler which will process the selected shortcut action.
  /// - Parameters:
  ///   - application:
  ///   - shortcutItem:
  ///   - completionHandler:
  ///
  func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
    completionHandler(handleShortcut(item: shortcutItem))
  }
  
  /// Using the given `item` deal with the action to process.
  ///
  /// Because RxFlow is not really ready for 3D-Touch quick actions, it is a bit tricky to handle a quick action from app icon to
  /// the the ad-bookmark-location screen. Thus we stops before, at tab at index 2 to finally let user click on the item.
  ///
  /// - Parameter item: The selected item
  /// - Returns: True if the item has been managed, false otherwise
  ///
  private func handleShortcut(item: UIApplicationShortcutItem) -> Bool {
    guard let shortcutIdentifier = Constants.ShortcutIdentifier(fullIdentifier: item.type) else {
      return false
    }
    guard let tabBarController = UIApplication.shared.windows.first!.rootViewController as? UITabBarController else {
      return false
    }
    switch shortcutIdentifier {
    case .addBookmarkedLocation:
      tabBarController.selectedIndex = 2 // Tab at index 2 contains the item to cick on to add new bookmark
      return true
    case .weatherDetailsOfBookmarkedLocation:
      tabBarController.selectedIndex = 0 // Bookmarked location weather details is on tab at index 0
      return true
    }
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    refreshWeatherDataIfNeeded()
  }
  
  func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    self.backgroundTaskId = application.beginBackgroundTask { [weak self] in
      self?.endBackgroundTask()
    }
    
    WeatherDataService.shared.updatePreferredBookmark { [weak self] result in
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

extension AppDelegate {
  
  private func instantiateServices() {
    WeatherNetworkingService.instantiateSharedInstance()
    UserLocationService.instantiateSharedInstance()
    PreferencesDataService.instantiateSharedInstance()
    WeatherDataService.instantiateSharedInstance()
    PermissionsService.instantiateSharedInstance()
    BadgeService.instantiateSharedInstance()
  }
  
  private func instantiateApplicationUserInterface() {
    let window = UIWindow(frame: UIScreen.main.bounds)
    self.window = window
    let rootFlow = RootFlow(rootWindow: window)
    
    flowCoordinator = FlowCoordinator()
    flowCoordinator?.coordinate(
      flow: rootFlow,
      with: RootStepper()
    )
  }
  
  private func refreshWeatherDataIfNeeded() {
    if UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey) != nil,
      UserDefaults.standard.bool(forKey: Constants.Keys.UserDefaults.kRefreshOnAppStartKey) == true {
      WeatherDataService.shared.update(withCompletionHandler: nil)
    }
  }
  
  private func endBackgroundTask() {
    UIApplication.shared.endBackgroundTask(backgroundTaskId)
    backgroundTaskId = .invalid
  }
}
