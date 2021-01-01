//
//  Constants+Dimensions.Size.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 07.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

extension Constants.Dimensions {
  enum Size {}
}

extension Constants.Dimensions.Size {
  
  enum ContentElementSize {
    /// constant: 34
    static let height: CGFloat = 34
  }
  
  enum InteractableElementSize {
    /// constant: 34
    static let height: CGFloat = 34
  }
  
  enum AppIconImageSize {
    /// constant: 75
    static let width: CGFloat = 75
    /// constant: 75
    static let height: CGFloat = 75
    /// constant: 4
    static let cornerRadius: CGFloat = 13
  }
  
  enum TableCellImageSize {
    /// constant: 28
    static let width: CGFloat = 28
    /// constant: 28
    static let height: CGFloat = 28
    /// constant: 4
    static let cornerRadius: CGFloat = 4
  }
  
  enum CornerRadiusSize {
    /// values: 8, 12 and 16
    static func from(weight: Weight) -> CGFloat {
      switch weight {
      case .small:
        return 8
      case .medium:
        return 12
      case .large:
        return 16
      }
    }
  }
}
