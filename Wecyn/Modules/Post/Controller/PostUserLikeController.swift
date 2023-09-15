//
//  PostUserLikeController.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/13.
//

import UIKit

class PostUserLikeController: BasePagingTableController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.endRefresh(.NoData)
    }
    

    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - PostUserHeaderInSectionHeight.cgFloat - kNavBarHeight)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

}
