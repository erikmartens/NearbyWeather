//
//  WeatherDetailViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.02.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxFlow
import RxCocoa
import MapKit
import APTimeZones

extension WeatherDetailViewController {
  static func instantiateFromStoryBoard(weatherDTO: WeatherInformationDTO, isBookmark: Bool) -> WeatherDetailViewController {
    let viewController = R.storyboard.weatherDetail.weatherDetailViewController()!
    viewController.titleString = weatherDTO.cityName
    viewController.weatherDTO = weatherDTO
    viewController.isBookmark = isBookmark
    return viewController
  }
}

final class WeatherDetailViewController: UIViewController, Stepper {

  // MARK: - Routing

  var steps = PublishRelay<Step>()

  // MARK: - Properties

  /* Injected */

  private var titleString: String!
  private var weatherDTO: WeatherInformationDTO!
  private var isBookmark: Bool!

  /* Outlets */

  @IBOutlet weak var conditionSymbolLabel: UILabel!
  @IBOutlet weak var conditionNameLabel: UILabel!
  @IBOutlet weak var conditionDescriptionLabel: UILabel!
  @IBOutlet weak var temperatureLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!

  @IBOutlet weak var daytimeStackView: UIStackView!
  @IBOutlet weak var sunriseImageView: UIImageView!
  @IBOutlet weak var sunriseNoteLabel: UILabel!
  @IBOutlet weak var sunriseLabel: UILabel!
  @IBOutlet weak var sunsetImageView: UIImageView!
  @IBOutlet weak var sunsetNoteLabel: UILabel!
  @IBOutlet weak var sunsetLabel: UILabel!

  @IBOutlet weak var cloudCoverImageView: UIImageView!
  @IBOutlet weak var cloudCoverNoteLabel: UILabel!
  @IBOutlet weak var cloudCoverLabel: UILabel!
  @IBOutlet weak var humidityImageView: UIImageView!
  @IBOutlet weak var humidityNoteLabel: UILabel!
  @IBOutlet weak var humidityLabel: UILabel!
  @IBOutlet weak var pressureImageView: UIImageView!
  @IBOutlet weak var pressureNoteLabel: UILabel!
  @IBOutlet weak var pressureLabel: UILabel!

  @IBOutlet weak var windSpeedStackView: UIStackView!
  @IBOutlet weak var windSpeedImageView: UIImageView!
  @IBOutlet weak var windSpeedNoteLabel: UILabel!
  @IBOutlet weak var windSpeedLabel: UILabel!
  @IBOutlet weak var windDirectionStackView: UIStackView!
  @IBOutlet weak var windDirectionImageView: UIImageView!
  @IBOutlet weak var windDirectionNoteLabel: UILabel!
  @IBOutlet weak var windDirectionLabel: UILabel!

  @IBOutlet weak var locationStackView: UIStackView!
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var coordinatesImageView: UIImageView!
  @IBOutlet weak var coordinatesNoteLabel: UILabel!
  @IBOutlet weak var coordinatesLabel: UILabel!
  @IBOutlet weak var distanceStackView: UIStackView!
  @IBOutlet weak var distanceImageView: UIImageView!
  @IBOutlet weak var distanceNoteLabel: UILabel!
  @IBOutlet weak var distanceLabel: UILabel!

  @IBOutlet var separatorLineHeightConstraints: [NSLayoutConstraint]!

  // MARK: - ViewController Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    title = titleString

    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: R.image.verticalCloseButton(),
      style: .plain,
      target: self,
      action: #selector(Self.dismissButtonTapped))

    mapView.delegate = self
    mapView.mapType = PreferencesDataService.shared.preferredMapType

    configureMap()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    configure()
  }

  // MARK: - Private Helpers

  private func configure() {

    let isDayTime = ConversionWorker.isDayTime(for: weatherDTO.daytimeInformation, coordinates: weatherDTO.coordinates) ?? true

    var navigationBarTintColor: UIColor
    var navigationTintColor: UIColor
    if isBookmark {
      navigationBarTintColor = isDayTime ? Constants.Theme.Color.MarqueColors.standardDay : Constants.Theme.Color.MarqueColors.standardNight
      navigationTintColor = .white
    } else {
      navigationBarTintColor = .white
      navigationTintColor = .black
    }

    navigationController?.navigationBar.style(withBarTintColor: navigationBarTintColor, tintColor: navigationTintColor)

    separatorLineHeightConstraints.forEach { $0.constant = 1/UIScreen.main.scale }

    conditionSymbolLabel.text = ConversionWorker.weatherConditionSymbol(
      fromWeatherCode: weatherDTO.weatherCondition[0].identifier,
      isDayTime: isDayTime
    )
    conditionNameLabel.text = weatherDTO.weatherCondition.first?.conditionName
    conditionDescriptionLabel.text = weatherDTO.weatherCondition.first?.conditionDescription?.capitalized

    if let temperatureKelvin = weatherDTO.atmosphericInformation.temperatureKelvin {
      let temperatureUnit = PreferencesDataService.shared.temperatureUnit
      temperatureLabel.text = ConversionWorker.temperatureDescriptor(forTemperatureUnit: temperatureUnit, fromRawTemperature: temperatureKelvin)
    } else {
      temperatureLabel.text = nil
    }

    if let sunriseTimeSinceReferenceDate = weatherDTO.daytimeInformation.sunrise,
      let sunsetTimeSinceReferenceDate = weatherDTO.daytimeInformation.sunset,
      let latitude = weatherDTO.coordinates.latitude,
      let longitude = weatherDTO.coordinates.longitude {
      let sunriseDate = Date(timeIntervalSince1970: sunriseTimeSinceReferenceDate)
      let sunsetDate = Date(timeIntervalSince1970: sunsetTimeSinceReferenceDate)

      let location = CLLocation(latitude: latitude, longitude: longitude)

      let dateFormatter = DateFormatter()
      dateFormatter.calendar = .current
      dateFormatter.timeZone = location.timeZone()
      dateFormatter.dateStyle = .none
      dateFormatter.timeStyle = .short

      let description = isDayTime ? R.string.localizable.dayTime() : R.string.localizable.nightTime()
      let localTime = dateFormatter.string(from: Date())
      timeLabel.text = ""
        .append(contentsOf: description, delimiter: .none)
        .append(contentsOf: localTime, delimiter: .space)

      sunriseImageView.tintColor = .darkGray
      sunriseNoteLabel.text = R.string.localizable.sunrise()
      sunriseLabel.text = dateFormatter.string(from: sunriseDate)

      sunsetImageView.tintColor = .darkGray
      sunsetNoteLabel.text = R.string.localizable.sunset()
      sunsetLabel.text = dateFormatter.string(from: sunsetDate)
    } else {
      daytimeStackView.isHidden = true
      timeLabel.isHidden = true
    }

    cloudCoverImageView.tintColor = .darkGray
    cloudCoverNoteLabel.text = R.string.localizable.cloud_coverage()
    cloudCoverLabel.text = weatherDTO.cloudCoverage.coverage?.append(contentsOf: "%", delimiter: .none)
    humidityImageView.tintColor = .darkGray
    humidityNoteLabel.text = R.string.localizable.humidity()
    humidityLabel.text = weatherDTO.atmosphericInformation.humidity?.append(contentsOf: "%", delimiter: .none)
    pressureImageView.tintColor = .darkGray
    pressureNoteLabel.text = R.string.localizable.air_pressure()
    pressureLabel.text = weatherDTO.atmosphericInformation.pressurePsi?.append(contentsOf: "hpa", delimiter: .space)

    windSpeedImageView.tintColor = .darkGray
    windSpeedNoteLabel.text = R.string.localizable.windspeed()

    if let windspeed = weatherDTO.windInformation.windspeed {
      windSpeedLabel.text = ConversionWorker.windspeedDescriptor(
        forDistanceSpeedUnit: PreferencesDataService.shared.distanceSpeedUnit,
        forWindspeed: windspeed
      )
    } else {
      windSpeedStackView.isHidden = true
    }

    if let windDirection = weatherDTO.windInformation.degrees {
      windDirectionImageView.transform = CGAffineTransform(rotationAngle: CGFloat(windDirection)*0.0174532925199) // convert to radians
      windDirectionImageView.tintColor = .darkGray
      windDirectionNoteLabel.text = R.string.localizable.wind_direction()
      windDirectionLabel.text = ConversionWorker.windDirectionDescriptor(forWindDirection: windDirection)
    } else {
      windDirectionStackView.isHidden = true
    }
  }

  private func configureMap() {
    guard let weatherLatitude = weatherDTO.coordinates.latitude,
      let weatherLongitude = weatherDTO.coordinates.longitude else {
        locationStackView.isHidden = true
        return
    }

    // mapView
    if let mapAnnotation = WeatherLocationMapAnnotation(weatherDTO: weatherDTO, isBookmark: isBookmark) {
      mapView.layer.cornerRadius = 10
      mapView.addAnnotation(mapAnnotation)
      let location = CLLocation(latitude: weatherLatitude, longitude: weatherLongitude)
      let region = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
      mapView.setRegion(region, animated: false)
    } else {
      mapView.isHidden = true
    }

    // coordinates
    coordinatesImageView.tintColor = .darkGray
    coordinatesNoteLabel.text = R.string.localizable.coordinates()
    coordinatesLabel.text = ""
      .append(contentsOfConvertible: weatherDTO.coordinates.latitude, delimiter: .none)
      .append(contentsOfConvertible: weatherDTO.coordinates.longitude, delimiter: .comma)

    // distance
    if UserLocationService.shared.locationPermissionsGranted,
      let userLocation = UserLocationService.shared.location,
      let weatherLatitude = weatherDTO.coordinates.latitude,
      let weatherLongitude = weatherDTO.coordinates.longitude {
      let location = CLLocation(latitude: weatherLatitude, longitude: weatherLongitude)
      let distanceInMetres = location.distance(from: userLocation)

      let distanceSpeedUnit = PreferencesDataService.shared.distanceSpeedUnit
      let distanceString = ConversionWorker.distanceDescriptor(forDistanceSpeedUnit: distanceSpeedUnit, forDistanceInMetres: distanceInMetres)

      distanceImageView.tintColor = .darkGray
      distanceNoteLabel.text = R.string.localizable.distance()
      distanceLabel.text = distanceString
    } else {
      distanceStackView.isHidden = true
    }
  }

  // MARK: - IBActions

  @IBAction func openWeatherMapButtonPressed(_ sender: UIButton) {
    presentSafariViewController(for:
      Constants.Urls.kOpenWeatherMapCityDetailsUrl(forCityWithName: weatherDTO.cityName)
    )
  }

  @objc private func dismissButtonTapped(_ sender: UIBarButtonItem) {
    steps.accept(WeatherDetailStep.dismiss)
  }
}

extension WeatherDetailViewController: MKMapViewDelegate {

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard let annotation = annotation as? WeatherLocationMapAnnotation else {
      return nil
    }

    var viewForCurrentAnnotation: WeatherLocationMapAnnotationView?
    if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.Keys.MapAnnotation.kMapAnnotationViewIdentifier) as? WeatherLocationMapAnnotationView {
      viewForCurrentAnnotation = dequeuedAnnotationView
    } else {
      viewForCurrentAnnotation = WeatherLocationMapAnnotationView(frame: kMapAnnotationViewInitialFrame)
    }

    var fillColor: UIColor
    var textColor: UIColor

    if annotation.isBookmark {
      fillColor = annotation.isDayTime ?? true
        ? Constants.Theme.Color.MarqueColors.standardDay
        : Constants.Theme.Color.MarqueColors.standardNight // default to blue colored cells

      textColor = .white
    } else {
      fillColor = .white
      textColor = .black
    }

    viewForCurrentAnnotation?.annotation = annotation
    viewForCurrentAnnotation?.configure(
      withTitle: annotation.title ?? Constants.Messages.kNotSet,
      subtitle: annotation.subtitle ?? Constants.Messages.kNotSet,
      fillColor: fillColor,
      textColor: textColor,
      tapHandler: nil
    )
    return viewForCurrentAnnotation
  }
}
