//
//  BaseViewController+Extension.swift
//  VictorCRM
//
//  Created by VICTOR03 on 2021/6/29.
//  Copyright © 2021 Victor. All rights reserved.
//

import Foundation
import JXPagingView
import JXSegmentedView
extension BaseViewController: JXSegmentedListContainerViewListDelegate {

    
    func listView() -> UIView {
        return view
    }
    
}


class BasePagingTableController: BaseTableController {
   
    var listViewDidScrollCallback: ((UIScrollView) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.listViewDidScrollCallback?(scrollView)
    }
    
}

extension BasePagingTableController: JXPagingViewListViewDelegate {
    override func listView() -> UIView {
        return view
    }
    
    func listViewDidScrollCallback(callback: @escaping (UIScrollView) -> ()) {
        self.listViewDidScrollCallback = callback
    }
    
    func listScrollView() -> UIScrollView {
        
        return self.tableView!
    }
    
}

extension JXPagingListContainerView: JXSegmentedViewListContainer {}
