//
//  UIColor+Variations.swift
//  NearbyWeather
//
//  Created by Pierre-Yves Lapersonne on 05/05/2020.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit.UIColor

/// Extension to bring an helper function for `UIColor`so a to compuite a darker variation of the current color
///
extension UIColor {

    /// Computes a darker version of the current color and returns the new value.
    /// If no darker color has ben computed, returns the `self` version.
    /// - Parameters:
    ///     - rate: Variation to apply, the lower is it, the darker the color will be, default is -40
    /// - Returns: The new color if darker, otherwise the current color
    ///
    func darker(by rate: CGFloat = -40.0) -> UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + rate/100, 1.0),
                              green: min(green + rate/100, 1.0),
                              blue: min(blue + rate/100, 1.0),
                              alpha: alpha)
        } else {
            return self
        }
    }
    
    /// Computes a lighter version of the current color and returns the new value.
    /// If no lighter color hhas ben computed, returns the `self` version.
    /// - Parameters:
    ///     - rate: Variation to apply, the higher is it, the ligther the color will be, default is 5
    /// - Returns: The new color if lighter, otherwise the current color
    ///
    func lighter(by rate: CGFloat = 5.0) -> UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + rate/100, 1.0),
                              green: min(green + rate/100, 1.0),
                              blue: min(blue + rate/100, 1.0),
                              alpha: alpha)
        } else {
            return self
        }
    }
}
