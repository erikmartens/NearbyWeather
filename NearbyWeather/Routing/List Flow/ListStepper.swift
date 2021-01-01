//
//  ListStepper.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import RxCocoa
import RxFlow

enum ListStep: Step {
  case list
  case emptyList
  case weatherDetails(identifier: Int?, isBookmark: Bool)
  case dismissChildFlow
}

final class ListStepper: Stepper {
  
  init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(Self.emitStepOnWeatherDataServiceDidUpdate),
      name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kWeatherServiceDidUpdate),
      object: nil
    )
  }
  
  var steps = PublishRelay<Step>()
  
  var initialStep: Step {
    WeatherInformationService.shared.hasDisplayableData
      ? ListStep.list
      : ListStep.emptyList
  }
  
  @objc private func emitStepOnWeatherDataServiceDidUpdate() {
    guard WeatherInformationService.shared.hasDisplayableData else {
      steps.accept(ListStep.emptyList)
      return
    }
    steps.accept(ListStep.list)
  }
}
