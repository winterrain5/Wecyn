//
//  RegistConfirmController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/9.
//

import UIKit
import IQKeyboardManagerSwift
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

        container.registModel = registModel
        self.view.addSubview(container)
        container.frame = self.view.bounds
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = true
    }
}
