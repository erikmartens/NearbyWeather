//
//  SettingsInputTableViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxFlow
import RxCocoa
import PKHUD

final class SettingsInputTableViewController: UITableViewController, Stepper {

  // MARK: - Routing

  var steps = PublishRelay<Step>()

  // MARK: - ViewController Life Cycle

  override init(style: UITableView.Style) {
    super.init(style: style)

    tableView.delegate = self
    tableView.register(UINib(nibName: R.nib.textInputCell.name, bundle: R.nib.textInputCell.bundle),
                       forCellReuseIdentifier: R.reuseIdentifier.textInputCell.identifier)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = R.string.localizable.api_settings()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextInputCell)?.inputTextField.becomeFirstResponder()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    validateAndSave()
  }

  // MARK: - TableViewDataSource

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return R.string.localizable.enter_api_key()
  }

  override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return R.string.localizable.api_key_length_description()
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.textInputCell.identifier) as! TextInputCell
    cell.inputTextField.delegate = self
    cell.inputTextField.text = UserDefaults.standard.string(forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey)

    cell.inputTextField.animate = true
    cell.inputTextField.ascending = true
    cell.inputTextField.maxLength = 32
    cell.inputTextField.counterColor = cell.inputTextField.textColor ?? .black
    cell.inputTextField.limitColor = Constants.Theme.Color.MarqueColors.standardDay

    return cell
  }

  // MARK: - ScrollViewDelegate

  override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextInputCell)?.inputTextField.resignFirstResponder()
  }

  // MARK: - Private Helpers

  @discardableResult fileprivate func validateAndSave() -> Bool {
    guard let text = (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextInputCell)?.inputTextField.text,
      text.count == 32
      else {
        return false
    }

    (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextInputCell)?.inputTextField.resignFirstResponder()

    if let currentApiKey = UserDefaults.standard.string(forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey), text == currentApiKey {
      return true // saving is unnecessary as there was no change
    }
    UserDefaults.standard.set(text, forKey: Constants.Keys.UserDefaults.kNearbyWeatherApiKeyKey)
    HUD.flash(.success, delay: 1.0)
    WeatherInformationService.shared.update(withCompletionHandler: nil)
    return true
  }
}

extension SettingsInputTableViewController: UITextFieldDelegate {

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    navigationController?.popViewController(animated: true)
    return validateAndSave()
  }
}
