//
//  AppDelegate.swift
//  CCTStaff
//
//  Created by Derrick on 2022/3/21.
//

import UIKit
import IQKeyboardManagerSwift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let manager = IQKeyboardManager.shared
        manager.enable = true
        manager.shouldResignOnTouchOutside = true
        manager.shouldShowToolbarPlaceholder = true
        manager.enableAutoToolbar = true
        
        SwiftyFitsize.shared.referenceW = 375
        
        Localizer.shared.changeLanguage.accept("en")
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let vc = LoginController()
        let main = BaseNavigationController(rootViewController: vc)
//        let main = MainController()
//        main.setSelectedIndex(at: 2)
        window?.rootViewController = main
        window?.makeKeyAndVisible()
        
        
        return true
    }



}

