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
    
    func addRightBarItems() {
        
        let fixItem1 = UIBarButtonItem.fixedSpace(width: 16)
        
        let notification = UIButton()
        notification.imageForNormal = R.image.navbar_bell()
        let notificationItem = UIBarButtonItem(customView: notification)
        notification.rx.tap.subscribe(onNext:{
          
        }).disposed(by: rx.disposeBag)
        
        let fixItem2 = UIBarButtonItem.fixedSpace(width: 16)
        
        let message = UIButton()
        message.imageForNormal = R.image.navbar_message()
        let messageItem = UIBarButtonItem(customView: message)
        message.rx.tap.subscribe(onNext:{
            
        }).disposed(by: rx.disposeBag)
                
        
        self.navigation.item.rightBarButtonItems = [notificationItem,fixItem1,messageItem,fixItem2]
  
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
