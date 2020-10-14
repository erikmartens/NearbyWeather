//
//  Constants+ShortcutIdentifier.swift
//  NearbyWeather
//
//  Created by Pierre-Yves Lapersonne on 14/10/2020.
//  Copyright © 2020 Pierre-Yves Lapersonne. All rights reserved.
//

import Foundation

extension Constants {
  
  /// An enum to use for quick actions, e.g. for 3D-Touch shortcuts
  ///
  enum ShortcutIdentifier: String {
    
    // MARK: - Cases
    
    case addBookmarkedLocation
    case weatherDetailsOfBookmarkedLocation
    
    // MARK: - Init
    
    /// Defines the identifier / enum case using the last token of the scring, splitted by '.'.
    ///
    init?(fullIdentifier: String) {
      guard let shortIdentifier = fullIdentifier.split(separator: ".").map(String.init).last else {
        return nil
      }
      self.init(rawValue: shortIdentifier)
    }
    
  }
}
