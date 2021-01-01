//
//  WeatherListTableViewCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 04.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

private extension WeatherListInformationTableViewCell {
  
  struct Definitions {
    static let cellLeadingInset: CGFloat = 48
    static let weatherConditionSymbolHeight: CGFloat = 80
  }
}

final class WeatherListInformationTableViewCell: UITableViewCell, BaseCell, ReuseIdentifiable {
  
  typealias CellViewModel = WeatherListInformationTableViewCellViewModel
  
  // MARK: - UIComponents
  
  private lazy var backgroundColorView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = Constants.Dimensions.Size.CornerRadiusSize.from(weight: .medium)
    return view
  }()
  
  private lazy var weatherConditionSymbolLabel = Factory.Label.make(fromType: .weatherSymbol)
  private lazy var placeNameLabel = Factory.Label.make(fromType: .title(numberOfLines: 1))
  private lazy var temperatureSymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.temperature()))
  private lazy var temperatureLabel = Factory.Label.make(fromType: .body(numberOfLines: 1))
  private lazy var cloudCoverageSymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.cloudCoverFilled()))
  private lazy var cloudCoverageLabel = Factory.Label.make(fromType: .body(alignment: .right, numberOfLines: 1))
  private lazy var humiditySymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.humidity()))
  private lazy var humidityLabel = Factory.Label.make(fromType: .body(numberOfLines: 1))
  private lazy var windspeedSymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.windSpeed()))
  private lazy var windspeedLabel = Factory.Label.make(fromType: .body(alignment: .right, numberOfLines: 1))
  
  // MARK: - Assets
  
  private var disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  private var cellViewModel: CellViewModel?
  
  // MARK: - Initialization
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    layoutUserInterface()
    setupAppearance()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Cell Life Cycle
  
  func configure(with cellViewModel: CellViewModel) {
    self.cellViewModel = cellViewModel
    bindInputFromViewModel(cellViewModel)
    bindOutputToViewModel(cellViewModel)
  }
}

// MARK: - ViewModel Bindings

extension WeatherListInformationTableViewCell {
  
  private func bindInputFromViewModel(_ cellViewModel: CellViewModel) {
    cellViewModel.cellModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
  }
  
  private func bindOutputToViewModel(_ cellViewModel: CellViewModel) {
    // nothing to do
  }
}

// MARK: - Cell Composition

private extension WeatherListInformationTableViewCell {
  
  func setContent(for cellModel: WeatherListInformationTableViewCellModel) {
    backgroundColorView.backgroundColor = cellModel.backgroundColor
    weatherConditionSymbolLabel.text = cellModel.weatherConditionSymbol
    temperatureLabel.text = cellModel.temperature
    cloudCoverageLabel.text = cellModel.cloudCoverage
    humidityLabel.text = cellModel.humidity
    windspeedLabel.text = cellModel.windspeed
  }
  
  func layoutUserInterface() {
    contentView.addSubview(backgroundColorView, constraints: [
      backgroundColorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Dimensions.Spacing.TableCellContentInsets.top),
      backgroundColorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Dimensions.Spacing.TableCellContentInsets.bottom),
      backgroundColorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Definitions.cellLeadingInset),
      backgroundColorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constants.Dimensions.Spacing.TableCellContentInsets.trailing)
    ])
    
    contentView.addSubview(weatherConditionSymbolLabel, constraints: [
      weatherConditionSymbolLabel.heightAnchor.constraint(equalToConstant: Definitions.weatherConditionSymbolHeight),
      weatherConditionSymbolLabel.widthAnchor.constraint(equalToConstant: Definitions.weatherConditionSymbolHeight),
      weatherConditionSymbolLabel.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: Constants.Dimensions.Spacing.TableCellContentInsets.top),
      weatherConditionSymbolLabel.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor, constant: -Constants.Dimensions.Spacing.TableCellContentInsets.bottom),
      weatherConditionSymbolLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.Spacing.TableCellContentInsets.leading),
      weatherConditionSymbolLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
    
    contentView.addSubview(placeNameLabel, constraints: [
      placeNameLabel.heightAnchor.constraint(equalToConstant: Definitions.weatherConditionSymbolHeight),
      placeNameLabel.topAnchor.constraint(
        greaterThanOrEqualTo: contentView.topAnchor,
        constant: Constants.Dimensions.Spacing.TableCellContentInsets.top + Constants.Dimensions.Spacing.InterElementSpacing.yDistance(from: .medium)
      ),
      placeNameLabel.leadingAnchor.constraint(
        equalTo: weatherConditionSymbolLabel.trailingAnchor,
        constant: Constants.Dimensions.Spacing.InterElementSpacing.xDistance(from: .medium)
      ),
      placeNameLabel.trailingAnchor.constraint(
        equalTo: contentView.trailingAnchor,
        constant: -(Constants.Dimensions.Spacing.TableCellContentInsets.trailing + Constants.Dimensions.Spacing.InterElementSpacing.xDistance(from: .medium))
      )
    ])
  }
  
  func setupAppearance() {
    selectionStyle = .none
    backgroundColor = .clear
    contentView.backgroundColor = .clear
  }
}
