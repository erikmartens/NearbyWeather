//
//  NearbyLocationsMapViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 22.01.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import MapKit
import RxFlow
import RxCocoa

final class MapViewController: UIViewController, Stepper {

  private lazy var mapTypeBarButton = {
    UIBarButtonItem(
      image: R.image.layerType(),
      style: .plain, target: self,
      action: #selector(Self.mapTypeBarButtonTapped(_:))
    )
  }()

  private var numberOfResultsBarButton: UIBarButtonItem {
    let image = PreferencesDataService.shared.amountOfResults.imageValue

    return UIBarButtonItem(
      image: image,
      style: .plain, target: self,
      action: #selector(Self.numberOfResultsBarButtonTapped(_:))
    )
  }

  private lazy var focusOnLocationBarButton = {
    UIBarButtonItem(
      image: R.image.marker(),
      style: .plain, target: self,
      action: #selector(Self.focusLocationButtonTapped(_:))
    )
  }()

  // MARK: - Routing

  var steps = PublishRelay<Step>()

  // MARK: - IBOutlets

  private var mapView: MKMapView!

  // MARK: - Properties

  var weatherLocationMapAnnotations: [WeatherLocationMapAnnotation]!

  private var selectedBookmarkedLocation: WeatherInformationDTO?
  private var previousRegion: MKCoordinateRegion?

  // MARK: - ViewController Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    title = R.string.localizable.tab_weatherMap()

    configureMapView()
    configureButtons()
    configureMapAnnotations()

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(Self.reconfigureOnWeatherDataServiceDidUpdate),
      name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kWeatherServiceDidUpdate),
      object: nil
    )
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    selectedBookmarkedLocation = WeatherInformationService.shared.bookmarkedWeatherDataObjects?.first?.weatherInformationDTO

    focusOnAvailableLocation()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

// MARK: - Private Helpers

private extension MapViewController {

  func configureMapAnnotations() {
    // remove previous annotations
    mapView.annotations.forEach { mapView.removeAnnotation($0) }

    // calculate current annotations
    weatherLocationMapAnnotations = [WeatherLocationMapAnnotation]()

    let bookmarkedLocationAnnotations: [WeatherLocationMapAnnotation]? = WeatherInformationService.shared.bookmarkedWeatherDataObjects?.compactMap {
      guard let weatherDTO = $0.weatherInformationDTO else { return nil }
      return WeatherLocationMapAnnotation(weatherDTO: weatherDTO, isBookmark: true)
    }
    weatherLocationMapAnnotations.append(contentsOf: bookmarkedLocationAnnotations ?? [WeatherLocationMapAnnotation]())

    let nearbyocationAnnotations = WeatherInformationService.shared.nearbyWeatherDataObject?.weatherInformationDTOs?.compactMap {
      return WeatherLocationMapAnnotation(weatherDTO: $0, isBookmark: false)
    }
    weatherLocationMapAnnotations.append(contentsOf: nearbyocationAnnotations ?? [WeatherLocationMapAnnotation]())

    // add current annotations
    mapView.addAnnotations(weatherLocationMapAnnotations)
  }

  func focusMapOnUserLocation() {
    if UserLocationService.shared.locationPermissionsGranted, let currentLocation = UserLocationService.shared.currentLocation {
      let region = MKCoordinateRegion.init(center: currentLocation.coordinate, latitudinalMeters: 15000, longitudinalMeters: 15000)
      mapView.setRegion(region, animated: true)
    }
  }

  func focusMapOnSelectedBookmarkedLocation() {
    guard let selectedLocation = selectedBookmarkedLocation,
      let latitude = selectedLocation.coordinates.latitude,
      let longitude = selectedLocation.coordinates.longitude else {
        return
    }
    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 15000, longitudinalMeters: 15000)
    mapView.setRegion(region, animated: true)
  }

  func focusOnAvailableLocation() {
    if let previousRegion = previousRegion {
      mapView.setRegion(previousRegion, animated: true)
      return
    }
    guard UserLocationService.shared.locationPermissionsGranted, UserLocationService.shared.currentLocation != nil else {
      focusMapOnSelectedBookmarkedLocation()
      return
    }
    focusMapOnUserLocation()
  }

  func configureMapView() {
    mapView = MKMapView()

    mapView.delegate = self
    mapView.mapType = PreferencesDataService.shared.preferredMapType

    view.addSubview(mapView, constraints: [
      mapView.topAnchor.constraint(equalTo: view.topAnchor),
      mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
  }

  func configureButtons() {
    navigationItem.leftBarButtonItem = mapTypeBarButton

    guard WeatherInformationService.shared.hasDisplayableWeatherData else {
      navigationItem.rightBarButtonItems = nil
      return
    }

    navigationItem.rightBarButtonItems = [focusOnLocationBarButton, numberOfResultsBarButton]
  }
}

// MARK: - Target Functions

private extension MapViewController {

  @objc func mapTypeBarButtonTapped(_ sender: UIBarButtonItem) {
    let alert = Factory.AlertController.make(fromType:
      .weatherMapType(currentMapType: PreferencesDataService.shared.preferredMapType, completionHandler: { [weak self] mapType in
        DispatchQueue.main.async {
          PreferencesDataService.shared.preferredMapType = mapType
          self?.mapView.mapType = PreferencesDataService.shared.preferredMapType
        }
      })
    )
    present(alert, animated: true, completion: nil)
  }

  @objc func numberOfResultsBarButtonTapped(_ sender: UIBarButtonItem) {
    let alert = Factory.AlertController.make(fromType:
      .preferredAmountOfResultsOptions(options: AmountOfResultsOption.availableOptions, completionHandler: { [weak self] changed in
        guard changed else { return }
        self?.configureButtons()
      })
    )
    present(alert, animated: true, completion: nil)
  }

  @objc func focusLocationButtonTapped(_ sender: UIBarButtonItem) {
    guard let bookmarkedWeatherDataObjects = WeatherInformationService.shared.bookmarkedWeatherDataObjects?.compactMap({
      return $0.weatherInformationDTO
    }) else {
      return
    }

    let alert = Factory.AlertController.make(fromType:
      .focusMapOnLocation(bookmarks: bookmarkedWeatherDataObjects,
                          completionHandler: { [weak self] weatherInformationDTO in
                            guard let weatherInformationDTO = weatherInformationDTO else {
                              self?.focusMapOnUserLocation()
                              return
                            }
                            self?.selectedBookmarkedLocation = weatherInformationDTO
                            DispatchQueue.main.async {
                              self?.focusMapOnSelectedBookmarkedLocation()
                            }
      })
    )
    present(alert, animated: true, completion: nil)
  }

  @objc private func reconfigureOnWeatherDataServiceDidUpdate() {
    configureMapAnnotations()
    configureButtons()
  }
}

extension MapViewController: MKMapViewDelegate {

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
      tapHandler: { [weak self] _ in
        self?.previousRegion = mapView.region
        self?.steps.accept(MapStep.weatherDetails(
            identifier: annotation.locationId,
            isBookmark: annotation.isBookmark
        ))
      }
    )
    return viewForCurrentAnnotation
  }
}
