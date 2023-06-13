//
//  RegistConfirmController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/9.
//

import UIKit

class RegistConfirmController: BaseViewController {

    
    private let container = RegistConfirmView.loadViewFromNib()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(container)
        container.frame = self.view.bounds
    }
    

}
