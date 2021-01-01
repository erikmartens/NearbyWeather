//
//  WeatherLocationManagementTableViewController.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 24.02.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxFlow
import RxCocoa

final class WeatherLocationManagementTableViewController: UITableViewController, Stepper {
  
  // MARK: - Routing
  
  var steps = PublishRelay<Step>()
  
  // MARK: - Properties
  
  private var editingEnabled: Bool {
    return WeatherInformationService.shared.bookmarkedLocations.count > 1
  }
  
  // MARK: - ViewController LifeCycle
  
  override init(style: UITableView.Style) {
    super.init(style: style)
    
    tableView.register(UINib(nibName: R.nib.singleLabelCell.name, bundle: R.nib.singleLabelCell.bundle),
    forCellReuseIdentifier: R.reuseIdentifier.singleLabelCell.identifier)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = R.string.localizable.manage_locations()
    tableView.isEditing = true
  }
  
  // MARK: - TableViewDelegate
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return WeatherInformationService.shared.bookmarkedLocations.count
    default:
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.singleLabelCell.identifier, for: indexPath) as! SingleLabelCell
      let location = WeatherInformationService.shared.bookmarkedLocations[indexPath.row]
      cell.contentLabel.text = location.name.append(contentsOf: location.country, delimiter: .comma)
      cell.selectionStyle = .none
      return cell
    default:
      return UITableViewCell()
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    true
  }
  
  override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
    false
  }
  
  override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
    defer {
      tableView.reloadData()
    }
    
    if editingStyle == .delete {
      guard editingEnabled else {
        presentLastBookmarkDeletionAlert()
        return
      }
      WeatherInformationService.shared.bookmarkedLocations.remove(at: indexPath.row)
    }
  }
  
  override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    let movedLocation = WeatherInformationService.shared.bookmarkedLocations[sourceIndexPath.row]
    WeatherInformationService.shared.bookmarkedLocations.remove(at: sourceIndexPath.row)
    WeatherInformationService.shared.bookmarkedLocations.insert(movedLocation, at: destinationIndexPath.row)
  }
  
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    tableView.reloadData()
  }
  
  // MARK: - Private Helpers
  
  private func presentLastBookmarkDeletionAlert() {
    let alert = Factory.AlertController.make(fromType:
      .dimissableNotice(title: R.string.localizable.delete_last_bookmark_title(),
                        message: R.string.localizable.delete_last_bookmark_message())
    )
    present(alert, animated: true, completion: nil)
  }
}
