//
//  ConnectionGroupController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/7.
//

import UIKit
import SwiftAlertView
class GroupZipModel: BaseModel {
    var head: GroupListModel =  GroupListModel()
    var groups: [FriendListModel] = []
}
class ConnectionGroupController: BasePagingTableController {
    var datas:[GroupZipModel] = []
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.CreateGroup, object: nil, queue: .main) { _ in
            
            self.loadNewData()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshData()
    }
    
    override func refreshData() {
        datas.removeAll()
        let friendList = FriendService.friendList()
        let groupList = FriendService.selectGroup()
        Observable.zip(friendList,groupList).subscribe(onNext:{ friends,groups in
            
            var temp = friends
            temp.removeAll(where: { $0.group_id == 0 })
            var dict:[Int:[FriendListModel]] = [:]
            temp.forEach { model in
                let key = model.group_id
                if dict[key] != nil {
                    dict[key]?.append(model)
                } else {
                    dict[key] = [model]
                }
            }
            
            self.datas = groups.map { item in
                let model = GroupZipModel()
                model.head = item
                model.groups = dict[item.id] ?? []
                return model
            }
            self.endRefresh(groups.count)
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype)
        }).disposed(by: rx.disposeBag)
        
    }
    
    
    override func createListView() {
        configTableview(.insetGrouped)
        tableView?.backgroundColor = R.color.backgroundColor()!
        tableView?.register(cellWithClass: GroupHeadeCell.self)
        tableView?.register(cellWithClass: GroupItemCell.self)
    }
    
    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: 2, width: kScreenWidth, height: kScreenHeight - ConnectFriendHeaderInSectionHeight.cgFloat + 2 - kNavBarHeight - kTabBarHeight)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.datas.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < datas.count {
            let head = datas[section].head
            if head.isExpand {
                return datas[section].head.count > 0 ? datas[section].head.count + 1 : 1
            }  else {
                return 1
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 80
        } else {
            return 66
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withClass: GroupHeadeCell.self)
            if datas.count > 0,indexPath.section < datas.count {
                cell.model = datas[indexPath.section].head
            }
            cell.indexPath = indexPath
            cell.arrowButtonDidClickHandler = { [weak self] idx in
                self?.tableView?.reloadSections(IndexSet(integer: idx.section), with: .none)
            }
            cell.deleteButtonDidClickHandler = { [weak self] item in
                self?.deleteGroup(id: item.id)
            }
            cell.editButtonDidClickHandler = {  [weak self] idx in
                let vc = CreateGroupController(groupModel: self?.datas[idx.section])
                self?.navigationController?.pushViewController(vc)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withClass: GroupItemCell.self)
            if datas.count > 0,indexPath.section < datas.count, datas[indexPath.section].groups.count > 0, (indexPath.row - 1) < datas[indexPath.section].groups.count{
                let model = datas[indexPath.section].groups[indexPath.row  - 1]
                cell.imgView.kf.setImage(with: model.avatar.avatarUrl,placeholder: R.image.proile_user()!)
                cell.nameLabel.text = model.full_name
            }
            return cell
        }
    }
    
    
    func deleteGroup(id:Int) {
        Toast.showLoading()
        FriendService.deleteGroup(id: id).subscribe(onNext:{
            if $0.success == 1 {
                Toast.showSuccess(withStatus: "Successful operation")
                self.loadNewData()
            } else {
                Toast.showError(withStatus: $0.message)
            }
        },onError: { e in
            Toast.showError(withStatus: e.asAPIError.errorInfo().message)
        }).disposed(by: rx.disposeBag)
    }
}
