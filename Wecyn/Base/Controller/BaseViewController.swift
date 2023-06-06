//
//  BaseViewController.swift
//  OneOnline
//
//  Created by Derrick on 2020/2/28.
//  Copyright © 2020 OneOnline. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
class BaseViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    private lazy var leftButton = UIButton()
    var leftButtonDidClick:(()->())?
    var interactivePopGestureRecognizerEnable:Bool = true{
        didSet {
            navigationController?.interactivePopGestureRecognizer?.isEnabled = interactivePopGestureRecognizerEnable
        }
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isSkeletonable = true
        view.backgroundColor = .white
        self.extendedLayoutIncludesOpaqueBars = true
        interactivePopGestureRecognizerEnable = true
        self.becomeFirstResponder()
    
        IQKeyboardManager.shared.enableAutoToolbar = true
    
    }
    
    func addLeftBarButtonItem(_ image:UIImage? = nil) {
        leftButton.setImage(image, for: .normal)
        leftButton.frame = CGRect(x: 0, y: 0, width: 33, height: 40)
        leftButton.contentHorizontalAlignment = .left
        leftButton.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.leftButtonDidClick?()
            }).disposed(by: rx.disposeBag)
        self.navigation.item.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        Toast.dismiss()
    }
    
    func barTintColor(_ color:UIColor) {
        self.navigation.bar.tintColor = color
        self.navigation.bar.titleTextAttributes = [.foregroundColor: color,.font: UIFont.systemFont(ofSize: 18)]
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        Logger.debug("摇一摇结束")
        #if DEBUG
        self.showAlertController(title: "LookInServer", message: nil, buttonTitles: ["导出当前UI结构","审查元素","3D视图","取消"], highlightedButtonIndex: nil, preferredStyle: .alert, completion: { idx in
            if idx == 0 {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Lookin_Export"), object: nil)
            }
            if idx == 1 {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Lookin_2D"), object: nil)
            }
            if idx == 2 {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Lookin_3D"), object: nil)
            }
        })
        #endif
    }
    
    deinit {
        Toast.dismiss()
        Logger.info("\(self.className)销毁" )
    }
}
