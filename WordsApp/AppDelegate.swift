//
//  AppDelegate.swift
//  WordsApp
//
//  Created by Jeytery on 21.10.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let mainCoordinator = MainCoordinator()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = mainCoordinator.navigationPresenter
        window?.makeKeyAndVisible()
        return true
    }
}

