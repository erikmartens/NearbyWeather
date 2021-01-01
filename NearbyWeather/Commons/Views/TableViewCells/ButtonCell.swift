//
//  ButtonCell.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 12.02.18.
//  Copyright © 2018 Erik Maximilian Martens. All rights reserved.
//

import UIKit

class ButtonCell: UITableViewCell, ReuseIdentifiable {
  
  private lazy var contentLabel = Factory.Label.make(fromType: .body())
  private lazy var leftButton = Factory.Button.make(fromType: .standard(height: Constants.Dimensions.Size.InteractableElementSize.height))
  private lazy var rightButton = Factory.Button.make(fromType: .standard(height: Constants.Dimensions.Size.InteractableElementSize.height))
  
  private var leftButtonHandler: ((UIButton) -> Void)?
  private var rightButtonHandler: ((UIButton) -> Void)?
  
  @objc private func leftButtonPressed(_ sender: UIButton) {
    leftButtonHandler?(sender)
  }
  
  @objc private func rightButtonPressed(_ sender: UIButton) {
    rightButtonHandler?(sender)
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    composeCell()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    leftButtonHandler = nil
    leftButton.removeTarget(self, action: #selector(Self.leftButtonPressed(_:)), for: .touchUpInside)
    
    rightButtonHandler = nil
    rightButton.removeTarget(self, action: #selector(Self.rightButtonPressed(_:)), for: .touchUpInside)
  }
  
}

extension ButtonCell {
  
  func configure(
    withTitle title: String,
    leftButtonTitle: String,
    rightButtonTitle: String,
    leftButtonHandler: @escaping ((UIButton) -> Void),
    rightButtonHandler: @escaping ((UIButton) -> Void)
  ) {
    contentLabel.text = title
    
    self.rightButtonHandler = rightButtonHandler
    self.leftButtonHandler = leftButtonHandler
    
    leftButton.setTitle(leftButtonTitle, for: UIControl.State())
    leftButton.addTarget(self, action: #selector(ButtonCell.leftButtonPressed(_:)), for: .touchUpInside)
    
    rightButton.setTitle(rightButtonTitle, for: UIControl.State())
    rightButton.addTarget(self, action: #selector(ButtonCell.rightButtonPressed(_:)), for: .touchUpInside)
  }
}

private extension ButtonCell {
  
  func composeCell() {
    contentView.addSubview(contentLabel, constraints: [
      contentLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Dimensions.Size.ContentElementSize.height),
      contentLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.Spacing.TableCellContentInsets.leading),
      contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.Spacing.TableCellContentInsets.trailing)
    ])
    
    contentView.addSubview(leftButton, constraints: [
      leftButton.heightAnchor.constraint(equalToConstant: Constants.Dimensions.Size.InteractableElementSize.height),
      leftButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: Constants.Dimensions.Spacing.InterElementSpacing.yDistance(from: .small)),
      leftButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Dimensions.Spacing.InterElementSpacing.xDistance(from: .medium)),
      leftButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.Spacing.TableCellContentInsets.leading)
    ])
    
    contentView.addSubview(rightButton, constraints: [
      rightButton.heightAnchor.constraint(equalToConstant: Constants.Dimensions.Size.InteractableElementSize.height),
      rightButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: Constants.Dimensions.Spacing.InterElementSpacing.yDistance(from: .small)),
      rightButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.Dimensions.Spacing.InterElementSpacing.yDistance(from: .medium)),
      rightButton.leadingAnchor.constraint(equalTo: leftButton.trailingAnchor, constant: Constants.Dimensions.Spacing.InterElementSpacing.xDistance(from: .large)),
      rightButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.Spacing.TableCellContentInsets.trailing),
      rightButton.widthAnchor.constraint(equalTo: leftButton.widthAnchor, multiplier: 1)
    ])
  }
}
