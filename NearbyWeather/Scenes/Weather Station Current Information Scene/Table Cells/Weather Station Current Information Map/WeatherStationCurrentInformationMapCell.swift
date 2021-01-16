//
//  WeatherStationCurrentInformationMapCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 16.01.21.
//  Copyright © 2021 Erik Maximilian Martens. All rights reserved.
//

import UIKit
import RxSwift

// MARK: - Definitions

private extension WeatherStationCurrentInformationMapCell {
  struct Definitions {
    static var trailingLeadingContentInsets: CGFloat {
      if #available(iOS 13, *) {
        return CellContentInsets.leading(from: .small)
      }
      return CellContentInsets.leading(from: .medium)
    }
    static let mapViewHeight: CGFloat = 200
    static let symbolWidth: CGFloat = 20
  }
}

// MARK: - Class Definition

final class WeatherStationCurrentInformationMapCell: UITableViewCell, BaseCell {
  
  typealias CellViewModel = WeatherStationCurrentInformationMapCellViewModel
  private typealias CellContentInsets = Constants.Dimensions.Spacing.ContentInsets
  private typealias CellInterelementSpacing = Constants.Dimensions.Spacing.InterElementSpacing
  
  // MARK: - UIComponents
  
  private lazy var mapView = Factory.MapView.make(fromType: .standard(
    frame: CGRect(
      origin: .zero,
      size: CGSize(width: contentView.frame.size.width - 2*Definitions.trailingLeadingContentInsets, height: Definitions.mapViewHeight)
    ),
    cornerRadiusWeight: .large
  ))
  
  private lazy var coordinatesSymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.sunrise()))
  private lazy var coordinatesDescriptionLabel = Factory.Label.make(fromType: .body(text: R.string.localizable.sunrise(), numberOfLines: 1))
  private lazy var coordinatesLabel = Factory.Label.make(fromType: .body(alignment: .right, numberOfLines: 1))
  
  private lazy var distanceSymbolImageView = Factory.ImageView.make(fromType: .symbol(image: R.image.sunset()))
  private lazy var distanceDescriptionLabel = Factory.Label.make(fromType: .body(text: R.string.localizable.sunset(), numberOfLines: 1))
  private lazy var distanceLabel = Factory.Label.make(fromType: .body(alignment: .right, numberOfLines: 1))
  
  // MARK: - Assets
  
  private var disposeBag = DisposeBag()
  
  // MARK: - Properties
  
  var cellViewModel: CellViewModel?
  
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
  
  func configure(with cellViewModel: BaseCellViewModelProtocol?) {
    guard let cellViewModel = cellViewModel as? WeatherStationCurrentInformationMapCellViewModel else {
      return
    }
    self.cellViewModel = cellViewModel
    cellViewModel.observeEvents()
    bindContentFromViewModel(cellViewModel)
    bindUserInputToViewModel(cellViewModel)
  }
}

// MARK: - ViewModel Bindings

extension WeatherStationCurrentInformationMapCell {
  
  func bindContentFromViewModel(_ cellViewModel: CellViewModel) {
    cellViewModel.cellModelDriver
      .drive(onNext: { [setContent] in setContent($0) })
      .disposed(by: disposeBag)
    
    cellViewModel.mapDelegate?
      .dataSource
      .asDriver(onErrorJustReturn: nil)
      .filterNil()
      .drive(onNext: { [weak self] mapAnnotationData in
        self?.mapView.annotations.forEach { self?.mapView.removeAnnotation($0) }
        self?.mapView.addAnnotations(mapAnnotationData.annotationItems)
      })
      .disposed(by: disposeBag)
  }
}

// MARK: - Cell Composition

private extension WeatherStationCurrentInformationMapCell {
  
  func setContent(for cellModel: WeatherStationCurrentInformationMapCellModel) {
    if let preferredMapTypeValue = cellModel.preferredMapTypeOption?.value {
      switch preferredMapTypeValue {
      case .standard:
        mapView.mapType = .standard
      case .satellite:
        mapView.mapType = .satellite
      case .hybrid:
        mapView.mapType = .hybrid
      }
    }
    coordinatesLabel.text = cellModel.coordinatesString
    distanceLabel.text = cellModel.distanceString
  }
  
  func layoutUserInterface() {
    // map view
    contentView.addSubview(mapView, constraints: [
      mapView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: CellContentInsets.top(from: .medium)),
      mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Definitions.trailingLeadingContentInsets),
      mapView.trailingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Definitions.trailingLeadingContentInsets),
      mapView.heightAnchor.constraint(equalToConstant: Definitions.mapViewHeight)
    ])
    
    // line 1
    contentView.addSubview(coordinatesSymbolImageView, constraints: [
      coordinatesSymbolImageView.topAnchor.constraint(equalTo: mapView.topAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      coordinatesSymbolImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Definitions.trailingLeadingContentInsets),
      coordinatesSymbolImageView.widthAnchor.constraint(equalToConstant: Definitions.symbolWidth),
      coordinatesSymbolImageView.heightAnchor.constraint(equalTo: coordinatesSymbolImageView.widthAnchor)
    ])
    
    contentView.addSubview(coordinatesDescriptionLabel, constraints: [
      coordinatesDescriptionLabel.topAnchor.constraint(equalTo: mapView.topAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      coordinatesDescriptionLabel.leadingAnchor.constraint(equalTo: coordinatesSymbolImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      coordinatesDescriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.Size.ContentElementSize.height),
      coordinatesDescriptionLabel.centerYAnchor.constraint(equalTo: coordinatesSymbolImageView.centerYAnchor)
    ])
    
    contentView.addSubview(coordinatesLabel, constraints: [
      coordinatesLabel.topAnchor.constraint(equalTo: mapView.topAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      coordinatesLabel.leadingAnchor.constraint(equalTo: coordinatesDescriptionLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      coordinatesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Definitions.trailingLeadingContentInsets),
      coordinatesLabel.widthAnchor.constraint(equalTo: coordinatesDescriptionLabel.widthAnchor),
      coordinatesLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.Size.ContentElementSize.height),
      coordinatesLabel.heightAnchor.constraint(equalTo: coordinatesDescriptionLabel.heightAnchor),
      coordinatesLabel.centerYAnchor.constraint(equalTo: coordinatesDescriptionLabel.centerYAnchor),
      coordinatesLabel.centerYAnchor.constraint(equalTo: coordinatesSymbolImageView.centerYAnchor)
    ])
    
    // line 2
    contentView.addSubview(distanceSymbolImageView, constraints: [
      distanceSymbolImageView.topAnchor.constraint(equalTo: coordinatesSymbolImageView.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      distanceSymbolImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Definitions.trailingLeadingContentInsets),
      distanceSymbolImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      distanceSymbolImageView.widthAnchor.constraint(equalToConstant: Definitions.symbolWidth),
      distanceSymbolImageView.heightAnchor.constraint(equalTo: distanceSymbolImageView.widthAnchor)
    ])
    
    contentView.addSubview(distanceDescriptionLabel, constraints: [
      distanceDescriptionLabel.topAnchor.constraint(equalTo: coordinatesDescriptionLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      distanceDescriptionLabel.leadingAnchor.constraint(equalTo: distanceSymbolImageView.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      distanceDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      distanceDescriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.Size.ContentElementSize.height),
      distanceDescriptionLabel.centerYAnchor.constraint(equalTo: distanceSymbolImageView.centerYAnchor)
    ])
    
    contentView.addSubview(distanceLabel, constraints: [
      distanceLabel.topAnchor.constraint(equalTo: coordinatesLabel.bottomAnchor, constant: CellInterelementSpacing.yDistance(from: .medium)),
      distanceLabel.leadingAnchor.constraint(equalTo: distanceDescriptionLabel.trailingAnchor, constant: CellInterelementSpacing.xDistance(from: .small)),
      distanceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Definitions.trailingLeadingContentInsets),
      distanceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -CellContentInsets.bottom(from: .medium)),
      distanceLabel.widthAnchor.constraint(equalTo: distanceDescriptionLabel.widthAnchor),
      distanceLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.Size.ContentElementSize.height),
      distanceLabel.heightAnchor.constraint(equalTo: distanceDescriptionLabel.heightAnchor),
      distanceLabel.centerYAnchor.constraint(equalTo: distanceDescriptionLabel.centerYAnchor),
      distanceLabel.centerYAnchor.constraint(equalTo: distanceSymbolImageView.centerYAnchor)
    ])
  }
  
  func setupAppearance() {
    selectionStyle = .none
    backgroundColor = .clear
    contentView.backgroundColor = Constants.Theme.Color.ViewElement.secondaryBackground
  }
}