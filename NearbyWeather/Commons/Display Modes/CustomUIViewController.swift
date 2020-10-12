//
//  CustomUIViewController.swift
//  NearbyWeather
//
//  Created by Pierre-Yves Lapersonne on 05/05/2020.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

/// Class to use so as to be able to deal with switch of dark and light modes in `UIViewController` thanks to `DisplayModeNotifiable` protocol.
///
class CustomUIViewController: UIViewController, DisplayModeNotifiable, HasRootViewController {
    
    // MARK: - Properties
    
    /// Flag indicating if registration of app delegate notifications has been made or not to prevent to make several registrations.
    private var isRegisteredToDelegateNotifications = false
    
    // MARK: - Protocol HasRootViewController
    
    /// Weak reference to root view controller so as to reach navigation bar.
    /// The value for this `customRootViewController` is set after the `configure()` call with the RxFlow, so we cannot update it at that level.
    /// Thus the `barTintColor` and `tintColor` of its `navigationBar`are defined using the  `displayMode` just after its definition.
    weak var customRootViewController: UINavigationController? {
        didSet {
            updateNavigationBarColors()
        }
    }
    
    // MARK: - UIViewController
    
    /// When the view will appear, registers to notifications sent by app deegate,  and triggers also the callback to apply the display mode.
    ///
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerToDelegateNotifications()
        applyDisplayMode()
    }
    
    /// When the view will disappeau, registers to notifications sent by app deegate
    ///
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      unregisterFromDelegateNotifications()
    }
    
    // MARK: - Methods
    
    /// Once triggerred, triggers the configuration method with the mode to apply.
    /// If the curent OS is not iOS 13.0 or is under, configures with `.light` mode.
    /// Otherwise checks the `userInterfaceStyle` to define the mode to use.
    /// Can be called in view-did-load controller smethod.
    ///
    @objc func applyDisplayMode() {
        guard #available(iOS 13.0, *) else {
            return configure()
        }
        displayMode = traitCollection.userInterfaceStyle == .dark ? .dark : .light
        configure()
        updateNavigationBarColors()
    }
    
    /// Using the `displayMode`,  updates the `barTintColor` and `tintColor` of the `navigationBar`
    /// defined in `customRootViewController`
    func updateNavigationBarColors() {
        guard let customRootViewController = customRootViewController else {
            return
        }
        if displayMode == .dark {
            customRootViewController.navigationBar.barTintColor = Constants.Theme.Color.ViewElement.background.lighter()
            customRootViewController.navigationBar.tintColor = UIColor.white
        } else {
            customRootViewController.navigationBar.barTintColor = Constants.Theme.Color.ViewElement.background
            customRootViewController.navigationBar.tintColor = UIColor.black
        }
    }

    // MARK: - Protocol DisplayModeNotifiable
    
    /// Property giving details about the display mode (dark or light) which should be used.
    /// By default set to `.light` os as to be compliant with non-dark-mode-ready versions.
    var displayMode: Constants.Theme.Mode = .light
    
    /// This method must be overriden  by subclases of `CustomUIViewController` because it configures embeded elements.
    ///
    func configure() {
        preconditionFailure("This method must be overridden")
    }
       
    /// Registers to notifications sent from the delegate
    ///
    func registerToDelegateNotifications() {
        if !isRegisteredToDelegateNotifications {
            NotificationCenter.default.addObserver(self, selector: #selector(applyDisplayMode),
                                                          name: UIApplication.didBecomeActiveNotification,
                                                          object: nil)
            isRegisteredToDelegateNotifications = true
        }
    }
       
    /// Unregisters from notifications sent by the delegate
    ///
    func unregisterFromDelegateNotifications() {
        if isRegisteredToDelegateNotifications {
            NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification,
                                                           object: nil)
            isRegisteredToDelegateNotifications = false
        }
    }
    
}
