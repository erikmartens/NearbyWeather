//
//  ListViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 20.10.17.
//  Copyright © 2017 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import MapKit
import RxFlow
import RxCocoa

final class ListViewController: UITableViewController, Stepper {
  
  private lazy var listTypeBarButton = {
    UIBarButtonItem(
      image: R.image.layerType(),
      style: .plain, target: self,
      action: #selector(Self.listTypeBarButtonTapped(_:))
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
  
  private lazy var sortBarButton = {
    UIBarButtonItem(
      image: R.image.sort(),
      style: .plain, target: self,
      action: #selector(Self.sortBarButtonTapped(_:))
    )
  }()
  
  // MARK: - Routing
  
  var steps = PublishRelay<Step>()
  
  // MARK: - ViewController Lifecycle
  
  override init(style: UITableView.Style) {
    super.init(style: style)
    tableView.separatorStyle = .none
    
    tableView.register(UINib(nibName: R.nib.weatherDataCell.name, bundle: R.nib.weatherDataCell.bundle),
                       forCellReuseIdentifier: R.reuseIdentifier.weatherDataCell.identifier)
    
    tableView.register(UINib(nibName: R.nib.alertCell.name, bundle: R.nib.alertCell.bundle),
                       forCellReuseIdentifier: R.reuseIdentifier.alertCell.identifier)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    refreshControl = UIRefreshControl()
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(Self.reconfigureOnWeatherDataServiceDidUpdate),
      name: Notification.Name(rawValue: Constants.Keys.NotificationCenter.kWeatherServiceDidUpdate),
      object: nil
    )
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    configure()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if UserDefaults.standard.value(forKey: Constants.Keys.UserDefaults.kIsInitialLaunch) == nil {
      UserDefaults.standard.set(false, forKey: Constants.Keys.UserDefaults.kIsInitialLaunch)
      updateWeatherData()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    refreshControl?.endRefreshing()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

private extension ListViewController {
  
  // MARK: - Private Helpers
  
  private func configure() {
    configureNavigationTitle()
    configureLastRefreshDate()
    configureButtons()
    
    refreshControl?.addTarget(self, action: #selector(Self.updateWeatherData), for: .valueChanged)
  }
  
  @objc private func reconfigureOnWeatherDataServiceDidUpdate() {
    refreshControl?.endRefreshing()
    configureLastRefreshDate()
    configureButtons()
    tableView.reloadData()
  }
  
  private func configureLastRefreshDate() {
    guard let lastRefreshDate = UserDefaults.standard.object(forKey: Constants.Keys.UserDefaults.kWeatherDataLastRefreshDateKey) as? Date else {
      tableView.refreshControl?.attributedTitle = nil
      return
    }
    tableView.refreshControl?.attributedTitle = NSAttributedString(string:
      R.string.localizable.last_refresh_at(lastRefreshDate.shortDateTimeString)
    )
  }
  
  private func configureButtons() {
    guard WeatherInformationService.shared.hasDisplayableData else {
      navigationItem.leftBarButtonItem = nil
      navigationItem.rightBarButtonItems = nil
      return
    }
    navigationItem.leftBarButtonItem = listTypeBarButton
    
    guard WeatherInformationService.shared.hasDisplayableWeatherData else {
      navigationItem.rightBarButtonItems = nil
      return
    }
    
    switch PreferencesDataService.shared.preferredListType {
    case .bookmarked:
      navigationItem.rightBarButtonItems = nil
    case .nearby:
      navigationItem.rightBarButtonItems = [sortBarButton, numberOfResultsBarButton]
    }
  }
  
  func configureNavigationTitle() {
    switch PreferencesDataService.shared.preferredListType {
    case .bookmarked:
      navigationItem.title = R.string.localizable.bookmarks()
    case .nearby:
      navigationItem.title = R.string.localizable.nearby()
    }
  }
  
  @objc private func updateWeatherData() {
    refreshControl?.beginRefreshing()
    WeatherInformationService.shared.update(withCompletionHandler: nil)
  }
}

// MARK: - IBActions

private extension ListViewController {
  
  @objc func listTypeBarButtonTapped(_ sender: UIBarButtonItem) {
    let alert = Factory.AlertController.make(fromType:
      .weatherListType(currentListType: PreferencesDataService.shared.preferredListType, completionHandler: { [weak self] selectedListType in
        PreferencesDataService.shared.preferredListType = selectedListType
        self?.configureNavigationTitle()
        self?.tableView.reloadData()
        self?.configureButtons()
      })
    )
    present(alert, animated: true, completion: nil)
  }
  
  @objc func numberOfResultsBarButtonTapped(_ sender: UIBarButtonItem) {
    let alert = Factory.AlertController.make(fromType:
      .preferredAmountOfResultsOptions(options: AmountOfResultsOption.availableOptions, completionHandler: { [weak self] changed in
        guard changed else { return }
        self?.tableView.reloadData()
        self?.configureButtons()
      })
    )
    present(alert, animated: true, completion: nil)
  }
  
  @objc func sortBarButtonTapped(_ sender: UIBarButtonItem) {
    let alert = Factory.AlertController.make(fromType:
      .preferredSortingOrientationOptions(options: SortingOrientationOption.availableOptions, completionHandler: { [weak self] changed in
        if changed { self?.tableView.reloadData() }
      })
    )
    present(alert, animated: true, completion: nil)
  }
}

// MARK: - UITableViewDelegate

extension ListViewController {
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    UITableView.automaticDimension
  }
  
  override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    CGFloat(100)
  }
}

// MARK: - UITableViewDataSource

extension ListViewController {
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard !WeatherInformationService.shared.apiKeyUnauthorized else {
      return 1
    }
    switch PreferencesDataService.shared.preferredListType {
    case .bookmarked:
      let numberOfRows = WeatherInformationService.shared.bookmarkedWeatherDataObjects?.count ?? 1
      return numberOfRows > 0 ? numberOfRows : 1
    case .nearby:
      guard UserLocationService.shared.locationPermissionsGranted else {
        return 1
      }
      let numberOfRows = WeatherInformationService.shared.nearbyWeatherDataObject?.weatherInformationDTOs?.count ?? 1
      return numberOfRows > 0 ? numberOfRows : 1
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let weatherCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.weatherDataCell.identifier, for: indexPath) as! WeatherDataCell
    let alertCell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.alertCell.identifier, for: indexPath) as! AlertCell
    
    [weatherCell, alertCell].forEach {
      $0.backgroundColor = .clear
      $0.selectionStyle = .none
    }
    
    if WeatherInformationService.shared.apiKeyUnauthorized {
      let errorDataDTO = (WeatherInformationService.shared.bookmarkedWeatherDataObjects?.first { $0.errorDataDTO != nil})?.errorDataDTO ?? WeatherInformationService.shared.nearbyWeatherDataObject?.errorDataDTO
      alertCell.configureWithErrorDataDTO(errorDataDTO)
      return alertCell
    }
    
    switch PreferencesDataService.shared.preferredListType {
    case .bookmarked:
      guard let bookmarkedWeatherDataObjects = WeatherInformationService.shared.bookmarkedWeatherDataObjects,
        !bookmarkedWeatherDataObjects.isEmpty else {
          alertCell.configure(with: R.string.localizable.empty_bookmarks_message())
          return alertCell
      }
      guard let weatherDTO = bookmarkedWeatherDataObjects[indexPath.row].weatherInformationDTO else {
        alertCell.configureWithErrorDataDTO(WeatherInformationService.shared.bookmarkedWeatherDataObjects?[indexPath.row].errorDataDTO)
        return alertCell
      }
      weatherCell.configureWithWeatherDTO(weatherDTO, isBookmark: true)
      return weatherCell
    case .nearby:
      if !UserLocationService.shared.locationPermissionsGranted {
        let errorDataDTO = WeatherInformationErrorDTO(errorType: WeatherInformationErrorDTO.ErrorType(value: .locationAccessDenied), httpStatusCode: nil)
        alertCell.configureWithErrorDataDTO(errorDataDTO)
        return alertCell
      }
      guard let nearbyWeatherDataObject = WeatherInformationService.shared.nearbyWeatherDataObject else {
        alertCell.configure(with: R.string.localizable.empty_nearby_locations_message())
        return alertCell
      }
      guard let weatherDTO = nearbyWeatherDataObject.weatherInformationDTOs?[indexPath.row] else {
        alertCell.configureWithErrorDataDTO(WeatherInformationService.shared.nearbyWeatherDataObject?.errorDataDTO)
        return alertCell
      }
      weatherCell.configureWithWeatherDTO(weatherDTO, isBookmark: false)
      return weatherCell
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard WeatherInformationService.shared.hasDisplayableData else {
      return
    }
    
    tableView.deselectRow(at: indexPath, animated: true)
    
    guard let selectedCell = tableView.cellForRow(at: indexPath) as? WeatherDataCell else {
      return
    }
    steps.accept(
      ListStep.weatherDetails(
        identifier: selectedCell.weatherDataIdentifier,
        isBookmark: selectedCell.isBookmark
      )
    )
  }
}
