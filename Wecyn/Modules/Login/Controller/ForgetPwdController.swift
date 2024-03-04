//
//  ForgetPwdController.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/1.
//

import UIKit

class ForgetPwdController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let container = ForgetPwdContainer.loadViewFromNib()
        container.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height:kScreenHeight - kNavBarHeight)
        view.addSubview(container)
        
    }
    

  

}
