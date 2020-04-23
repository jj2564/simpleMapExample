//
//  AppDelegate.swift
//  MapExample
//
//  Created by IrvingHuang on 2020/4/16.
//  Copyright © 2020 Irving Huang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let viewController = ViewController()
        viewController.view.backgroundColor = .white
        window!.rootViewController = viewController
        window!.makeKeyAndVisible()
        
        return true
    }

}

