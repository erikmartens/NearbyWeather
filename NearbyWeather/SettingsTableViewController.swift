//
//  SettingsTableViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 03.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    // MARK: - ViewController Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("SettingsTVC_NavigationBarTitle", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.styleStandard(withTransluscency: false, animated: true)
        navigationController?.navigationBar.addDropShadow(offSet: CGSize(width: 0, height: 1), radius: 10)
        
        tableView.reloadData()
    }
    
    // MARK: - TableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationViewController = storyboard.instantiateViewController(withIdentifier: "OWMCityFilterTableViewController") as! OWMCityFilterTableViewController

            let barButton = UIBarButtonItem()
            barButton.title = nil
            navigationItem.backBarButtonItem = barButton
            navigationController?.pushViewController(destinationViewController, animated: true)
        case 1:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationViewController = storyboard.instantiateViewController(withIdentifier: "SettingsInputTVC") as! SettingsInputTableViewController
            
            let barButton = UIBarButtonItem()
            barButton.title = nil
            navigationItem.backBarButtonItem = barButton
            navigationController?.pushViewController(destinationViewController, animated: true)
        case 2:
            WeatherDataService.shared.amountOfResults = AmountOfResultsWrappedEnum(rawValue: indexPath.row)! // force unwrap -> this should never fail, if it does the app should crash so we know
            tableView.reloadData()
        case 3:
            WeatherDataService.shared.temperatureUnit = TemperatureUnitWrappedEnum(rawValue: indexPath.row)! // force unwrap -> this should never fail, if it does the app should crash so we know
            tableView.reloadData()
        case 4:
            WeatherDataService.shared.windspeedUnit = SpeedUnitWrappedEnum(rawValue: indexPath.row)! // force unwrap -> this should never fail, if it does the app should crash so we know
            tableView.reloadData()
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("SettingsTVC_SectionTitle1", comment: "")
        case 1:
            return NSLocalizedString("SettingsTVC_SectionTitle2", comment: "")
        case 2:
            return NSLocalizedString("SettingsTVC_SectionTitle3", comment: "")
        case 3:
            return NSLocalizedString("SettingsTVC_SectionTitle4", comment: "")
        case 4:
            return NSLocalizedString("SettingsTVC_SectionTitle5", comment: "")
        default:
            return nil
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return AmountOfResultsWrappedEnum.count
        case 3:
            return TemperatureUnitWrappedEnum.count
        case 4:
            return SpeedUnitWrappedEnum.count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        cell.accessoryType = .none
        
        switch indexPath.section {
        case 0:
            cell.contentLabel.text = "\(WeatherDataService.shared.favoritedCity.name), \(WeatherDataService.shared.favoritedCity.country)"
            cell.accessoryType = .disclosureIndicator
            return cell
        case 1:
            cell.contentLabel.text = UserDefaults.standard.value(forKey: "nearby_weather.openWeatherMapApiKey") as? String
            cell.accessoryType = .disclosureIndicator
            return cell
        case 2:
            let amountResults = AmountOfResultsWrappedEnum(rawValue: indexPath.row)! // force unwrap -> this should never fail, if it does the app should crash so we know
            cell.contentLabel.text = "\(amountResults.integerValue) \(NSLocalizedString("SettingsTVC_Results", comment: ""))"
            if amountResults.integerValue == WeatherDataService.shared.amountOfResults.integerValue {
                cell.accessoryType = .checkmark
            }
            return cell
        case 3:
            let temperatureUnit = TemperatureUnitWrappedEnum(rawValue: indexPath.row)! // force unwrap -> this should never fail, if it does the app should crash so we know
            cell.contentLabel.text = temperatureUnit.stringValue
            if temperatureUnit.stringValue == WeatherDataService.shared.temperatureUnit.stringValue {
                cell.accessoryType = .checkmark
            }
            return cell
        case 4:
            let windspeedUnit = SpeedUnitWrappedEnum(rawValue: indexPath.row)! // force unwrap -> this should never fail, if it does the app should crash so we know
            cell.contentLabel.text = windspeedUnit.stringValue
            if windspeedUnit.stringValue == WeatherDataService.shared.windspeedUnit.stringValue {
                cell.accessoryType = .checkmark
            }
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
