//
//  AdminRoomController.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/15.
//

import UIKit

class AdminRoomController: BasePagingTableController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func refreshData() {
        updateDataComplete?()
    }
}
