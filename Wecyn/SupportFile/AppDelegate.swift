//
//  AppDelegate.swift
//  CCTStaff
//
//  Created by Derrick on 2022/3/21.
//

import UIKit
import IQKeyboardManagerSwift
import OpenIMSDK
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let manager = IQKeyboardManager.shared
        manager.enable = true
        manager.shouldResignOnTouchOutside = true
        manager.shouldShowToolbarPlaceholder = true
        manager.enableAutoToolbar = true
        
        SwiftyFitsize.shared.referenceW = 375
        
        Localizer.shared.changeLanguage.accept(getCurrentLanguage())
        
        
        if let _ = UserDefaults.sk.get(of: TokenModel.self, for: TokenModel.className)  {
            let main = MainController()
            window?.rootViewController = main
            main.setSelectedIndex(at: 0)
        } else {
            let vc = LoginController()
            let main = BaseNavigationController(rootViewController: vc)
            window?.rootViewController = main
        }
        
        let userDefaults = UserDefaults(suiteName: APIHost.share.suitName)
        userDefaults?.setValue(APIHost.share.BaseUrl, forKey: "baseUrl")
        userDefaults?.synchronize()
        
        window?.makeKeyAndVisible()
        
        UNUserNotificationCenter.current().delegate = self
        
     
        
        return true
    }
    
    func getCurrentLanguage() -> String {
        let preferredLang = Bundle.main.preferredLocalizations.first! as String
        Logger.debug("当前系统语言:\(preferredLang)")
//        if preferredLang.hasPrefix("en") {
//            return "en"
//        }
//        if preferredLang.hasPrefix("zh") {
//            return "zh_cn"
//        }
        return "en"
        
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
            let url = URL(string: uri.removingPrefix("\u{02}"))  {
            if url.pathComponents.contains("terrabyte.sg") {
                let components = URLComponents(
                    url: url,
                    resolvingAgainstBaseURL: false
                )!
                let id = components.queryItems?.first?.value ?? ""
                let uuid = components.queryItems?.last?.value ?? ""
                let vc = NFCNameCardController(id: id.int,uuid: uuid)
                window?.rootViewController?.navigationController?.pushViewController(vc)
            }
            
        }
        
        if let url = userActivity.webpageURL {
            
//            let vc = NFCNameCardController(id: String(uid).int)
//            window?.rootViewController?.present(vc, animated: true)
        }
        
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let trigger = response.notification.request.trigger else { return; }
        if trigger.isKind(of: UNCalendarNotificationTrigger.classForCoder()) {
            print("Notification did receive, Is class UNCalendarNotificationTrigger")
        } 
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print(url.absoluteString)
       
        if url.scheme == "wecyn" {
            if url.host == "addNewEvent" {
                let vc = CalendarAddNewEventController()
                UIViewController.sk.getTopVC()?.navigationController?.pushViewController(vc)
            }
            if url.host == "checkEventDetail" {
                let components = URLComponents(
                    url: url,
                    resolvingAgainstBaseURL: false
                )!
                print(components.queryItems?.first?.value ?? "")
                if let id = components.queryItems?.first?.value?.int {
                    NotificationCenter.default.post(name: NSNotification.Name.WidgetItemSelected, object: id)
                }
                
            }
            return true
        }
        
        if url.absoluteString.hasSuffix("ics") {
            guard let content = try? String(contentsOf: url, encoding: .utf8) else {
                return true
            }
            let alert = UIAlertController(title: "Want wecyn to create a new calendar schedule for you", message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(title: "yes",style: .destructive) { _ in
                ScheduleService.parseics(icsStr: content).subscribe(onNext:{
                    let infoModel = EventInfoModel()
                    infoModel.title = $0.title
                    infoModel.start_time = $0.start_time
                    infoModel.end_time = $0.end_time
                    infoModel.is_repeat = $0.is_repeat
                    infoModel.rrule_str = $0.rrule_str
                    infoModel.url = $0.url
                    infoModel.location = $0.location
                    infoModel.desc = $0.desc
                    infoModel.isCreateByiCS = true
                    let vc = CalendarAddNewEventController(editEventModel: infoModel)
                    UIViewController.sk.getTopVC()?.navigationController?.pushViewController(vc)
                }).disposed(by: self.rx.disposeBag)
                
            }
            
            alert.addAction(title: "cancel",style: .cancel)
            
            alert.show()
            
            return true
        }
        
        return true
    }

    

}

