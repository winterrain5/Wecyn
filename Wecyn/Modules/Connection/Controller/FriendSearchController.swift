//
//  FriendSearchController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/30.
//

import UIKit
import SwiftAlertView
import IQKeyboardManagerSwift
class FriendSearchController: BaseTableController {
    
    var keword:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchView = NavbarSearchView(placeholder: "Search Friend Name",isSearchable: true).frame(CGRect(x: 0, y: 0, width: kScreenWidth * 0.75, height: 36))
        self.navigation.item.titleView = searchView
        searchView.searching = { [weak self] keyword in
            guard let `self` = self else { return }
            self.keword = keyword.trimmed
            self.loadNewData()
        }
        
        self.addLeftBarButtonItem(image: R.image.navigation_back_default()!.withTintColor(.black))
        self.leftButtonDidClick = {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = true
    }
    
    override func refreshData() {
        FriendService.searchUserList(keyword:keword).subscribe(onNext:{ models in
            self.dataArray = models.map({
                let model = FriendListModel()
                model.avatar = $0.avatar
                model.first_name = $0.first_name
                model.last_name = $0.last_name
                model.id = $0.id
                model.wid =   $0.wid
                return model
            })
            self.endRefresh(models.count)
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype)
        }).disposed(by: rx.disposeBag)
    }
    
    override func createListView() {
        super.createListView()
        
        registRefreshHeader()
        tableView?.showsVerticalScrollIndicator = false
        tableView?.register(nibWithCellClass: ConnectionOfMyCell.self)
        tableView?.scrollToTop()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 116
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withClass: ConnectionOfMyCell.self)
        cell.model = dataArray[indexPath.row] as? FriendListModel
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
