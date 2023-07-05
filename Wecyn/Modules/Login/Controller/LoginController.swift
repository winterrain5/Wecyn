//
//  LoginController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/9.
//

import UIKit
import IQKeyboardManagerSwift
class LoginController: BaseViewController {

    private let container = LoginView.loadViewFromNib()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AuthService.getAllCountry().subscribe(onNext:{ _ in }).disposed(by: rx.disposeBag)
        
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
