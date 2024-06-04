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
        
        if let selectAssistant = UserDefaults.sk.get(of: UserInfoModel.self, for: "selectAssistant") {
            CalendarBelongUserId = selectAssistant.id.int ?? 0
            CalendarBelongUserName = selectAssistant.full_name
        } else {
            CalendarBelongUserId = UserDefaults.userModel?.id.int ?? 0
            CalendarBelongUserName = UserDefaults.userModel?.full_name ?? ""
        }
        
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = self.dataArray[indexPath.row] as! NotificationModel
        // 通知类型。默认0，所有通知。1 入职审核结果通知（Work_Exp，Edu_Exp），2 添加助理通知（被添加，被移除），3 好友审核通知（同意/拒绝），4 Event的attendees通知，5 Post的@通知，6 Post的评论和回复通知
        if model.type == 4 {
            guard let model = model.extra?.event else { return }
            let vc = CalendarEventDetailController(eventModel: model)
            self.navigationController?.pushViewController(vc)
        }
        if model.type == 5 || model.type == 6 {
            guard let postId = model.extra?.id else { return }
            let vc = PostDetailViewController(postId: postId)
            self.navigationController?.pushViewController(vc)
        }
    }
}
