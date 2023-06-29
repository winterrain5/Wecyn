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
    var editEventModel:EventInfoModel? = nil
    
    init(editEventMode:EventInfoModel? = nil) {

        self.editEventModel = editEventMode
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
     
        self.view.addSubview(scrollView)
        scrollView.frame = self.view.bounds
        
        scrollView.addSubview(container)
        container.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 740)
        scrollView.contentSize = CGSize(width: kScreenWidth, height: 740)
        
        if let _ = editEventModel {
            navigation.item.title = "Edit event"
        } else {
            navigation.item.title = "Add New event"
        }
        container.editEventModel = editEventModel
    }
    


}
