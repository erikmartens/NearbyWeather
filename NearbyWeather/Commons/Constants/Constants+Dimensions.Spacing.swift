//
//  Constants+Spacing.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 07.05.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

extension Constants.Dimensions {
  enum Spacing {}
}

extension Constants.Dimensions.Spacing {
  
  enum TableCellContentInsets {
    /// constant: 16
    static let leading: CGFloat = 16
    /// constant: 16
    static let trailing: CGFloat = 16
    /// constant: 4
    static let top: CGFloat = 4
    /// constant: 4
    static let bottom: CGFloat = 4
  }
  
  enum InterElementSpacing {
    /// values: 4, 8 or 12
    static func yDistance(from weight: Weight) -> CGFloat {
      switch weight {
      case .small:
        return 4
      case .medium:
        return 8
      case .large:
        return 12
      }
    }
    /// values: 8, 12 and 16
    static func xDistance(from weight: Weight) -> CGFloat {
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
