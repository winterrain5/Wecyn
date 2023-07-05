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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "Logout"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UserDefaults.sk.removeAllKeyValue()
        let nav = BaseNavigationController(rootViewController: LoginController())
        UIApplication.shared.keyWindow?.rootViewController = nav
    }

}
