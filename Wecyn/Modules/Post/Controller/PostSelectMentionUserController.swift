//
//  PostSelectMentionUserController.swift
//  Wecyn
//
//  Created by Derrick on 2024/5/9.
//

import UIKit
import SectionIndexView

class PostSelectMentionUserController: BaseTableController {
    var friends:[[FriendUserInfoModel]] = []
    var models:[FriendUserInfoModel] = []
    var sectionCharacters:[String] = []
    var didSelectContact:((FriendUserInfoModel)->())?
    var searchResults:[FriendUserInfoModel] = []
    var isSearching = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isSkeletonable = true
        self.addLeftBarButtonItem(image: R.image.xmark())
        self.leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }
        refreshData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addTitleView()
    }
    
    func addTitleView() {
        let searchView = NavbarSearchView(placeholder: "Search by name",isSearchable: true,isBecomeFirstResponder: false).frame(CGRect(x: 0, y: 0, width: kScreenWidth * 0.75, height: 36))
        
        self.navigation.item.titleView = searchView
        
        searchView.searchTextChanged = { [weak self] keyword in
            guard let `self` = self else { return }
            if keyword.isEmpty {
                self.isSearching = false
                self.reloadData()
                return
            }
            self.isSearching = true
            self.searchResults = self.friends.flatMap({ $0 }) .filter({
                $0.first_name.lowercased().contains(keyword.trimmed.lowercased()) ||
                $0.last_name.lowercased().contains(keyword.trimmed.lowercased()) ||
                $0.full_name.lowercased().contains(keyword.trimmed.lowercased()) })
            
            self.reloadData()
            searchView.stoploading()
        }
        
        searchView.beginSearch = { [weak self] in
            guard let `self` = self else { return }
            
            self.searchResults = []
            self.reloadData()
        }
    }
    
    
    
    override func refreshData() {
        self.isSearching = false
        NetworkService.searchUserList().subscribe(onNext:{
            self.models = $0
            self.configData(models: $0)
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype, emptyString: e.asAPIError.errorInfo().message)
        }).disposed(by: rx.disposeBag)
    }
    
    func configData(models:[FriendUserInfoModel]) {
        self.showSkeleton()
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
        var dict:[String:[FriendUserInfoModel]] = [:]
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
        tableView?.register(cellWithClass: ConnectionOfMyCell.self)
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom:  10, right: 0)
        
    }
    
    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return isSearching ? 1 : self.friends.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return searchResults.count
        } else {
            
            if friends.count > 0 {
                return friends[section].count
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withClass: ConnectionOfMyCell.self)
        if isSearching {
            if searchResults.count > 0 {
                cell.selectionMentionModel = searchResults[indexPath.row]
            }
        } else {
            if friends.count > 0,friends[indexPath.section].count > 0 {
                cell.selectionMentionModel = friends[indexPath.section][indexPath.row]
            }
        }
       
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return isSearching ? 0 : 22
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if sectionCharacters.count > 0, section < sectionCharacters.count, !isSearching{
            let view = UIView().backgroundColor(R.color.backgroundColor()!)
            let label = UILabel().text(self.sectionCharacters[section])
                .color(R.color.textColor77()!)
                .font(UIFont.sk.pingFangSemibold(12))
            view.addSubview(label)
            label.frame = CGRect(x: 16, y: 0, width: kScreenWidth, height: 22)
            return view
        }
       return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var model:FriendUserInfoModel!
        if friends.count > 0,friends[indexPath.section].count > 0, !isSearching {
            model = friends[indexPath.section][indexPath.row]
        }
        if isSearching, searchResults.count > 0 {
            model = searchResults[indexPath.row]
        }
        
        self.dismiss(animated: true) {
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5) {
                self.didSelectContact?(model)
            }
        }
        
    }
}
