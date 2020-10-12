//
//  ListFlow.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxFlow

final class ListFlow: Flow {
  
  // MARK: - Assets
  
  var root: Presentable {
    rootViewController
  }
  
  private lazy var rootViewController: UINavigationController = {
    let navigationController = Factory.NavigationController.make(fromType: .standard)
    navigationController.tabBarItem.image = R.image.tabbar_list_ios11()
    navigationController.tabBarItem.title = R.string.localizable.tab_weatherList()
    return navigationController
  }()
  
  // MARK: - Initialization
  
  init() {}
  
  deinit {
    printDebugMessage(domain: String(describing: self), message: "was deinitialized")
  }
  
  // MARK: - Functions
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = transform(step: step) as? ListStep else {
      return .none
    }
    switch step {
    case .list:
      return summonWeatherListController()
    case .emptyList:
      return summonEmptyWeatherListController()
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
        return ListStep.dismissChildFlow
      }
    }
    return step
  }
}

private extension ListFlow {
  
  func summonWeatherListController() -> FlowContributors {
    let weatherListViewController = ListViewController(style: .grouped)
    rootViewController.setViewControllers([weatherListViewController], animated: false)
    weatherListViewController.customRootViewController = rootViewController
    return .one(flowContributor: .contribute(withNext: weatherListViewController))
  }
  
  func summonEmptyWeatherListController() -> FlowContributors {
    let emptyWeatherListViewController = R.storyboard.emptyList.emptyListViewController()!
    rootViewController.setViewControllers([emptyWeatherListViewController], animated: false)
    emptyWeatherListViewController.customRootViewController = rootViewController
    return .none
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
