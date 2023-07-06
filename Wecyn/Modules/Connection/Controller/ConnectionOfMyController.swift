//
//  ConnectionOfMyController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/19.
//

import UIKit
import SwiftAlertView
import SectionIndexView
class ConnectionOfMyController: BaseTableController {
    
    var friends:[[FriendListModel]] = []
    var connections:[FriendRecieveModel] = []
    var sectionCharacters:[String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addRightBarItems()
        
        let searchView = NavbarSearchView(placeholder: "Search User",isSearchable: false)
        searchView.size = CGSize(width: kScreenWidth * 0.7, height: 36)
        self.navigation.item.titleView = searchView
        searchView.rx.tapGesture().when(.recognized).subscribe(onNext:{ _ in
            self.navigationController?.pushViewController(ConnectionController(),animated: false)
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
        self.friends.removeAll()
        self.showSkeleton()
        FriendService.friendList().subscribe(onNext:{ models in
            self.configData(models: models)
            self.endRefresh()
            self.hideSkeleton()
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype)
            self.hideSkeleton()
        }).disposed(by: rx.disposeBag)
        
        FriendService.friendRecieveList().subscribe(onNext:{ models  in
            self.connections = models
            self.endRefresh()
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype)
        }).disposed(by: rx.disposeBag)
    }
    
    func configData(models:[FriendListModel]) {
        if  models.count > 0 {
            var characters = models.map({ String( $0.first_name.first! ).uppercased() })
            self.sectionCharacters = characters.removeDuplicates().sorted(by: { $0 < $1 })
            let items = self.sectionCharacters.compactMap { (title) -> SectionIndexViewItem? in
                let item = SectionIndexViewItemView()
                item.title = title
                item.indicator = SectionIndexViewItemIndicator(title: title)
                return item
            }
            
            self.tableView?.sectionIndexView(items: items)
        }
        var dict:[String:[FriendListModel]] = [:]
        models.forEach { model in
            let key = model.first_name.first?.uppercased() ?? ""
            if dict[key] != nil {
                dict[key]?.append(model)
            } else {
                dict[key] = [model]
            }
        }
        dict.values.sorted(by: {
            ($0.first?.first_name.first?.uppercased() ?? "") < ($1.first?.first_name.first?.uppercased() ?? "")
        }).forEach({ self.friends.append($0) })
    }
    
    override func createListView() {
        super.createListView()
        cellIdentifier = ConnectionOfMyCell.className
        tableView?.isSkeletonable = true
        registRefreshHeader()
        tableView?.showsVerticalScrollIndicator = false
        tableView?.register(nibWithCellClass: ConnectionOfMyCell.self)
        tableView?.register(nibWithCellClass: ConnectAuditItemCell.self)
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kTabBarHeight + 10, right: 0)
        tableView?.scrollToTop()
        
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.friends.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return connections.count
        } else {
            if friends.count > 0 {
                return friends[section - 1].count
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
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
            if friends.count > 0,friends[indexPath.section - 1].count > 0 {
                cell.model = friends[indexPath.section - 1][indexPath.row]
            }
            cell.deleteFriendHandler = { [weak self] item in
                guard let `self` = self else { return }
                SwiftAlertView.show(title:"Danger Operation",message: "Are you sure you want to delete this friend?", buttonTitles: ["Cancel","Confirm"]).onActionButtonClicked { alertView, buttonIndex in
                    if buttonIndex == 1 {
                        FriendService.deleteFriend(friend_id: item.id).subscribe(onNext:{ status in
                            if status.success == 1 {
                                Toast.showSuccess(withStatus: "Delete Success")
                                self.loadNewData()
                            } else {
                                Toast.showError(withStatus: status.message)
                            }
                            
                        }).disposed(by: self.rx.disposeBag)
                    }
                }
                
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section >= 1 {
            return 22
        }
        return connections.count > 0 ? 36 : 0
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0  {
            let view = UIView().backgroundColor(.white)
            let label = UILabel().text("New connection request(s) from:").color(R.color.textColor52()!).font(UIFont.sk.pingFangSemibold(15))
            view.addSubview(label)
            label.frame = CGRect(x: 16, y: 0, width: kScreenWidth, height: 36)
            return view
        } else {
            let view = UIView().backgroundColor(.white)
            let label = UILabel().text(self.sectionCharacters[section - 1]).color(R.color.textColor52()!).font(UIFont.sk.pingFangSemibold(15))
            view.addSubview(label)
            label.frame = CGRect(x: 16, y: 0, width: kScreenWidth, height: 22)
            return view
        }
    }
}
