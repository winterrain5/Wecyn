//
//  AdminEditStaffController.swift
//  Wecyn
//
//  Created by Derrick on 2024/1/4.
//

import UIKit

class AdminEditStaffController: BaseViewController {

    var model:AdminStaffModel?
    var container = AdminEditStaffContainer.loadViewFromNib()
    
    required init(model:AdminStaffModel) {
        super.init(nibName: nil, bundle: nil)
        self.model = model
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(container)
        container.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
        container.model = model
        
        self.navigation.item.title = "Edit Staff"
        self.addLeftBarButtonItem(image: R.image.xmark()!)
        leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }
    }
    

 
}
