//
//  ConnectionOfMyController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/19.
//

import UIKit
import SwiftAlertView
import SectionIndexView
class ConnectionOfMyController: BasePagingTableController {
    
    var friends:[[FriendListModel]] = []
    var models:[FriendListModel] = [] {
        didSet {
            configData(models: models)
        }
    }
    var connections:[FriendRecieveModel] = []
    var sectionCharacters:[String] = []
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showSkeleton()
    }
    


    
    func configData(models:[FriendListModel]) {
        self.friends.removeAll()
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
        
        self.endRefresh(models.count)
        self.hideSkeleton()
    }
    
    override func createListView() {
        super.createListView()
        cellIdentifier = ConnectionOfMyCell.className
        tableView?.isSkeletonable = true
        registRefreshHeader()
        tableView?.showsVerticalScrollIndicator = false
        tableView?.register(nibWithCellClass: ConnectionOfMyCell.self)
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom:  10, right: 0)
        
    }
    
    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: 2, width: kScreenWidth, height: kScreenHeight - ConnectFriendHeaderInSectionHeight.cgFloat + 2 - kNavBarHeight - kTabBarHeight)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.friends.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if friends.count > 0 {
            return friends[section].count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withClass: ConnectionOfMyCell.self)
        if friends.count > 0,friends[indexPath.section].count > 0 {
            cell.model = friends[indexPath.section][indexPath.row]
        }
        
        cell.deleteFriendHandler = { [weak self] item in
            guard let `self` = self else { return }
            SwiftAlertView.show(title:"Danger Operation",message: "Are you sure you want to delete this friend?", buttonTitles: ["Cancel","Confirm"]).onActionButtonClicked { alertView, buttonIndex in
                if buttonIndex == 1 {
                    Toast.showLoading()
                    FriendService.deleteFriend(friend_id: item.id).subscribe(onNext:{ status in
                        Toast.dismiss()
                        if status.success == 1 {
                            Toast.showSuccess(withStatus: "Delete Success")
                            let datas = self.friends.flatMap({
                                var temp = $0
                                temp.removeAll(where: { $0.id == item.id })
                                return temp
                            })
                            self.configData(models: datas)
                        } else {
                            Toast.showError(withStatus: status.message)
                        }
                        
                    },onError: { e in
                        Toast.showError(withStatus: e.asAPIError.errorInfo().message)
                    }).disposed(by: self.rx.disposeBag)
                }
            }
            
        }
        cell.selectionStyle = .none
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if sectionCharacters.count > 0, section < sectionCharacters.count{
            let view = UIView().backgroundColor(.white)
            let label = UILabel().text(self.sectionCharacters[section])
                .color(R.color.textColor52()!)
                .font(UIFont.sk.pingFangSemibold(15))
            view.addSubview(label)
            label.frame = CGRect(x: 16, y: 0, width: kScreenWidth, height: 22)
            return view
        }
       return nil
    }
}
