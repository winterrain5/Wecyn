//
//  AppDelegate.swift
//  CCTStaff
//
//  Created by Derrick on 2022/3/21.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let manager = IQKeyboardManager.shared
        manager.enable = true
        manager.shouldResignOnTouchOutside = true
        manager.shouldShowToolbarPlaceholder = true
        manager.enableAutoToolbar = true
        
        SwiftyFitsize.shared.referenceW = 375
        
        Localizer.shared.changeLanguage.accept("en")
        
        //        CocoaDebug.onlyURLs = [APIHost.share.BaseUrl.appending("/api")]
        
        
        if let _ = UserDefaults.sk.get(of: TokenModel.self, for: TokenModel.className)  {
            let main = MainController()
            window?.rootViewController = main
            main.setSelectedIndex(at: 0)
        } else {
            let vc = LoginController()
            let main = BaseNavigationController(rootViewController: vc)
            window?.rootViewController = main
        }
        
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else {
            return false
        }
        
        // Confirm that the NSUserActivity object contains a valid NDEF message.
        let ndefMessage = userActivity.ndefMessagePayload
        if
            let record = ndefMessage.records.first,
            record.typeNameFormat == .absoluteURI || record.typeNameFormat == .nfcWellKnown,
            let uri = String(data: record.payload, encoding: .utf8),
            let uid = uri.split(separator: "/").last  {
            print("uid:\(uid)")
            
            let vc = NFCNameCardController(id: String(uid).int)
            window?.rootViewController?.present(vc, animated: true)
        }
        
        if let url = userActivity.webpageURL {
            guard let uid = url.absoluteString.split(separator: "/").last else  {
                return false
            }
            
            let vc = NFCNameCardController(id: String(uid).int)
            window?.rootViewController?.present(vc, animated: true)
        }
        
        
        return true
    }
    
}

