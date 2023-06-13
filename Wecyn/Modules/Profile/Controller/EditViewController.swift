//
//  EditViewController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/13.
//

import UIKit

class EditViewController: BaseViewController {
    
    private let container = NameCardView()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(container)
        container.frame = self.view.bounds
        view.backgroundColor = R.color.backgroundColor()
        
        
    }
    

    

}
