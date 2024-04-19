//
//  NotifictionCenter+Name.swift
//  VictorCRM
//
//  Created by liyuzhu on 2021/7/7.
//  Copyright © 2021 Victor. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let ConnectionRefreshing = Notification.Name("ConnectionRefreshing")
    static let ConnectionAuditUser = Notification.Name("ConnectionAuditUser")
    static let CreateGroup = Notification.Name("CreateGroup")
    static let WidgetItemSelected = Notification.Name("WidgetItemSelected")
    
    static let UpdateAdminData = Notification.Name("UpdateAdminData")
    static let UpdateUserInfo = Notification.Name("UpdateUserInfo")
}

extension Notification.Name {
    static let UpdateConversation = Notification.Name("UpdateConversation")
    static let ClearC2CHistory = Notification.Name("ClearC2CHistory")
    static let UpdateNotificationCount = Notification.Name("UpdateNotificationCount")
    static let UpdateConnectionCount = Notification.Name("UpdateConnectionCount")
    static let UpdateFriendRecieve = Notification.Name("UpdateFriendRecieve")
}
