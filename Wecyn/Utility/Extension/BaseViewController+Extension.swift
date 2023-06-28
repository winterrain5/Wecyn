//
//  BaseViewController+Extension.swift
//  VictorCRM
//
//  Created by VICTOR03 on 2021/6/29.
//  Copyright © 2021 Victor. All rights reserved.
//

import Foundation
import JXSegmentedView
extension BaseViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
    
    func addRightBarItems() {
        let notification = UIButton()
        notification.imageForNormal = R.image.navbar_bell()
        let notificationItem = UIBarButtonItem(customView: notification)
        
        let message = UIButton()
        message.imageForNormal = R.image.navbar_message()
        let messageItem = UIBarButtonItem(customView: message)
                
        
        self.navigation.item.rightBarButtonItems = [notificationItem,messageItem]
  
    }
}
