//
//  OWMCityFilterTableViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 07.01.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxFlow
import RxCocoa
import PKHUD

final class WeatherLocationSelectionTableViewController: UITableViewController, Stepper {
  
  // MARK: - Routing
  
  var steps = PublishRelay<Step>()
  
  // MARK: - Properties

  private var filteredCities = [WeatherStationDTO]() {
    didSet {
      DispatchQueue.main.async { [weak self] in
        self?.tableView.reloadData()
      }
    }
  }
  
  // MARK: - ViewController Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = R.string.localizable.add_location()
    
    tableView.delegate = self
    tableView.register(UINib(nibName: R.nib.subtitleCell.name, bundle: R.nib.subtitleCell.bundle),
                       forCellReuseIdentifier: R.reuseIdentifier.subtitleCell.identifier)
    
    let searchController = UISearchController(searchResultsController: nil)
    searchController.delegate = self
    searchController.searchResultsUpdater = self
    searchController.searchBar.placeholder = R.string.localizable.search_by_name()
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.dimsBackgroundDuringPresentation = false
    
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    
    tableView.contentInset = UIEdgeInsets(
      top: Constants.Dimensions.TableCellContentInsets.top,
      left: .zero,
      bottom: Constants.Dimensions.TableCellContentInsets.bottom,
      right: .zero
    )
    
    definesPresentationContext = true
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    DispatchQueue.main.async {
      self.navigationItem.searchController?.searchBar.becomeFirstResponder()
    }
  }
  
  // MARK: - TableViewDataSource
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    filteredCities.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.subtitleCell.identifier, for: indexPath) as! SubtitleCell
    
    var usStateName: String?
    if let usStateCode = filteredCities[indexPath.row].state {
      usStateName = ConversionWorker.usStateName(for: usStateCode)
    }
    
    cell.contentLabel.text = filteredCities[indexPath.row].name
    cell.subtitleLabel.text = ""
      .append(contentsOf: usStateName, delimiter: .none) // only US states have state codes attached
      .append(contentsOf: ConversionWorker.countryName(for: filteredCities[indexPath.row].country), delimiter: .comma)
    return cell
  }
  
  // MARK: - TableViewDelegate
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    WeatherInformationService.shared.bookmarkedLocations.append(filteredCities[indexPath.row])
    HUD.flash(.success, delay: 1.0)
    navigationController?.popViewController(animated: true)
  }
}

extension WeatherLocationSelectionTableViewController: UISearchResultsUpdating {
  
  func updateSearchResults(for searchController: UISearchController) {
    guard let searchText = navigationItem.searchController?.searchBar.text else {
      filteredCities = [WeatherStationDTO]()
      tableView.reloadData()
      return
    }
    WeatherStationService.shared.locations(forSearchString: searchText, completionHandler: { [weak self] weatherLocationDTOs in
      if let weatherLocationDTOs = weatherLocationDTOs {
        self?.filteredCities = weatherLocationDTOs
      }
    })
  }
}

extension WeatherLocationSelectionTableViewController: UISearchControllerDelegate {
  
  func didDismissSearchController(_ searchController: UISearchController) {
    filteredCities = [WeatherStationDTO]()
    tableView.reloadData()
  }
}
