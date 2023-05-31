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
}
