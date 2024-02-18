//
//  AdminEditStaffController.swift
//  Wecyn
//
//  Created by Derrick on 2024/1/4.
//

import UIKit

class AdminEditStaffController: BaseViewController {

    var model:AdminStaffModel?
    var newModel:AdminNewStaffModel?
    var container = AdminEditStaffContainer.loadViewFromNib()
    
    init(model:AdminStaffModel) {
        super.init(nibName: nil, bundle: nil)
        self.model = model
    }
    
    init(newModel:AdminNewStaffModel) {
        super.init(nibName: nil, bundle: nil)
        self.newModel = newModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(container)
        container.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
        
        
        if newModel !=  nil  {
            self.navigation.item.title = "New Staff"
            container.newModel = newModel
        } else {
            self.navigation.item.title = "Edit Staff"
            container.model = model
        }
       
        self.addLeftBarButtonItem(image: R.image.xmark()!)
        leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }
    }
    

 
}
