//
//  Factory+UIButton.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 12.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIButton

extension Factory {

  struct Button: FactoryFunction {

    enum ButtonType {
      case standard(title: String? = nil, height: CGFloat)
    }

    typealias InputType = ButtonType
    typealias ResultType = UIButton

    static func make(fromType type: InputType) -> ResultType {
      let button = UIButton()

      switch type {
      case let .standard(title, height):
        button.layer.cornerRadius = height/2
        button.layer.backgroundColor = Constants.Theme.Color.MarqueColors.standardDay.cgColor

        button.titleLabel?.font = .preferredFont(forTextStyle: .headline)
        button.setTitleColor(.white, for: UIControl.State())

        if let title = title {
          button.setTitle(title, for: UIControl.State())
        }
      }

      return button
    }
  }
}
