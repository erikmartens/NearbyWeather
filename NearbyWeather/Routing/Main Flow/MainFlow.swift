//
//  MainFlow.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxFlow

final class MainFlow: Flow {

  // MARK: - Assets

  var root: Presentable {
    rootViewController
  }

  private lazy var rootViewController: UITabBarController = {
    let tabbar = UITabBarController()
    tabbar.tabBar.backgroundColor = Constants.Theme.Color.ViewElement.background
    tabbar.tabBar.barTintColor = Constants.Theme.Color.ViewElement.background
    tabbar.tabBar.tintColor = Constants.Theme.Color.MarqueColors.standardDay
    return tabbar
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
    guard let step = step as? MainStep else {
      return .none
    }
    switch step {
    case .main:
      return summonRootTabBar()
    }
  }
}

private extension MainFlow {

  func summonRootTabBar() -> FlowContributors {

    let listFlow = ListFlow()
    let mapFlow = MapFlow()
    let settingsFlow = SettingsFlow()

    Flows.whenReady(
      flow1: listFlow,
      flow2: mapFlow,
      flow3: settingsFlow
    ) { [rootViewController] (listRoot: UINavigationController, mapRoot: UINavigationController, settingsRoot: UINavigationController) in
      rootViewController.viewControllers = [
        listRoot,
        mapRoot,
        settingsRoot
      ]
    }

    return .multiple(flowContributors: [
      .contribute(withNextPresentable: listFlow, withNextStepper: ListStepper()),
      .contribute(withNextPresentable: mapFlow, withNextStepper: MapStepper()),
      .contribute(withNextPresentable: settingsFlow, withNextStepper: SettingsStepper())
    ])
  }
}
