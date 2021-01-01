//
//  BaseViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import Foundation

protocol BaseViewController {
  associatedtype ViewModel: BaseViewModel
  init(dependencies: ViewModel.Dependencies)
}
