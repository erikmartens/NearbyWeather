//
//  SetPermissionsViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.04.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxFlow
import RxCocoa

final class SetPermissionsViewController: CustomUIViewController, Stepper {
  
  // MARK: - Routing
  
  var steps = PublishRelay<Step>()
  
  // MARK: - Properties
  
  private var timer: Timer?
  
  // MARK: - Outlets
  
  @IBOutlet var mainView: UIView!
  @IBOutlet weak var bubbleView: UIView!
  @IBOutlet weak var warningImageView: UIImageView!
  
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var askPermissionsButton: UIButton!
  
  // MARK: - Override Functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = R.string.localizable.location_access()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(Self.dismiss),
      name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kLocationAuthorizationUpdated),
      object: nil
    )
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
    
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    animatePulse()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    warningImageView.layer.removeAllAnimations()
    timer?.invalidate()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Helper Functions

  /// Configures the elements displayed in this `UIViewController`.
  /// Inherited from `CustomUIViewController`
  ///
  override func configure() {
        
    bubbleView.layer.cornerRadius = 10
    bubbleView.backgroundColor = Constants.Theme.Color.BrandColors.standardDay
    warningImageView.backgroundColor = Constants.Theme.Color.BrandColors.standardDay // Mandatory for iOS < 13, otherwise not displayed
        
    descriptionLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    descriptionLabel.text! = R.string.localizable.configure_location_permissions_description()
    descriptionLabel.textColor = .white
    
    askPermissionsButton.setTitle(R.string.localizable.configure().uppercased(), for: .normal)
    askPermissionsButton.setTitleColor(.white, for: UIControl.State())
    askPermissionsButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
    askPermissionsButton.layer.cornerRadius = askPermissionsButton.bounds.height/2
    askPermissionsButton.layer.backgroundColor = Constants.Theme.Color.BrandColors.standardDay.cgColor
        
    mainView.backgroundColor = Constants.Theme.Color.ViewElement.background
        
  }
    
  fileprivate func startAnimationTimer() {
    timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: (#selector(Self.animatePulse)), userInfo: nil, repeats: false)
  }
  
  @objc private func animatePulse() {
    warningImageView.layer.removeAllAnimations()
    warningImageView.animatePulse(withAnimationDelegate: self)
  }
  
  @objc func launchApp() {
    steps.accept(WelcomeStep.dismiss)
  }
  
  // MARK: - Button Interaction
  
  @IBAction func didTapAskPermissionsButton(_ sender: UIButton) {
    guard UserLocationService.shared.authorizationStatus != .notDetermined else {
      UserLocationService.shared.requestWhenInUseAuthorization()
      return
    }
    launchApp()
  }
}

extension SetPermissionsViewController: CAAnimationDelegate {
  
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    startAnimationTimer()
  }
}
