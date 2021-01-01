//
//  SettingsFlow.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxFlow

final class SettingsFlow: Flow {
  
  // MARK: - Assets
  
  var root: Presentable {
    rootViewController
  }
  
  private lazy var rootViewController: UINavigationController = {
    let navigationController = Factory.NavigationController.make(fromType: .standard)
    
    navigationController.tabBarItem.image = R.image.tabbar_settings_ios11()
    navigationController.tabBarItem.title = R.string.localizable.tab_settings()
    
    return navigationController
  }()
  
  // MARK: - Initialization
  
  init() {}
  
  deinit {
    printDebugMessage(
      domain: String(describing: self),
      message: "was deinitialized",
      type: .info
    )
  }
  
  // MARK: - Functions
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? SettingsStep else {
      return .none
    }
    switch step {
    case .settings:
      return summonSettingsController()
    case .about:
      return summonAboutController()
    case .apiKeyEdit:
      return summonApiKeyEditController()
    case .manageLocations:
      return summonManageLocationsController()
    case .addLocation:
      return summonAddLocationController()
    case let .webBrowser(url):
      return summonWebBrowser(url: url)
    }
  }
}

private extension SettingsFlow {
  
  static func preferredTableViewStyle() -> UITableView.Style {
    if #available(iOS 13, *) {
      return .insetGrouped
    }
    return .grouped
  }
  
  func summonSettingsController() -> FlowContributors {
    let settingsViewController = SettingsTableViewController(style: SettingsFlow.preferredTableViewStyle())
    rootViewController.setViewControllers([settingsViewController], animated: false)
    return .one(flowContributor: .contribute(withNext: settingsViewController))
  }
  
  func summonAboutController() -> FlowContributors {
    let aboutController = AboutAppTableViewController(style: SettingsFlow.preferredTableViewStyle())
    rootViewController.pushViewController(aboutController, animated: true)
    return .one(flowContributor: .contribute(withNext: aboutController))
  }
  
  func summonApiKeyEditController() -> FlowContributors {
    let apiKeyEditController = SettingsInputTableViewController(style: SettingsFlow.preferredTableViewStyle())
    rootViewController.pushViewController(apiKeyEditController, animated: true)
    return .one(flowContributor: .contribute(withNext: apiKeyEditController))
  }
  
  func summonManageLocationsController() -> FlowContributors {
    guard !WeatherInformationService.shared.bookmarkedLocations.isEmpty else {
      return .none
    }
    let locationManagementController = WeatherLocationManagementTableViewController(style: SettingsFlow.preferredTableViewStyle())
    rootViewController.pushViewController(locationManagementController, animated: true)
    return .one(flowContributor: .contribute(withNext: locationManagementController))
  }
  
  func summonAddLocationController() -> FlowContributors {
    let addLocationController = WeatherLocationSelectionTableViewController(style: SettingsFlow.preferredTableViewStyle())
    rootViewController.pushViewController(addLocationController, animated: true)
    return .one(flowContributor: .contribute(withNext: addLocationController))
  }
  
  func summonWebBrowser(url: URL) -> FlowContributors {
    rootViewController.presentSafariViewController(for: url)
    return .none
  }
}
