//
//  RegistInfoController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/9.
//

import UIKit

class RegistInfoController: BaseViewController {

    private let container = RegistInfoView.loadViewFromNib()
    private lazy var scrollView = UIScrollView()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(scrollView)
        scrollView.frame = self.view.bounds
        scrollView.addSubview(container)
        container.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 730)
        scrollView.contentSize = CGSize(width: kScreenWidth, height: 730)
        
     
    }
    

   

}
