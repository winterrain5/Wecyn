//
//  EventDetailController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/27.
//

import UIKit

class EventDetailController: BaseViewController {

    var container = EventDetailView.loadViewFromNib()
    var eventModel:EventListModel
    init(eventModel:EventListModel) {
        self.eventModel = eventModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(container)
        container.frame = self.view.bounds
        
        ScheduleService.eventInfo(eventModel.id).subscribe(onNext:{
            
            self.container.eventModel = self.eventModel
            self.container.model = $0
            
        }).disposed(by: rx.disposeBag)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigation.bar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigation.bar.isHidden = false
    }
    

}
