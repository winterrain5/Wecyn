//
//  ConnectAuditController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/25.
//

import UIKit

class ConnectAuditController: BaseTableController {

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshData()
       
    }
    
    override func refreshData() {
       
    }

    override func createListView() {
        super.createListView()
        registRefreshHeader()
        tableView?.register(nibWithCellClass: ConnectAuditItemCell.self)
        tableView?.rowHeight = 116
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ConnectAuditItemCell.self)
        if self.dataArray.count > 0 {
            let model = self.dataArray[indexPath.row] as? FriendRecieveModel
            cell.model = model
        }
        cell.selectionStyle = .none
        return cell
    }
}
