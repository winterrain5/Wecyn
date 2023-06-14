//
//  RegistConfirmController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/9.
//

import UIKit

class RegistConfirmController: BaseViewController {

    
    private let container = RegistConfirmView.loadViewFromNib()
    private var registModel:RegistRequestModel
    
    init(registModel:RegistRequestModel) {
        self.registModel = registModel
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(container)
        container.frame = self.view.bounds
        container.registModel = registModel
    }
    

}
