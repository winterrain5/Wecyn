//
//  CalendarAddEventController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/19.
//

import UIKit

class CalendarAddEventController: BaseViewController {
    
    let scrollView = UIScrollView()
    let container = CalendarAddEventView.loadViewFromNib()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigation.item.title = "Add New event"
     
        self.view.addSubview(scrollView)
        scrollView.frame = self.view.bounds
        
        scrollView.addSubview(container)
        container.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 740)
        scrollView.contentSize = CGSize(width: kScreenWidth, height: 740)
    }
    


}
