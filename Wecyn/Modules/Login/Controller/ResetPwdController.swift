//
//  ResetPwdController.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/1.
//

import UIKit

class ResetPwdController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        let container = ResetPwdContainer.loadViewFromNib()
        container.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height:kScreenHeight - kNavBarHeight)
        view.addSubview(container)
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
