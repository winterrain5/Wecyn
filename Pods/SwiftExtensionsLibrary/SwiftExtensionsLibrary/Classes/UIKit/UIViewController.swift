//
//  UIViewController.swift
//  SwiftExtensionsLibrary
//
//  Created by Derrick on 2023/6/8.
//

import Foundation

public extension ExtensionBase where Base: UIViewController {
    // MARK: - 查找顶层控制器、
    // 获取顶层控制器 根据window
    static func getTopVC() -> UIViewController? {
        var window = UIApplication.shared.keyWindow
        //是否为当前显示的window
        if window?.windowLevel != UIWindow.Level.normal{
            let windows = UIApplication.shared.windows
            for  windowTemp in windows{
                if windowTemp.windowLevel == UIWindow.Level.normal{
                    window = windowTemp
                    break
                }
            }
        }
        let vc = window?.rootViewController
        return getTopVC(withCurrentVC: vc)
    }
    
    static func getTopVC(by windowLevel:CGFloat) -> UIViewController? {
        var window = UIApplication.shared.keyWindow
        //是否为当前显示的window
        if window?.windowLevel != UIWindow.Level.normal{
            let windows = UIApplication.shared.windows
            for  windowTemp in windows{
                if windowTemp.windowLevel == UIWindow.Level(windowLevel){
                    window = windowTemp
                    break
                }
            }
        }
        let vc = window?.rootViewController
        return getTopVC(withCurrentVC: vc)
    }
    
    ///根据控制器获取 顶层控制器
    private static func getTopVC(withCurrentVC VC :UIViewController?) -> UIViewController? {
        if VC == nil {
            print("🌶： 找不到顶层控制器")
            return nil
        }
        if let presentVC = VC?.presentedViewController {
            //modal出来的 控制器
            return getTopVC(withCurrentVC: presentVC)
        }else if let tabVC = VC as? UITabBarController {
            // tabBar 的跟控制器
            if let selectVC = tabVC.selectedViewController {
                return getTopVC(withCurrentVC: selectVC)
            }
            return nil
        } else if let naiVC = VC as? UINavigationController {
            // 控制器是 nav
            return getTopVC(withCurrentVC:naiVC.visibleViewController)
        } else {
            // 返回顶控制器
            return VC
        }
    }
    
 
}

public extension UIViewController {
    @discardableResult
    func showAlertController(title: String?,
                             message: String?,
                             buttonTitles: [String]? = nil,
                             highlightedButtonIndex: Int? = nil,
                             preferredStyle:UIAlertController.Style = .alert,
                             completion: ((Int) -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        var allButtons = buttonTitles ?? [String]()
        if allButtons.count == 0 {
            allButtons.append("OK")
        }

        for index in 0..<allButtons.count {
            let buttonTitle = allButtons[index]

            // Check which button to highlight
            if let highlightedButtonIndex = highlightedButtonIndex, index == highlightedButtonIndex {
                alertController.addAction(image: nil, title: buttonTitle, color: .blue, style: .default, isEnabled: true) { (action) in
                    completion?(index)
                }
            }else {
                alertController.addAction(image: nil, title: buttonTitle, color: UIColor.gray, style: .default, isEnabled: true) { (action) in
                    completion?(index)
                }
            }
        }
        alertController.setTitle(font: UIFont.boldSystemFont(ofSize: 14), color: .black)
        alertController.setMessage(font: UIFont.systemFont(ofSize: 14), color: .lightGray)
        present(alertController, animated: true, completion: nil)
        return alertController
    }
}
