//
//  AppDelegate.swift
//  CCTStaff
//
//  Created by Derrick on 2022/3/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let vc = ViewController()
        vc.view.backgroundColor = .white
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        Logger.debug(APIHost.share.buildType.currentBuildType)
        return true
    }



}

