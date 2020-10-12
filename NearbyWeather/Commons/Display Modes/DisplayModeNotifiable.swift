//
//  DisplayModeNotifiable.swift
//  NearbyWeather
//
//  Created by Pierre-Yves Lapersonne on 05/05/2020.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

/// Declares behaviour to implement so as to be able to deal with notifications sent by app delegate and to deal with display modes.
/// Embeds a `displayMode` flag to as to be able to say if the mode in use is light or dark (if ready) for all `UIViewController` which are `DisplayModeNotifiable`.
///
protocol DisplayModeNotifiable where Self: UIViewController {
        
    /// Property giving details about the display mode (dark or light) which should be used.
    var displayMode: Constants.Theme.Mode { get set }
    
    /// To configure elements of the callee using the`displayMode`.
    /// Should be implemented in children so as to deal with display of elements.
    ///
    func configure()
    
    /// To register to notifications sent from the delegate.
    /// Can be called in will-appear methods for view controllers.
    ///
    func registerToDelegateNotifications()
    
    /// To unregister from notifications sent by the delegate.
    /// Can be called in will-disappear methods for view controllers.
    ///
    func unregisterFromDelegateNotifications()
    
}
