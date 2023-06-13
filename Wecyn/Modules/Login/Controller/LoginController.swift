//
//  LoginController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/9.
//

import UIKit

class LoginController: BaseViewController {

    private let container = LoginView.loadViewFromNib()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(container)
        container.frame = self.view.bounds
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
