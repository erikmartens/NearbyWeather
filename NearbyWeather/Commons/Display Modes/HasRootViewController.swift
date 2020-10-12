//
//  HasRootViewController.swift
//  NearbyWeather
//
//  Created by Pierre-Yves Lapersonne on 05/05/2020.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

import UIKit

/// It seems because of the RxFlow architecture the rootViewController defined as root in the Flow, and also the navigation controller, are not reachable it view controllers.
/// This protocol allows to keep a reference to it so as to update some details likes tint and bar tint colors.
///
protocol HasRootViewController {

    /// Reference to the root view congtroller
    var customRootViewController: UINavigationController? { get set }
    
}
