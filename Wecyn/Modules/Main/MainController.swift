//
//  TabBarViewController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/8.
//

import UIKit

enum TabConstants {
    
}

class MainController: UITabBarController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupChildController()
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setupChildController() {
        let home = BaseNavigationController(rootViewController: HomeController())
        let connection = BaseNavigationController(rootViewController: ConnectionController())
        let calendar = BaseNavigationController(rootViewController: CalendarEventController())
        let profile = BaseNavigationController(rootViewController: ProfileController())
        let admin = BaseNavigationController(rootViewController: AdminController())
        func selectedImage(_ image: UIImage?) -> UIImage? {
            image?.withTintColor(R.color.theamColor()!).withRenderingMode(.alwaysOriginal)
        }
        
        home.tabBarItem = UITabBarItem.init(
            title: "Home",
            image: R.image.tab_home(),
            selectedImage: selectedImage(R.image.tab_home()))
        connection.tabBarItem = UITabBarItem.init(
            title: "Connection",
            image: R.image.tab_book(),
            selectedImage: selectedImage(R.image.tab_book()))
        
        calendar.tabBarItem = UITabBarItem.init(
            title: "Calendar",
            image: R.image.tab_calendar(),
            selectedImage: selectedImage(R.image.tab_calendar()))
        
        profile.tabBarItem = UITabBarItem.init(
            title: "Profile",
            image: R.image.tab_person(),
            selectedImage: selectedImage(R.image.tab_person()))
        
        admin.tabBarItem = UITabBarItem.init(
            title: "Admin",
            image: R.image.tab_admin(),
            selectedImage: selectedImage(R.image.tab_admin()))
        
        let is_admin = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)?.is_admin ?? 0
        if is_admin == 1 {
            self.viewControllers = [home,calendar,connection,profile,admin]
        } else {
            self.viewControllers = [home,calendar,connection,profile]
        }
        
        configAppearance()
    }
    
    
    func configAppearance() {
        
        let normalFont: UIFont = UIFont.sk.pingFangMedium(10)
        let selectFont: UIFont = UIFont.sk.pingFangSemibold(10)
        
        let normalColor = UIColor.gray
        let selectedColro = UIColor.hexStringColor(hexString: "#288B85")
        
        let normalAttributes:[NSAttributedString.Key:Any] =  [NSAttributedString.Key.foregroundColor: normalColor as Any,NSAttributedString.Key.font: normalFont]
        let selectAttributes:[NSAttributedString.Key:Any] =  [NSAttributedString.Key.foregroundColor: selectedColro as Any,NSAttributedString.Key.font: selectFont]
        
        
        if #available(iOS 13, *) {
            let appearance = UITabBarAppearance()
            let normal = appearance.stackedLayoutAppearance.normal
            normal.titleTextAttributes = normalAttributes
            let select = appearance.stackedLayoutAppearance.selected
            select.titleTextAttributes = selectAttributes
            appearance.backgroundColor = .white
            appearance.backgroundImage = UIImage()
            appearance.shadowImage = UIImage()
            appearance.shadowColor = .clear
            self.tabBar.standardAppearance = appearance
        } else {
            UITabBarItem.appearance().setTitleTextAttributes(normalAttributes, for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes(selectAttributes, for: .selected)
            self.tabBar.shadowImage = UIImage()
            self.tabBar.backgroundImage = UIImage()
            self.tabBar.backgroundColor = .white
        }
        
        self.tabBar.layer.shadowColor = UIColor.black.withAlphaComponent(0.09).cgColor
        self.tabBar.layer.shadowOffset = CGSize(width: 0, height: -3)
        self.tabBar.layer.shadowOpacity = 1
        self.tabBar.layer.shadowRadius = 16
        
    }
    
    
    func setSelectedIndex(at index:Int) {
        self.selectedIndex = index
    }
    
}

