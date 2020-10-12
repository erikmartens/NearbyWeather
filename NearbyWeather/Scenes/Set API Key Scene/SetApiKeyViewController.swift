//
//  SetApiKeyViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 15.04.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxFlow
import RxCocoa
import TextFieldCounter

final class SetApiKeyViewController: CustomUIViewController, Stepper {
  
  // MARK: - Routing
  
  var steps = PublishRelay<Step>()
  
  // MARK: - Properties
  
  private var timer: Timer?
    
  // MARK: - Outlets
  
  @IBOutlet var mainView: UIView!
  @IBOutlet weak var bubbleView: UIView!
  @IBOutlet weak var warningImageView: UIImageView!
  
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var inputTextField: TextFieldCounter!
  
  @IBOutlet weak var saveButtonContainerView: UIView!
  @IBOutlet weak var saveButton: UIButton!
  @IBOutlet weak var getInstructionsButtons: UIButton!
  
  // MARK: - Override Functions
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = R.string.localizable.welcome()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    checkValidTextFieldInput()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    inputTextField.becomeFirstResponder()
    animatePulse()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    warningImageView.layer.removeAllAnimations()
    timer?.invalidate()
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
    descriptionLabel.text! = R.string.localizable.welcome_api_key_description()
    descriptionLabel.textColor = .white
    
    inputTextField.limitColor = Constants.Theme.Color.InteractableElement.standardTint
    inputTextField.textColor = Constants.Theme.Color.ContentElement.title
    inputTextField.tintColor = Constants.Theme.Color.ContentElement.title
    inputTextField.counterColor = inputTextField.textColor ?? .black
    
    saveButton.setTitleColor(.white, for: UIControl.State())
    saveButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
    saveButton.layer.cornerRadius = saveButton.bounds.height/2
    saveButton.layer.backgroundColor = Constants.Theme.Color.BrandColors.standardDay.cgColor
    saveButton.setTitle(R.string.localizable.save().uppercased(), for: .normal)

    getInstructionsButtons.setTitle(R.string.localizable.get_api_key_description().uppercased(), for: .normal)
    getInstructionsButtons.setTitleColor(Constants.Theme.Color.InteractableElement.standardButton, for: .normal)
    getInstructionsButtons.setTitleColor(Constants.Theme.Color.InteractableElement.standardButton, for: .highlighted)
  
    mainView.backgroundColor = Constants.Theme.Color.ViewElement.background
    
  }
  
  fileprivate func startAnimationTimer() {
    timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: (#selector(SetApiKeyViewController.animatePulse)), userInfo: nil, repeats: false)
  }
  
  @objc private func animatePulse() {
    warningImageView.layer.removeAllAnimations()
    warningImageView.animatePulse(withAnimationDelegate: self)
  }
  
  // MARK: - TextField Interaction
  
  @IBAction func inputTextFieldEditingChanged(_ sender: TextFieldCounter) {
    checkValidTextFieldInput()
  }
  
  private func checkValidTextFieldInput() {
    defer {
      saveButtonContainerView.isHidden = !saveButton.isEnabled
    }
    
    guard let text = inputTextField.text,
      text.count == 32 else {
        saveButton.isEnabled = false
        inputTextField.textColor = .lightGray
        return
    }
    saveButton.isEnabled = true
    inputTextField.textColor = Constants.Theme.Color.InteractableElement.standardTint
  }
  
  // MARK: - Button Interaction
  
  @IBAction func didTapSaveButton(_ sender: UIButton) {
    inputTextField.resignFirstResponder()
    UserDefaults.standard.set(inputTextField.text, forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey)
    
    steps.accept(WelcomeStep.setPermissions)
  }
  
  @IBAction func didTapGetInstructionsButton(_ sender: UIButton) {
    presentSafariViewController(for: Constants.Urls.kOpenWeatherMapInstructionsUrl)
  }
    
}

extension SetApiKeyViewController: CAAnimationDelegate {
  
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    startAnimationTimer()
  }
}
