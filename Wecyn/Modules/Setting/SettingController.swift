//
//  SettingController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/8.
//

import UIKit

class SettingController: BaseTableController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = RegistAddAvatarController()
        self.navigationController?.pushViewController(vc)
    }

}
