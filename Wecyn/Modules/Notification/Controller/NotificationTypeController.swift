//
//  NotificationTypeController.swift
//  Wecyn
//
//  Created by Derrick on 2024/5/31.
//

import UIKit
struct NotificationType {
    let title: String
    let image: UIImage
}
class NotificationTypeController: BaseTableController {

    var data:[NotificationType] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        data = [
        
        ]
        
    }
    

    override func createListView() {
        super.createListView()
        
        tableView?.register(cellWithClass: UITableViewCell.self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
        
        return cell
    }
}
