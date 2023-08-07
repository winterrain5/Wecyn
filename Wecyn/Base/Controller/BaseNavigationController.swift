//
//  BaseNavigationController.swift
//  OneOnline
//
//  Created by Derrick on 2020/2/28.
//  Copyright © 2020 OneOnline. All rights reserved.
//

import UIKit
import EachNavigationBar
class BaseNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigation.configuration.isEnabled = true
        self.navigation.configuration.titleTextAttributes = [.foregroundColor: UIColor.black,.font: UIFont.systemFont(ofSize: 18,weight: .medium)]
        self.navigation.configuration.isShadowHidden = true
        self.navigation.configuration.isTranslucent = true
        self.navigation.configuration.barTintColor = .white
        self.navigation.configuration.backItem = UINavigationController.Configuration.BackItem(style: .image(R.image.chevronBackward()!))
        self.navigation.configuration.tintColor = .black
    }
    /// 拦截push
    override func pushViewController(_ viewController: UIViewController, animated: Bool = true) {
        if self.viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    /// 拦截present
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if self.viewControllers.count > 1 {
            viewControllerToPresent.hidesBottomBarWhenPushed = true
        }
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if (animated) {
            let popController = self.viewControllers.last
            popController?.hidesBottomBarWhenPushed = false
        }
        return super.popToRootViewController(animated: animated)
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if (animated) {
            let popController = self.viewControllers.last
            popController?.hidesBottomBarWhenPushed = false
        }
        return super.popToViewController(viewController, animated: animated)
    }
    
    @objc func popBack() {
        self.view.endEditing(true)
        self.popViewController(animated: true)
    }
    
    @objc func dismissBack() {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
}
