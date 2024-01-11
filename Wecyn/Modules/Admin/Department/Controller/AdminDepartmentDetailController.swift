//
//  AdminDepartmentDetailController.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/20.
//

import UIKit

enum CheckMode {
    case Edit
    case Check
    case Add
}

class AdminDepartmentDetailController: BaseViewController {

    let container = AdminDepartmentDetailContainer.loadViewFromNib()
    var node:MMNode<AdminDepartmentModel>?
    var mode:CheckMode = .Check
    
    var deleteHandler:((MMNode<AdminDepartmentModel>)->())?
    var editHandler:((MMNode<AdminDepartmentModel>)->())?
    required init(node:MMNode<AdminDepartmentModel>? = nil,mode:CheckMode) {
        super.init(nibName: nil, bundle: nil)
        self.node = node
        self.mode = mode
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(container)
       
    
        container.editButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self,let node = self.node else { return }
            UIViewController.sk.getTopVC()?.dismiss(animated: true,completion: {
                self.editHandler?(node)
            })
        }).disposed(by: rx.disposeBag)
        
        container.deleteButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self,let node = self.node else { return }
            UIViewController.sk.getTopVC()?.dismiss(animated: true,completion: {
                self.deleteHandler?(node)
            })
        }).disposed(by: rx.disposeBag)
        
        
        self.addLeftBarButtonItem(image: R.image.xmark()!)
        self.leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }
        
        container.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
        container.mode = self.mode
        if mode == .Check {
            self.navigation.item.title = "Department Detail"
            container.node = self.node
        }
        
        
        if mode == .Add {
            self.navigation.item.title = "Add Department"
        }
        
        if mode == .Edit {
            self.navigation.item.title = "Edit Department"
            container.node = self.node
        }
        
        
    }
    


}
