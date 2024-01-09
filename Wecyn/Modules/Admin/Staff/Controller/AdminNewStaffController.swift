//
//  AdminNewStaffController.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/29.
//

import UIKit

class AdminNewStaffController: BaseTableController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigation.item.title = "New Staff"
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNewData()
    }
    
    override func refreshData() {
        AdminService.pendingCertificateStaff(orgId: Admin_Org_ID).subscribe(onNext:{
            self.dataArray = $0
            self.endRefresh($0.count,emptyString: "No Staff")
            
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype,emptyString: e.asAPIError.errorInfo().message)
            self.updateDataComplete?()
        }).disposed(by: rx.disposeBag)
    }
    
    override func createListView() {
        super.createListView()
        
        
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kTabBarHeight + 10, right: 0)
        
        tableView?.register(nibWithCellClass: AdminNewStaffCell.self)
        
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorInset = .zero
        tableView?.separatorStyle = .singleLine
        
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.estimatedRowHeight = 120
    }
    

    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: AdminNewStaffCell.self)
        
        if self.dataArray.count > 0 {
            cell.model = self.dataArray[indexPath.row] as? AdminNewStaffModel
        }
        
        cell.operateHandler = { [weak self] in

            if $0 == 1 {
                self?.accpet($1)
            }
            
            if $0 == 2 {
                self?.reject($1)
            }
        }
   
        return cell
        
    }
    
    func accpet(_ model:AdminNewStaffModel) {
        let alert = UIAlertController(title: "Accept New Staff", message: "You should assign this staff to a department.", preferredStyle: .actionSheet)
        
        alert.addAction(title: "Confirm") { [weak self] _ in
            guard let `self` = self else { return }
            let vc = AdminSelectDepartmentController()
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            UIViewController.sk.getTopVC()?.present(nav, animated: true)
            vc.selectComplete = { dept in
                
                self.showAlert(title: dept.name, message: "Please confirm assigned department", buttonTitles: ["Confirm","Cancel"], highlightedButtonIndex: 0) { idx in
                    if idx == 0 {
                        let requst = AdminCertificatStaffRequestModel()
                        requst.id = model.id
                        requst.org_id = model.org_id
                        requst.status = 1
                        requst.dept_id = dept.id
                       
                        AdminService.staffCertificate(model: requst).subscribe(onNext:{
                            if $0.success == 1 {
                                Toast.showSuccess("Successful operation")
                                self.navigationController?.popViewController()
                            } else {
                                Toast.showError($0.message)
                            }
                        },onError: { e in
                            Toast.showError(e.asAPIError.errorInfo().message)
                        }).disposed(by: self.rx.disposeBag)
                    }
                }
                
            }
            
        }
        alert.addAction(title: "Cancel",style: .cancel) { _ in
            
        }
        
        alert.show()
        
    }
    func reject(_ model:AdminNewStaffModel) {
        let requst = AdminCertificatStaffRequestModel()
        requst.id = model.id
        requst.org_id = model.org_id
        requst.status = 0
        
        AdminService.staffCertificate(model: requst).subscribe(onNext:{
            if $0.success == 1 {
                Toast.showSuccess("Successful operation")
                self.navigationController?.popViewController()
            } else {
                Toast.showError($0.message)
            }
        },onError: { e in
            Toast.showError(e.asAPIError.errorInfo().message)
        }).disposed(by: rx.disposeBag)
    }


}
