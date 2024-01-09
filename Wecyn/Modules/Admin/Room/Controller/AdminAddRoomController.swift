//
//  AdminAddRoomController.swift
//  Wecyn
//
//  Created by Derrick on 2024/1/9.
//

import UIKit

class AdminAddRoomController: BaseViewController {

    let container = AdminAddRoomContainer.loadViewFromNib()
    var model:AdminRoomModel?
    required init(model:AdminRoomModel? = nil) {
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
        container.model = self.model
        
        addLeftBarButtonItem(image: R.image.xmark())
        leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }
        
        if self.model == nil {
            self.navigation.item.title = "Add Room"
        } else {
            self.navigation.item.title = "Edit Room"
        }
    }
    


}
