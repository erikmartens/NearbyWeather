//
//  WeatherDetailFlow.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxFlow

extension WeatherDetailFlow {
  struct Dependencies {
    let identifier: Int
    let isBookmark: Bool
  }
}

final class WeatherDetailFlow: Flow {
  
  // MARK: - Assets
  
  var root: Presentable {
    rootViewController
  }
  
  private lazy var rootViewController: UINavigationController = {
    Factory.NavigationController.make(fromType: .standard)
  }()
  
  // MARK: - Dependencies
  
  private let dependencies: Dependencies
  
  // MARK: - Initialization
  
  init(dependencies: Dependencies) {
    self.dependencies = dependencies
  }
  
  deinit {
    printDebugMessage(
      domain: String(describing: self),
      message: "was deinitialized",
      type: .info
    )
  }
  
  // MARK: - Functions
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? WeatherDetailStep else {
      return .none
    }
    switch step {
    case .weatherDetail:
      return summonWeatherDetailController(weatherDataIdentifier: dependencies.identifier,
                                           isBookmark: dependencies.isBookmark)
    case .dismiss:
      return dismissWeatherDetailController()
    }
  }
}

private extension WeatherDetailFlow {
  
  func summonWeatherDetailController(weatherDataIdentifier: Int?, isBookmark: Bool) -> FlowContributors {
    guard let weatherDataIdentifier = weatherDataIdentifier,
      let weatherDTO = WeatherInformationService.shared.weatherDTO(forIdentifier: weatherDataIdentifier) else {
        return .none
    }
    let weatherDetailViewController = WeatherDetailViewController.instantiateFromStoryBoard(
      weatherDTO: weatherDTO,
      isBookmark: isBookmark
    )
    
    rootViewController.setViewControllers([weatherDetailViewController], animated: false)
    return .one(flowContributor: .contribute(withNext: weatherDetailViewController))
  }
  
  func dismissWeatherDetailController() -> FlowContributors {
    .end(forwardToParentFlowWithStep: WeatherDetailStep.dismiss)
  }
}
