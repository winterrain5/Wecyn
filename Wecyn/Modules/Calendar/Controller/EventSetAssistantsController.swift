//
//  EventSetAssistantsController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/4.
//

import UIKit

import UIKit
import RxRelay
import IQKeyboardManagerSwift
class EventSetAssistantsController: BaseTableController {

    var friends:[FriendListModel] = []
    var selectUsers: [FriendListModel] = []
    var searchResults:[FriendListModel] = []
    var keyword = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneButton = UIButton()
        doneButton.textColor(.black)
        doneButton.titleForNormal = "Done"
        let doneItem = UIBarButtonItem(customView: doneButton)
        
        let fixItem = UIBarButtonItem.fixedSpace(width: 16)
        
        self.navigation.item.rightBarButtonItems = [doneItem,fixItem]
        doneButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            if self.selectUsers.count > 0 {
                self.addAssistants()
            } else {
                self.dismiss(animated: true)
            }
           
            
        }).disposed(by: rx.disposeBag)
        
        let searchView = NavbarSearchView(placeholder: "Search by Name",isSearchable: true,isBecomeFirstResponder: false)
        searchView.size = CGSize(width: kScreenWidth * 0.75, height: 36)
        self.navigation.item.titleView = searchView
        searchView.searching = { [weak self] keyword in
            guard let `self` = self else { return }
            self.keyword = keyword.trimmed
            self.searchResults = self.friends.filter({ $0.first_name.contains(keyword.trimmed) || $0.last_name.contains(keyword.trimmed) || $0.full_name.contains(keyword.trimmed)})
            self.reloadData()
        }
        
        searchView.beginSearch = { [weak self] in
            guard let `self` = self else { return }
            self.searchResults = []
            self.reloadData()
        }
        
        self.addLeftBarButtonItem()
        self.leftButtonDidClick = { [weak self] in
            self?.dismiss(animated: true)
        }
        
   
        refreshData()
    }
    
    func addAssistants() {
        if selectUsers.count > 3 {
            Toast.showMessage("The number of people selected cannot exceed 3")
            return
        }
        let assistants:[Assistant] = self.selectUsers.map { model in
            let assistant = Assistant()
            assistant.id = model.id
            return assistant
        }
        let requestModel = AddAssitantsRequestModel()
        requestModel.assistants = assistants
        ScheduleService.addAssistants(model: requestModel).subscribe(onNext:{
            if $0.success == 1 {
                Toast.showSuccess(withStatus: "Successful operation", after: 2, {
                    self.dismiss(animated: true)
                })
                
            } else {
                Toast.showError(withStatus: $0.message)
            }
            
        },onError: { e in
            Toast.showError(withStatus: e.asAPIError.errorInfo().message)
        }).disposed(by: self.rx.disposeBag)
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
        let friendList = FriendService.friendList()
        let assistants = ScheduleService.sendedAssistantList()
        
        Observable.zip(friendList,assistants).subscribe(onNext:{ friends,assistants in
            
            friends.forEach({ item in
                if assistants.contains(where: { $0.id == item.id }) {
                    item.isSelected = true
                    self.selectUsers.append(item)
                }
            })
            
            self.friends = friends
            self.endRefresh()
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype)
        }).disposed(by: rx.disposeBag)
    }
    
    override func createListView() {
        super.createListView()
        
        registRefreshHeader()
        tableView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: kBottomsafeAreaMargin + 10, right: 0)
        tableView?.showsVerticalScrollIndicator = false
        tableView?.register(cellWithClass: CalendarAddAttendanceCell.self)
        tableView?.scrollToTop()
        
        let view = UIView()
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "You can choose up to 3 assistants from your friends, who have full control of your schedule."
        label.font = UIFont.sk.pingFangSemibold(15)
        label.textColor = R.color.textColor162C46()
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview().inset(16)
        }
        tableView?.tableHeaderView = view
        let height = (label.text?.heightWithConstrainedWidth(width: kScreenWidth - 32, font: label.font) ?? 0) + 32
        view.size = CGSize(width: kScreenWidth, height: height)
        
    }
    
  
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count > 0 ? searchResults.count : friends.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withClass: CalendarAddAttendanceCell.self)
        var model:FriendListModel?
        if searchResults.count > 0 {
            model = searchResults[indexPath.row]
        }else if friends.count > 0{
            model = friends[indexPath.row]
        }
        guard let model = model else { return cell  }
        cell.imgView.kf.setImage(with: model.avatar.avatarUrl,placeholder: R.image.proile_user()!)
        cell.nameLabel.text = model.full_name
        cell.accessoryType = model.isSelected ? .checkmark : .none
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        selectUsers.removeAll()
        
        let model = friends[indexPath.row]
        model.isSelected = !model.isSelected
        
        selectUsers.append(contentsOf:friends.filter({ $0.isSelected }))
        
        tableView.reloadData()
    }

}
