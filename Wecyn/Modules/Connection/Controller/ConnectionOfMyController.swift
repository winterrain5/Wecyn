//
//  ConnectionOfMyController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/19.
//

import UIKit
import SwiftAlertView
class ConnectionOfMyController: BaseTableController {
    
    var friends:[FriendListModel] = []
    var connections:[FriendRecieveModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigation.item.title = "My connections"
        
        let search = UIButton().image(R.image.connection_search())
        let searchItem = UIBarButtonItem(customView: search)
        self.navigation.item.rightBarButtonItems = [searchItem]
        search.rx.tap.subscribe(onNext:{
            let vc = FriendSearchController()
            self.navigationController?.pushViewController(vc,animated: false)
        }).disposed(by: rx.disposeBag)
        
        refreshData()
    }
    
    override func refreshData() {
        getFriendList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func getFriendList() {
        
        FriendService.friendList().subscribe(onNext:{ models in
            self.friends = models
            self.endRefresh()
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype)
        }).disposed(by: rx.disposeBag)
        
        FriendService.friendRecieveList().subscribe(onNext:{ models  in
            self.connections = models
            self.endRefresh()
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype)
        }).disposed(by: rx.disposeBag)
    }
    
    override func createListView() {
        super.createListView()
        
        registRefreshHeader()
        tableView?.showsVerticalScrollIndicator = false
        tableView?.register(nibWithCellClass: ConnectionOfMyCell.self)
        tableView?.register(nibWithCellClass: ConnectAuditItemCell.self)
        tableView?.scrollToTop()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? connections.count : friends.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 90 : 116
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withClass: ConnectAuditItemCell.self)
            let model = connections[indexPath.row]
            cell.model = model
            cell.auditHandler = { [weak self] in
                self?.refreshData()
            }
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withClass: ConnectionOfMyCell.self)
            cell.model = friends[indexPath.row]
            cell.deleteFriendHandler = { [weak self] item in
                guard let `self` = self else { return }
                SwiftAlertView.show(title:"Danger Operation",message: "Are you sure you want to delete this friend?", buttonTitles: ["Cancel","Confirm"]).onActionButtonClicked { alertView, buttonIndex in
                    if buttonIndex == 1 {
                        FriendService.deleteFriend(friend_id: item.id).subscribe(onNext:{ status in
                            if status.success == 1 {
                                Toast.showSuccess(withStatus: "Delete Success")
                            } else {
                                Toast.showError(withStatus: status.message)
                            }
                            self.endRefresh()
                        }).disposed(by: self.rx.disposeBag)
                    }
                }
                
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 0
        }
        return connections.count > 0 ? 44 : 0
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0  {
            let view = UIView().backgroundColor(.white)
            let label = UILabel().text("New connection request(s) from:").color(R.color.textColor52()!).font(UIFont.sk.pingFangSemibold(15))
            view.addSubview(label)
            label.frame = CGRect(x: 28, y: 0, width: kScreenWidth, height: 44)
            return view
        }
        return nil
    }
}
