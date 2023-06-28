//
//  EventDetailController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/27.
//

import UIKit

class EventDetailController: BaseViewController {

    var container = EventDetailView.loadViewFromNib()
    var eventId:Int
    var status:Int
    init(eventId:Int,status:Int) {
        self.eventId = eventId
        self.status = status
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(container)
        container.frame = self.view.bounds
        
        ScheduleService.eventInfo(eventId).subscribe(onNext:{
            self.container.model = $0
            self.container.status = self.status
            self.container.eventId = self.eventId
        }).disposed(by: rx.disposeBag)
        
        
    }

}
