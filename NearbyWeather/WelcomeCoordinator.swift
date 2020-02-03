//
//  WelcomeCoordinator.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 01.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

enum WelcomeCoordinatorStep: String, Step {
  case initial
  case dismiss
  case none
}

final class WelcomeCoordinator: Coordinator {
  
  // MARK: - Common Properties
  
  override var rootViewController: UIViewController {
    return root
  }
  
  private lazy var root: UINavigationController = {
    let navigationController = UINavigationController()
    navigationController.navigationBar.backgroundColor = .white
    navigationController.navigationBar.barTintColor = .black
    navigationController.navigationBar.tintColor = .nearbyWeatherStandard
    return navigationController
  }()
  
  // MARK: - Properties
  
  weak var windowManager: WindowManager?

  // MARK: - Initialization
  
  init(windowManager: WindowManager) {
    super.init(parentCoordinator: nil)
    
    self.windowManager = windowManager
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(Self.didReceiveStep),
      name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kWelcomeCoordinatorExeceuteRoutingStep),
      object: nil
    )
  }
  
  // MARK: - Navigation
  
  @objc func didReceiveStep(_ notification: Notification) {
    guard let userInfo = notification.userInfo as? [String: String],
      let stepString = userInfo[Constants.Keys.AppCoordinator.kStep],
      let step = WelcomeCoordinatorStep(rawValue: stepString) else {
        return
    }
    let childCoordinator = executeRoutingStep(step)
    childCoordinators.appendSafe(childCoordinator)
  }
  
  override func executeRoutingStep(_ step: Step) -> Coordinator? {
    guard let step = step as? WelcomeCoordinatorStep else { return nil }
    
    switch step {
    case .initial:
      return summonWelcomeWindow()
    case .dismiss:
      return dismissWelcomeWindow()
    case .none:
      return nil
    }
  }
}
  
  // MARK: - Navigation Helper Functions

private extension WelcomeCoordinator {
  
  private func summonWelcomeWindow() -> Coordinator? {
   
    let welcomeViewController = R.storyboard.welcome.welcomeScreenViewController()!
    let root = rootViewController as? UINavigationController
    root?.setViewControllers([welcomeViewController], animated: false)
    
    let splashScreenWindow = UIWindow(frame: UIScreen.main.bounds)
    splashScreenWindow.rootViewController = root
    splashScreenWindow.windowLevel = UIWindow.Level.alert
    splashScreenWindow.makeKeyAndVisible()
    
    windowManager?.splashScreenWindow = splashScreenWindow
    
    return nil
  }
  
  private func dismissWelcomeWindow() -> Coordinator? {
    UIView.animate(withDuration: 0.2,
                   animations: { [weak self] in
                    self?.windowManager?.splashScreenWindow?.alpha = 0
                    self?.windowManager?.splashScreenWindow?.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
      },
                   completion: { [weak self] _ in
                    self?.windowManager?.splashScreenWindow?.resignKey()
                    self?.windowManager?.splashScreenWindow = nil
                    self?.windowManager?.window?.makeKeyAndVisible()
    })
    return nil
  }
}