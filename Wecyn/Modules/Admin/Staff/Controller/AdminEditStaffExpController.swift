//
//  AdminEditStaffExpController.swift
//  Wecyn
//
//  Created by Derrick on 2024/1/10.
//

import UIKit

class AdminEditStaffExpController: BaseViewController {

    var model:AdminStaffExps?
    var container = AdminEditStaffExpContainer.loadViewFromNib()
    var updateComplete:((AdminStaffExps)->())?
    required init(model:AdminStaffExps) {
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
        container.model = model
        container.updateComplete = { [weak self] in
            guard let `self` = self,let model = self.model else { return }
            Toast.showSuccess("successfully edited")
            UIViewController.sk.getTopVC()?.dismiss(animated: true)
            NotificationCenter.default.post(name: NSNotification.Name.UpdateAdminData, object: nil)
            
            model.title_name = $0.title_name ?? ""
            model.desc = $0.desc ?? ""
            model.industry_name = $0.industry_name ?? ""
            
            self.updateComplete?(model)
        }
        
        self.navigation.item.title = "Edit Staff Experience"
        self.addLeftBarButtonItem(image: R.image.xmark()!)
        leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }
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
