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
    }
    
    typealias InputType = NavigationControllerType
    typealias ResultType = UINavigationController
    
    static func make(fromType type: InputType) -> ResultType {
      let navigationController = UINavigationController()
      
      switch type {
      case .standard:
        navigationController.navigationBar.backgroundColor = Constants.Theme.Color.ViewElement.background
        navigationController.navigationBar.barTintColor = Constants.Theme.Color.ViewElement.background
        navigationController.navigationBar.tintColor = Constants.Theme.Color.ViewElement.background
  
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.titleTextAttributes = [.foregroundColor: Constants.Theme.Color.ContentElement.title]
        navigationController.navigationBar.barStyle = .default
      }
      
      return navigationController
    }
  }
}
