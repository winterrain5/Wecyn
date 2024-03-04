//
//  NotificationController.swift
//  Wecyn
//
//  Created by Derrick on 2024/2/27.
//

import UIKit

class NotificationController: BaseTableController {
    
    var lastId:Int?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigation.item.title = "Notificaiton"
        refreshData()
    }
    
    override func loadNewData() {
        lastId = nil
        self.dataArray.removeAll()
        refreshData()
    }

    override func refreshData() {
    
        NotificationService.getNotificationList(lastId: lastId).subscribe(onNext:{
            self.dataArray.append(contentsOf: $0)
            self.lastId = $0.last?.id
            self.endRefresh($0.count,emptyString: "No Notification")
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype, emptyString: e.asAPIError.errorInfo().message)
        }).disposed(by: rx.disposeBag)
        
    }
    
    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    }
    
    
    override func createListView() {
        super.createListView()
        
        tableView?.register(nibWithCellClass: NotificationCell.self)
        
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 60
        
        registRefreshFooter()
        registRefreshHeader(colorStyle: .gray)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: NotificationCell.self)
        if self.dataArray.count > 0 {
            let model = self.dataArray[indexPath.row] as? NotificationModel
            cell.model = model
        }
        return cell
    }
}
