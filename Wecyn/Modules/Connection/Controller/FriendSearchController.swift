//
//  FriendSearchController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/30.
//

import UIKit
import IQKeyboardManagerSwift
class FriendSearchController: BaseTableController {
    let searchView = NavbarSearchView(placeholder: "Search Friend Name",isSearchable: true).frame(CGRect(x: 0, y: 0, width: kScreenWidth * 0.75, height: 36))

    var keword:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigation.item.titleView = searchView
        searchView.searching = { [weak self] keyword in
            guard let `self` = self else { return }
            self.searchView.startLoading()
            self.keword = keyword.trimmed
            self.loadNewData()
        }
        
        self.addLeftBarButtonItem()
        self.leftButtonDidClick = {
            self.navigationController?.popViewController(animated: true)
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
        NetworkService.searchUserList(keyword:keword).subscribe(onNext:{ models in
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
            self.searchView.stoploading()
        },onError: { e in
            self.searchView.stoploading()
            self.endRefresh(e.asAPIError.emptyDatatype)
        }).disposed(by: rx.disposeBag)
    }
    
    override func createListView() {
        super.createListView()
        
        registRefreshHeader()
        tableView?.showsVerticalScrollIndicator = false
        tableView?.register(cellWithClass: ConnectionOfMyCell.self)
        tableView?.scrollToTop()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withClass: ConnectionOfMyCell.self)
        if  dataArray.count > 0 {
            cell.model = dataArray[indexPath.row] as? FriendListModel
        }
        
        cell.selectionStyle = .none
        return cell
    }

    
}
