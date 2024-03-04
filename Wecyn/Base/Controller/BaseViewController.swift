//
//  BaseViewController.swift
//  OneOnline
//
//  Created by Derrick on 2020/2/28.
//  Copyright © 2020 OneOnline. All rights reserved.
//

import UIKit
import BadgeControl
import IQKeyboardManagerSwift
class BaseViewController: UIViewController {
    var badger:BadgeController!
    var updateDataComplete:(()->())?
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
        
        IQKeyboardManager.shared.enableAutoToolbar = false

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Toast.dismiss()
    }
    
    func addLeftBarButtonItem(image:UIImage? = R.image.chevronBackward()) {
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
    
    func returnBack() {
        if self.presentingViewController == nil {
            self.navigationController?.popViewController(animated: true)
        }else {
          self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func addRightBarItems() {
        
        
        let fixItem1 = UIBarButtonItem.fixedSpace(width: 22)
        
        let notificationButton = UIButton()
        notificationButton.imageForNormal = R.image.bell()
        let notificationItem = UIBarButtonItem(customView: notificationButton)
        notificationButton.rx.tap.subscribe(onNext:{
            
            let vc = NotificationController()
            self.navigationController?.pushViewController(vc)
           
        }).disposed(by: rx.disposeBag)
        
        let fixItem2 = UIBarButtonItem.fixedSpace(width: 22)
        
        let message = UIButton()
        message.imageForNormal = R.image.ellipsisMessage()
        let messageItem = UIBarButtonItem(customView: message)
        message.rx.tap.subscribe(onNext:{
            
        }).disposed(by: rx.disposeBag)
        
        
        self.navigation.item.rightBarButtonItems = [notificationItem,fixItem1,messageItem,fixItem2]
        
        badger = BadgeController(for: notificationButton,
                                 in: .upperLeftCorner,
                                 badgeBackgroundColor: UIColor.red,
                                 badgeTextColor: UIColor.white,
                                 badgeHeight: 16)
        
        
    }
    
    func updateBadge(_ count:Int) {
        if count == 0 {
            badger.remove(animated: false)
            return
        }
        badger.addOrReplaceCurrent(with: count.string, animated: true)
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
        Logger.info("\(self.className)销毁" )
    }
}
