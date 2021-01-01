//
//  EmptyListViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.02.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

final class EmptyListViewController: UIViewController {

  // MARK: - IBOutlets

  @IBOutlet weak var emptyListImageView: UIImageView!
  @IBOutlet weak var emptyListTitleLabel: UILabel!
  @IBOutlet weak var emptyListDescriptionLabel: UILabel!

  @IBOutlet weak var reloadButton: UIButton!

  // MARK: - ViewController Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    title = R.string.localizable.tab_weatherList()

    configureWeatherDataUnavailableElements()
    configureButtons()

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(Self.reconfigureOnNetworkDidBecomeAvailable),
      name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kNetworkReachabilityChanged),
      object: nil
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  // MARK: - IBActions

  @IBAction func didTapReloadButton(_ sender: UIButton) {
    WeatherInformationService.shared.update(withCompletionHandler: nil)
  }

  // MARK: - Functions

  @objc private func reconfigureOnNetworkDidBecomeAvailable() {
    UIView.animate(withDuration: 0.5) {
      self.reloadButton.isHidden = WeatherNetworkingService.shared.reachabilityStatus != .connected
    }
  }

  private func configureWeatherDataUnavailableElements() {
    emptyListImageView.tintColor = .lightGray
    emptyListTitleLabel.text = R.string.localizable.no_weather_data()
    emptyListDescriptionLabel.text = R.string.localizable.no_data_description()
  }
  
  private func configureButtons() {
    reloadButton.isHidden = WeatherNetworkingService.shared.reachabilityStatus != .connected

    reloadButton.setTitle(R.string.localizable.reload().uppercased(), for: .normal)
    reloadButton.setTitleColor(.white, for: UIControl.State())
    reloadButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
    reloadButton.layer.cornerRadius = reloadButton.bounds.height/2
    reloadButton.layer.backgroundColor = Constants.Theme.Color.MarqueColors.standardDay.cgColor
  }
}
