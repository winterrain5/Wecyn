//
//  AdiminAddRoleController.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/19.
//

import UIKit

class AdiminAddRoleController: BaseViewController {

    let container = AdminAddRoleContainer.loadViewFromNib()
    var editModel:AdminRoleItemModel?
    convenience init(editModel:AdminRoleItemModel?) {
        self.init(nibName: nil, bundle: nil)
        self.editModel = editModel
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(container)
        container.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
        
        self.addLeftBarButtonItem(image: R.image.xmark()!)
        self.leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }

        if let editModel = editModel {
            self.navigation.item.title = "Edit Role"
            container.editModel = editModel
        } else {
            self.navigation.item.title = "Add Role"
        }
   
        

    }
    



}
