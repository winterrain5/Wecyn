//
//  AdminStaffController.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/15.
//

import UIKit

class AdminStaffController: BasePagingTableController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.isSkeletonable = true
        
        let addButton = UIButton()
        self.view.addSubview(addButton)
        addButton.backgroundColor = R.color.theamColor()
        addButton.titleForNormal = "New"
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
        AdminService.staffList(orgId: Admin_Org_ID).subscribe(onNext:{
            self.dataArray = $0
            self.endRefresh($0.count,emptyString: "No Staffs")
            self.updateDataComplete?()
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype,emptyString: e.asAPIError.errorInfo().message)
            self.updateDataComplete?()
        }).disposed(by: rx.disposeBag)
    }
    
    override func createListView() {
        super.createListView()
        
        
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kTabBarHeight + 10, right: 0)
        
        tableView?.register(nibWithCellClass: AdminStaffItemCell.self)
        
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
        let cell = tableView.dequeueReusableCell(withClass: AdminStaffItemCell.self)
        
        if self.dataArray.count > 0 {
            cell.model = self.dataArray[indexPath.row] as? AdminStaffModel
        }
   
        return cell
        
    }

}
