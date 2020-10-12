//
//  MapFlow.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxFlow

final class MapFlow: Flow {
  
  // MARK: - Assets
  
  var root: Presentable {
    rootViewController
  }
  
  private lazy var rootViewController: UINavigationController = {
    let navigationController = Factory.NavigationController.make(fromType: .standard)
    
    navigationController.tabBarItem.image = R.image.tabbar_map_ios11()
    navigationController.tabBarItem.title = R.string.localizable.tab_weatherMap()
    
    return navigationController
  }()
  
  // MARK: - Initialization
  
  init() {}
  
  deinit {
    printDebugMessage(domain: String(describing: self), message: "was deinitialized")
  }
  
  // MARK: - Functions
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = transform(step: step) as? MapStep else {
      return .none
    }
    switch step {
    case .map:
      return summonWeatherMapController()
    case let .weatherDetails(identifier, isBookmark):
      return summonWeatherDetailsController(identifier: identifier,
                                            isBookmark: isBookmark)
    case .dismissChildFlow:
      return dismissChildFlow()
    }
  }
  
  private func transform(step: Step) -> Step? {
    if let weatherDetailStep = step as? WeatherDetailStep {
      switch weatherDetailStep {
      case .weatherDetail:
        return nil
      case .dismiss:
        return MapStep.dismissChildFlow
      }
    }
    return step
  }
}

private extension MapFlow {
  
  func summonWeatherMapController() -> FlowContributors {
    let mapViewController = MapViewController()
    rootViewController.setViewControllers([mapViewController], animated: false)
    mapViewController.customRootViewController = rootViewController
    return .one(flowContributor: .contribute(withNext: mapViewController))
  }
  
  func summonWeatherDetailsController(identifier: Int?, isBookmark: Bool) -> FlowContributors {
    guard let identifier = identifier else {
      return .none
    }
    let weatherDetailFlow = WeatherDetailFlow(dependencies: WeatherDetailFlow.Dependencies(
      identifier: identifier,
      isBookmark: isBookmark
    ))
    
    Flows.whenReady(flow1: weatherDetailFlow) { [rootViewController] (weatherDetailRoot: UINavigationController) in
      rootViewController.present(weatherDetailRoot, animated: true)
    }
    
    return .one(flowContributor: .contribute(withNextPresentable: weatherDetailFlow, withNextStepper: WeatherDetailStepper()))
  }
  
  func dismissChildFlow() -> FlowContributors {
    rootViewController.presentedViewController?.dismiss(animated: true, completion: nil)
    return .none
  }
}
