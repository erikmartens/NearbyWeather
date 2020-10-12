//
//  Constants+Theme.Color.swift
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 19.04.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

/// Composes `Constants` enumeration with a look and feel theme
/// Declares `Color` to use and also display `Mode`
///
extension Constants.Theme {
  
  /// The bunch of colros ot use in the app
  enum Color {}
    
  /// The display mode to use (e.g. in `UIViewController`: dark mode or light mode)
  enum Mode {
    /// Light mode has been choosen, needs to change colors, or iOS < 13.0
    case light
    /// Dark mode has been choosen
    case dark
  }
    
}

extension Constants.Theme.Color {
  
  enum BrandColors { // TODO rename
    
    static var standardDay: UIColor {
      UIColor.from(dark: .init(hex: 0x64aff5),
                   light: .init(hex: 0x50B4FA))
    }
    
    static var standardNight: UIColor {
      UIColor.from(dark: .init(hex: 0x3f709b),
                   light: .init(hex: 0x32719C))
    }
  }
  
  enum InteractableElement {
    
    static var standardButton: UIColor {
      Constants.Theme.Color.BrandColors.standardDay
    }
    
    static var standardTint: UIColor {
      Constants.Theme.Color.BrandColors.standardDay
    }
  }
  
  enum ContentElement {
    
    static var title: UIColor {
      UIColor.from(dark: .init(hex: 0xFFFFFF),
                   light: .init(hex: 0x000000))
    }
    
    static var subtitle: UIColor {
      Constants.Theme.Color.SystemColor.gray
    }
  }
  
  enum ViewElement {
    
    static var background: UIColor {
      guard #available(iOS 13, *) else {
        return UIColor(red: 255, green: 255, blue: 255)
      }
      return UIColor.systemBackground
    }
    
    static var secondaryBackground: UIColor {
      guard #available(iOS 13, *) else {
        return UIColor(red: 0, green: 0, blue: 0) // TODO
      }
      return UIColor.secondarySystemBackground
    }
    
    static var tertiaryBackground: UIColor {
      guard #available(iOS 13, *) else {
        return UIColor(red: 0, green: 0, blue: 0) // TODO
      }
      return UIColor.tertiarySystemBackground
    }
  }
  
  enum SystemColor {
    
    static var blue: UIColor {
      guard #available(iOS 13, *) else {
        return UIColor(red: 0, green: 122, blue: 255)
      }
      return UIColor.systemBlue
    }
    
    static var green: UIColor {
      UIColor.from(dark: .init(red: 48, green: 209, blue: 88),
                   light: .init(red: 52, green: 199, blue: 89))
    }
    
    static var indigo: UIColor {
      UIColor.from(dark: .init(red: 94, green: 92, blue: 230),
                   light: .init(red: 88, green: 86, blue: 214))
    }
    
    static var orange: UIColor {
      UIColor.from(dark: .init(red: 255, green: 159, blue: 10),
                   light: .init(red: 255, green: 149, blue: 0))
    }
    
    static var pink: UIColor {
      UIColor.from(dark: .init(red: 255, green: 55, blue: 85),
                   light: .init(red: 255, green: 45, blue: 95))
    }
    
    static var purple: UIColor {
      UIColor.from(dark: .init(red: 191, green: 90, blue: 242),
                   light: .init(red: 175, green: 82, blue: 222))
    }
    
    static var red: UIColor {
      UIColor.from(dark: .init(red: 255, green: 69, blue: 58),
                   light: .init(red: 255, green: 59, blue: 48))
    }
    
    static var teal: UIColor {
      UIColor.from(dark: .init(red: 100, green: 210, blue: 255),
                   light: .init(red: 90, green: 200, blue: 250))
    }
    
    static var yellow: UIColor {
      UIColor.from(dark: .init(red: 255, green: 214, blue: 10),
                   light: .init(red: 255, green: 204, blue: 0))
    }
    
    static var gray: UIColor {
      UIColor.from(dark: .init(red: 142, green: 142, blue: 147),
                   light: .init(red: 142, green: 142, blue: 147))
    }
    
    static var gray2: UIColor {
      UIColor.from(dark: .init(red: 99, green: 99, blue: 102),
                   light: .init(red: 174, green: 174, blue: 178))
    }
    
    static var gray3: UIColor {
      UIColor.from(dark: .init(red: 72, green: 72, blue: 74),
                   light: .init(red: 199, green: 199, blue: 204))
    }

    static var gray4: UIColor {
      UIColor.from(dark: .init(red: 58, green: 58, blue: 60),
                   light: .init(red: 209, green: 209, blue: 214))
    }
    
    static var gray5: UIColor {
      UIColor.from(dark: .init(red: 44, green: 44, blue: 46),
                   light: .init(red: 229, green: 229, blue: 234))
    }
    
    static var gray6: UIColor {
      UIColor.from(dark: .init(red: 28, green: 28, blue: 30),
                   light: .init(red: 242, green: 242, blue: 247))
    }
  }
}
