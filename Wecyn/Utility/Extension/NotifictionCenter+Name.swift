//
//  NotifictionCenter+Name.swift
//  VictorCRM
//
//  Created by liyuzhu on 2021/7/7.
//  Copyright © 2021 Victor. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let TapPersonalListCard = Notification.Name("TapPersonalListCard")
    static let TapPersonalListMsg = Notification.Name("TapPersonalListMsg")
    static let TapPersonalListTag = Notification.Name("TapPersonalListTag")
    static let TapPersonalListSetting = Notification.Name("TapPersonalListSetting")
    static let TapPersonalListWithdraw = Notification.Name("TapPersonalListWithdraw")
    static let getFingerInfoComplete = Notification.Name("getFingerInfoComplete")
    static let RefundPriceChange = Notification.Name("RefundPriceChange")
    static let RefundCountChange = Notification.Name("RefundCountChange")
    static let ShareRefundPriceChange = Notification.Name("ShareRefundPriceChange")
}
