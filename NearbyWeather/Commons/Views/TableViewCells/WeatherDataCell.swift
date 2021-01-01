//
//  WeatherDataCell.swift
//  SimpleWeather
//
//  Created by Erik Maximilian Martens on 03.12.16.
//  Copyright © 2016 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class WeatherDataCell: UITableViewCell {

  var weatherDataIdentifier: Int!
  var isBookmark: Bool!

  @IBOutlet weak var backgroundColorView: UIView!
  @IBOutlet weak var weatherConditionLabel: UILabel!
  @IBOutlet weak var cityNameLabel: UILabel!

  @IBOutlet weak var temperatureImageView: UIImageView!
  @IBOutlet weak var temperatureLabel: UILabel!

  @IBOutlet weak var cloudCoverImageView: UIImageView!
  @IBOutlet weak var cloudCoverageLabel: UILabel!

  @IBOutlet weak var humidityImageView: UIImageView!
  @IBOutlet weak var humidityLabel: UILabel!

  @IBOutlet weak var windSpeedImageView: UIImageView!
  @IBOutlet weak var windspeedLabel: UILabel!

  func configureWithWeatherDTO(_ weatherDTO: WeatherInformationDTO, isBookmark: Bool) {
    self.weatherDataIdentifier = weatherDTO.cityID
    self.isBookmark = isBookmark

    var bubbleColor: UIColor
    var textColor: UIColor
    var borderWidth: CGFloat

    switch isBookmark {
    case true:
      bubbleColor = ConversionWorker.isDayTime(for: weatherDTO.daytimeInformation, coordinates: weatherDTO.coordinates) ?? true
        ? Constants.Theme.Color.MarqueColors.standardDay
        : Constants.Theme.Color.MarqueColors.standardNight // default to blue colored cells

      textColor = .white
      borderWidth = 0
    case false:
      bubbleColor = .white
      textColor = .black
      borderWidth = 1/UIScreen.main.scale
    }

    backgroundColorView.layer.cornerRadius = 5.0
    backgroundColorView.layer.borderColor = textColor.cgColor
    backgroundColorView.layer.borderWidth = borderWidth
    backgroundColorView.layer.backgroundColor = bubbleColor.cgColor

    cityNameLabel.textColor = textColor
    cityNameLabel.font = .preferredFont(forTextStyle: .headline)

    temperatureImageView.tintColor = textColor
    temperatureLabel.textColor = textColor
    temperatureLabel.font = .preferredFont(forTextStyle: .subheadline)

    cloudCoverImageView.tintColor = textColor
    cloudCoverageLabel.textColor = textColor
    cloudCoverageLabel.font = .preferredFont(forTextStyle: .subheadline)

    humidityImageView.tintColor = textColor
    humidityLabel.textColor = textColor
    humidityLabel.font = .preferredFont(forTextStyle: .subheadline)

    windSpeedImageView.tintColor = textColor
    windspeedLabel.textColor = textColor
    windspeedLabel.font = .preferredFont(forTextStyle: .subheadline)

    let weatherConditionSymbol = ConversionWorker.weatherConditionSymbol(
      fromWeatherCode: weatherDTO.weatherCondition[safe: 0]?.identifier,
      isDayTime: ConversionWorker.isDayTime(for: weatherDTO.daytimeInformation, coordinates: weatherDTO.coordinates) ?? true
    )
    weatherConditionLabel.text = weatherConditionSymbol

    cityNameLabel.text = weatherDTO.cityName

    if let temperatureKelvin = weatherDTO.atmosphericInformation.temperatureKelvin {
      temperatureLabel.text = ConversionWorker.temperatureDescriptor(
        forTemperatureUnit: PreferencesDataService.shared.temperatureUnit,
        fromRawTemperature: temperatureKelvin
      )
    } else {
      temperatureLabel.text = nil
    }

    cloudCoverageLabel.text = weatherDTO.cloudCoverage.coverage?.append(contentsOf: "%", delimiter: .none)

    humidityLabel.text = weatherDTO.atmosphericInformation.humidity?.append(contentsOf: "%", delimiter: .none)

    if let windspeed = weatherDTO.windInformation.windspeed {
      windspeedLabel.text = ConversionWorker.windspeedDescriptor(
        forDistanceSpeedUnit: PreferencesDataService.shared.distanceSpeedUnit,
        forWindspeed: windspeed
      )
    } else {
      windspeedLabel.text = nil
    }
  }
}
