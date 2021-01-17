//
//  Factory+NavigationController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UINavigationController

extension Factory {
  
  struct NavigationController: FactoryFunction {
    
    enum NavigationControllerType {
      case standard
      case standardTabbed(tabTitle: String? = nil, tabImage: UIImage? = nil)
    }
    
    typealias InputType = NavigationControllerType
    typealias ResultType = UINavigationController
    
    static func make(fromType type: InputType) -> ResultType {
      let navigationController = UINavigationController()
      
      navigationController.navigationBar.backgroundColor = Constants.Theme.Color.ViewElement.primaryBackground
      navigationController.navigationBar.barTintColor = Constants.Theme.Color.ViewElement.primaryBackground
      navigationController.navigationBar.tintColor = Constants.Theme.Color.ViewElement.titleLight
      navigationController.navigationBar.isTranslucent = false
      navigationController.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
      navigationController.navigationBar.barStyle = .default
      
      switch type {
      case .standard:
        break
      case let .standardTabbed(tabTitle, tabImage):
        navigationController.tabBarItem.title = tabTitle
        navigationController.tabBarItem.image = tabImage
      }
      
      return navigationController
    }
  }
}
