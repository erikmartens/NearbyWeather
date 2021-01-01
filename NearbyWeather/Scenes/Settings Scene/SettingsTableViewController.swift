//
//  SettingsTableViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxFlow
import RxCocoa

final class SettingsTableViewController: UITableViewController, Stepper {
  
  // MARK: - Routing
  
  var steps = PublishRelay<Step>()
  
  // MARK: - ViewController LifeCycle
  
  override init(style: UITableView.Style) {
    super.init(style: style)
    
    tableView.register(ImagedSingleLabelCell.self, forCellReuseIdentifier: ImagedSingleLabelCell.reuseIdentifier)
    tableView.register(ImagedDualLabelCell.self, forCellReuseIdentifier: ImagedDualLabelCell.reuseIdentifier)
    tableView.register(ImagedToggleCell.self, forCellReuseIdentifier: ImagedToggleCell.reuseIdentifier)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = R.string.localizable.tab_settings()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
  
  // MARK: - TableViewDelegate
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    switch indexPath.section {
    case 0:
      steps.accept(SettingsStep.about)
    case 1:
      if indexPath.row == 0 {
        steps.accept(SettingsStep.apiKeyEdit)
        return
      }
      navigationController?.presentSafariViewController(for: Constants.Urls.kOpenWeatherMapInstructionsUrl)
    case 2:
      if indexPath.row == 0 {
        steps.accept(SettingsStep.manageLocations)
      } else if indexPath.row == 1 {
        steps.accept(SettingsStep.addLocation)
      }
    case 3:
      if indexPath.row == 1 {
        showOptionsAlert(withType: .preferredBookmark)
      }
    case 4:
      break
    case 5:
      if indexPath.row == 0 {
        showOptionsAlert(withType: .preferredTemperatureUnit)
      } else {
        showOptionsAlert(withType: .preferredDistanceSpeedUnit)
      }
    default:
      break
    }
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return R.string.localizable.general()
    case 1:
      return R.string.localizable.openWeatherMap_api()
    case 2:
      return R.string.localizable.bookmarks()
    case 3:
      return nil
    case 4:
      return R.string.localizable.preferences()
    case 5:
      return nil
    default:
      return nil
    }
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    6
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 1
    case 1:
      return 2
    case 2:
      return 2
    case 3:
      return 2
    case 4:
      return 1
    case 5:
      return 2
    default:
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      let cell = tableView.dequeueReusableCell(withIdentifier: ImagedSingleLabelCell.reuseIdentifier, for: indexPath) as! ImagedSingleLabelCell
      cell.configure(
        withTitle: R.string.localizable.about(),
        image: R.image.info(),
        imageBackgroundColor: Constants.Theme.Color.SystemColor.blue
      )
      cell.accessoryType = .disclosureIndicator
      return cell
    case 1:
      if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagedSingleLabelCell.reuseIdentifier, for: indexPath) as! ImagedSingleLabelCell
        cell.configure(
          withTitle: R.string.localizable.apiKey(),
          image: R.image.seal(),
          imageBackgroundColor: Constants.Theme.Color.SystemColor.green
        )
        cell.accessoryType = .disclosureIndicator
        return cell
      }
      let cell = tableView.dequeueReusableCell(withIdentifier: ImagedSingleLabelCell.reuseIdentifier, for: indexPath) as! ImagedSingleLabelCell
      cell.configure(
        withTitle: R.string.localizable.get_started_with_openweathermap(),
        image: R.image.start(),
        imageBackgroundColor: Constants.Theme.Color.SystemColor.green
      )
      cell.accessoryType = .disclosureIndicator
      return cell
    case 2:
      if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagedDualLabelCell.reuseIdentifier, for: indexPath) as! ImagedDualLabelCell
        
        let entriesCount = WeatherInformationService.shared.bookmarkedLocations.count
        let description: String
        switch entriesCount {
        case 0:
          description = R.string.localizable.empty_bookmarks()
          cell.accessoryType = .none
          cell.selectionStyle = .none
        case 1:
          description = WeatherInformationService.shared.bookmarkedLocations[indexPath.row].name
          cell.accessoryType = .disclosureIndicator
          cell.selectionStyle = .default
        default:
          description = String(describing: entriesCount)
          cell.accessoryType = .disclosureIndicator
          cell.selectionStyle = .default
        }
        
        cell.configure(
          withTitle: R.string.localizable.manage_locations(),
          description: description,
          image: R.image.wrench(),
          imageBackgroundColor: Constants.Theme.Color.SystemColor.red
        )
        return cell
      }
      let cell = tableView.dequeueReusableCell(withIdentifier: ImagedSingleLabelCell.reuseIdentifier, for: indexPath) as! ImagedSingleLabelCell
      cell.configure(
        withTitle: R.string.localizable.add_location(),
        image: R.image.add_bookmark(),
        imageBackgroundColor: Constants.Theme.Color.SystemColor.red
      )
      cell.accessoryType = .disclosureIndicator
      return cell
    case 3:
      if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagedToggleCell.reuseIdentifier, for: indexPath) as! ImagedToggleCell
        cell.configure(
          withTitle: R.string.localizable.show_temp_on_icon(),
          image: R.image.badge(),
          imageBackgroundColor: Constants.Theme.Color.SystemColor.red,
          toggleIsOnHandler: { sender in
            BadgeService.shared.isAppIconBadgeNotificationEnabled { enabled in
              sender.isOn = enabled
            }
          },
          toggleSwitchHandler: { [weak self] sender in
            guard sender.isOn else {
              BadgeService.shared.setTemperatureOnAppIconEnabled(false)
              return
            }
            
            PermissionsService.shared.requestNotificationPermissions { [weak self] approved in
              guard approved else {
                sender.setOn(false, animated: true)
                self?.showNotificationsSettingsAlert()
                return
              }
              BadgeService.shared.setTemperatureOnAppIconEnabled(true)
            }
        })
        cell.selectionStyle = .none
        return cell
      }
      
      let cell = tableView.dequeueReusableCell(withIdentifier: ImagedDualLabelCell.reuseIdentifier, for: indexPath) as! ImagedDualLabelCell
      
      // TODO: fix this
      if let preferredBookmarkId = PreferencesDataService.shared.preferredBookmark.value,
        WeatherInformationService.shared.bookmarkedLocations.first(where: { $0.identifier == preferredBookmarkId }) == nil {
          PreferencesDataService.shared.preferredBookmark = PreferredBookmarkOption(value: nil)
      }
      
      cell.configure(
        withTitle: R.string.localizable.preferred_bookmark(),
        description: PreferencesDataService.shared.preferredBookmark.stringValue,
        image: R.image.preferred_bookmark(),
        imageBackgroundColor: Constants.Theme.Color.SystemColor.red
      )
      
      return cell
    case 4:
      let cell = tableView.dequeueReusableCell(withIdentifier: ImagedToggleCell.reuseIdentifier, for: indexPath) as! ImagedToggleCell
      cell.configure(
        withTitle: R.string.localizable.refresh_on_app_start(),
        image: R.image.reload(),
        imageBackgroundColor: Constants.Theme.Color.SystemColor.gray,
        toggleIsOnHandler: { sender in
          sender.isOn = UserDefaults.standard.bool(forKey: Constants.Keys.UserDefaults.kRefreshOnAppStartKey)
        },
        toggleSwitchHandler: { sender in
          UserDefaults.standard.set(sender.isOn, forKey: Constants.Keys.UserDefaults.kRefreshOnAppStartKey)
      })
      cell.selectionStyle = .none
      return cell
    case 5:
      if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagedDualLabelCell.reuseIdentifier, for: indexPath) as! ImagedDualLabelCell
        cell.configure(
          withTitle: R.string.localizable.temperature_unit(),
          description: PreferencesDataService.shared.temperatureUnit.stringValue,
          image: R.image.thermometer(),
          imageBackgroundColor: Constants.Theme.Color.SystemColor.gray
        )
        return cell
      }
      let cell = tableView.dequeueReusableCell(withIdentifier: ImagedDualLabelCell.reuseIdentifier, for: indexPath) as! ImagedDualLabelCell
      cell.configure(
        withTitle: R.string.localizable.distanceSpeed_unit(),
        description: PreferencesDataService.shared.distanceSpeedUnit.stringValue,
        image: R.image.dimension(),
        imageBackgroundColor: Constants.Theme.Color.SystemColor.gray
      )
      return cell
    default:
      return UITableViewCell()
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    UITableView.automaticDimension
  }
  
  // MARK: - Private Helpers
  
  private enum OptionsAlertType {
    case preferredBookmark
    case preferredAmountOfResults
    case preferredSortingOrientation
    case preferredTemperatureUnit
    case preferredDistanceSpeedUnit
  }
  
  private func showOptionsAlert(withType type: OptionsAlertType) {
    let completionHandler: (Bool) -> Void = { [weak self] optionChanged in
      guard optionChanged else { return }
      DispatchQueue.main.async {
        self?.tableView.reloadData()
      }
    }
    
    var alert: UIAlertController
    
    switch type {
    case .preferredBookmark:
      var options = [PreferredBookmarkOption(value: .none)]
      options.append(contentsOf:
        WeatherInformationService.shared.bookmarkedLocations.map { $0.identifier }.map(PreferredBookmarkOption.init)
      )
      alert = Factory.AlertController.make(fromType:
        .preferredBookmarkOptions(options: options,
                                  completionHandler: completionHandler)
      )
    case .preferredTemperatureUnit:
      alert = Factory.AlertController.make(fromType:
        .preferredTemperatureUnitOptions(options: TemperatureUnitOption.availableOptions,
                                         completionHandler: completionHandler)
      )
    case .preferredDistanceSpeedUnit:
      alert = Factory.AlertController.make(fromType:
        .preferredSpeedUnitOptions(options: DimensionalUnitsOption.availableOptions,
                                   completionHandler: completionHandler)
      )
    case .preferredAmountOfResults, .preferredSortingOrientation:
      return // these options cannot be configured in settings
    }
    present(alert, animated: true, completion: nil)
  }
  
  private func showNotificationsSettingsAlert() {
    let alert = Factory.AlertController.make(fromType: .pushNotificationsDisabled)
    present(alert, animated: true, completion: nil)
  }
}
