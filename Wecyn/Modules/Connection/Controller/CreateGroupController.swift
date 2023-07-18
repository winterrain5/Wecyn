//
//  CreateGroupController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/7.
//

import UIKit
import IQKeyboardManagerSwift
class CreateGroupController: BaseTableController {

    let header = CreateGroupHeaderView.loadViewFromNib()
    let saveButton = UIButton()
    var selectedUsers:[FriendListModel] = []
    var groupName = ""
    var groupModel:GroupZipModel?
    init(groupModel:GroupZipModel? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.groupModel = groupModel
        self.selectedUsers = groupModel?.groups ?? []
        self.groupName = groupModel?.head.name ?? ""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.titleForNormal = "Save"
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        saveButton.textColor(.white)
        saveButton.size = CGSize(width: 48, height: 30)
        saveButton.cornerRadius = 5
        saveButton.isEnabled = false
        saveButton.backgroundColor = R.color.disableColor()!
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        saveButton.rx.tap.subscribe(onNext:{ [weak self] in
            self?.createGroup()
        }).disposed(by: rx.disposeBag)
        
        self.navigation.item.title = groupModel == nil ? "Crate a group" : "Edit Group"
        saveButton.isEnabled =  groupModel != nil
    }
    
    func createGroup() {
        Toast.showLoading()
        let friends = selectedUsers.map({ $0.id })
        FriendService.addGroup(name: groupName,friends: friends).subscribe(onNext:{
            if $0.success == 1 {
                Toast.showSuccess(withStatus: "Created Successfully")
                self.navigationController?.popViewController()
                NotificationCenter.default.post(name: NSNotification.Name.CreateGroup, object: nil)
            } else {
                Toast.showError(withStatus: $0.message)
            }
        },onError: { e in
            Toast.showError(withStatus: e.asAPIError.errorInfo().message)
        }).disposed(by: rx.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = true
    }
    
    override func createListView() {
        super.createListView()
        self.tableView?.tableHeaderView = header
        header.size = CGSize(width: kScreenWidth, height: 162)
        header.addButton.rx.tap.subscribe(onNext:{  [weak self] in
            guard let `self` = self else { return }
            let vc = CalendarAddAttendanceController(selecteds: self.selectedUsers)
            let nav = BaseNavigationController(rootViewController: vc)
            self.present(nav, animated: true)
            vc.selectUsers.subscribe(onNext:{
                self.selectedUsers = $0
                self.reloadData()
            }).disposed(by: self.rx.disposeBag)
        }).disposed(by: rx.disposeBag)
        
        header.nameTf.rx.controlEvent(.editingChanged).subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            let isEnable = !(self.header.nameTf.text?.isEmpty ?? false)
            self.saveButton.isEnabled = isEnable
            self.saveButton.backgroundColor = isEnable ? R.color.theamColor()! : R.color.disableColor()!
            self.groupName = self.header.nameTf.text ?? ""
        }).disposed(by: rx.disposeBag)
        
        header.nameTf.text = self.groupModel?.head.name
        
        
        tableView?.register(cellWithClass: CalendarAddAttendanceCell.self)
 
    }
    
  
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedUsers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withClass: CalendarAddAttendanceCell.self)
        if selectedUsers.count > 0 {
            let model = selectedUsers[indexPath.row]
            cell.imgView.kf.setImage(with: model.avatar.avatarUrl,placeholder: R.image.proile_user()!)
            cell.nameLabel.text = model.full_name
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { _,_,_ in
            if self.selectedUsers.count > indexPath.row {
                self.selectedUsers.remove(at: indexPath.row)
                UIView.performWithoutAnimation {
                    tableView.deleteRows(at: [indexPath], with: .none)
                }
            }
        }
        let config = UISwipeActionsConfiguration(actions: [action])
        return config
    }

}
