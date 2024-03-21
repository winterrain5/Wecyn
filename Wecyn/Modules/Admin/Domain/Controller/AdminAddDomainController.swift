//
//  AdminAddDomainController.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/20.
//

import UIKit

class AdminAddDomainController: BaseViewController {

    let container = AdminAddDomainContainer.loadViewFromNib()
   
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(container)
        container.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
        
        addLeftBarButtonItem(image: R.image.xmark())
        leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }
        
    }

}
