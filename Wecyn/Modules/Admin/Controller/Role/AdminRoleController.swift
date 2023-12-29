//
//  AdminRoleController.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/15.
//

import UIKit

class AdminRoleController: BasePagingTableController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.isSkeletonable = true
        
        let addButton = UIButton()
        self.view.addSubview(addButton)
        addButton.backgroundColor = R.color.theamColor()
        addButton.titleForNormal = "+"
        addButton.titleLabel?.font = UIFont.sk.pingFangMedium(30)
        addButton.titleColorForNormal = .white
        addButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-(kTabBarHeight + 16))
            make.width.height.equalTo(60)
        }
        addButton.addShadow(cornerRadius: 30)
        addButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Haptico.selection()
            let vc = AdiminAddRoleController()
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
           
        }).disposed(by: rx.disposeBag)
        
        
    }
    
    override func refreshData() {
        showSkeleton()
        AdminService.roleList(orgId: Admin_Org_ID,keyword: "").subscribe(onNext:{
            self.dataArray = $0
            self.endRefresh($0.count,emptyString: "No Roles")
            self.updateDataComplete?()
            self.hideSkeleton()
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype,emptyString: e.asAPIError.errorInfo().message)
            self.updateDataComplete?()
            self.hideSkeleton()
        }).disposed(by: rx.disposeBag)
    }
    
    override func createListView() {
        super.createListView()
        
        tableView?.isSkeletonable = true
        cellIdentifier = AdminRoleItemCell.className
        
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kTabBarHeight + 10, right: 0)
        
        tableView?.register(nibWithCellClass: AdminRoleItemCell.self)
        
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorInset = .zero
        tableView?.separatorStyle = .singleLine
        
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 120
    }
    

    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - kNavBarHeight - PagingSegmentHeight.cgFloat - kTabBarHeight)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: AdminRoleItemCell.self)
        
        if self.dataArray.count > 0 {
            cell.model = self.dataArray[indexPath.row] as? AdminRoleItemModel
        }
        cell.deleteHandler = { [weak self] in
            self?.deleteRole($0)
        }
        cell.editHandler = { [weak self] in
            self?.editRole($0)
        }
        return cell
        
    }
    
    func editRole(_ item:AdminRoleItemModel) {
        let vc = AdiminAddRoleController(editModel: item)
        let nav = BaseNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    
    func deleteRole(_ item:AdminRoleItemModel) {

        func deleteRow(_ item:AdminRoleItemModel) {
            let idx = (self.dataArray as! [AdminRoleItemModel]).firstIndex(of: item) ?? 0
            self.dataArray.remove(at: idx)
            self.tableView?.deleteRows(at: [IndexPath(row: idx, section: 0)], with: .automatic)
        }
        let alert = UIAlertController(title: "Are you sure you want to delete this role?", message: "You can move users to another role.", preferredStyle: .actionSheet)
        alert.addAction(title: "Delete directly",style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            AdminService.deleteRole(id: item.id).subscribe(onNext:{
                
                if $0.success == 1 {
                    deleteRow(item)
                    Toast.showSuccess("successfully deleted")
                } else {
                    Toast.showError($0.message)
                }
                
            },onError: { e in
                Toast.showError(e.asAPIError.errorInfo().message)
            }).disposed(by: self.rx.disposeBag)
        }
        
        alert.addAction(title: "Assigned to another role",style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            let vc = AdminDeleteRoleController(model: item, datas: self.dataArray as! [AdminRoleItemModel])
            let nav = BaseNavigationController(rootViewController: vc)
            if let sheet = nav.sheetPresentationController{
                sheet.detents = [.medium(), .large()]
            }
            vc.deleteSuccessfuly = { item in
                deleteRow(item)
            }
            self.present(nav, animated: true)
        }
        
        alert.addAction(title: "Cancel",style: .cancel) { _ in
            
        }
        
        alert.show()
        
    }
}
