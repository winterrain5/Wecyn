//
//  RegistAddAvatarController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/12.
//

import UIKit

class RegistAddAvatarController: BaseViewController {

    private let container = RegistAddAvatarView.loadViewFromNib()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(container)
        container.frame = self.view.bounds
    }
    
}
