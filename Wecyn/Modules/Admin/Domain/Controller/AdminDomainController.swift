//
//  AdminDomainController.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/20.
//

import UIKit

class AdminDomainController: BasePagingTableController {

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
            let vc = AdminAddDomainController()
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
            
        }).disposed(by: rx.disposeBag)
    }
    
    override func refreshData() {
        AdminService.domainList(orgId: Admin_Org_ID).subscribe(onNext:{
            self.dataArray = $0
            self.endRefresh($0.count,emptyString: "No Domain")
            self.updateDataComplete?()
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype,emptyString: e.asAPIError.errorInfo().message)
            self.updateDataComplete?()
        }).disposed(by: rx.disposeBag)
    }
    
    override func createListView() {
        super.createListView()
        
        
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kTabBarHeight + 10, right: 0)
        tableView?.register(cellWithClass: AdminDomainCell.self)
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorInset = .zero
        tableView?.separatorStyle = .singleLine
        
        tableView?.rowHeight = 60
    }
    

    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - kNavBarHeight - PagingSegmentHeight.cgFloat - kTabBarHeight)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: AdminDomainCell.self)
        
        if self.dataArray.count > 0 {
            let model = self.dataArray[indexPath.row] as? AdminDomainModel
            cell.model = model
            cell.deleteHandler = { [weak self] item in
                guard let `self` = self else { return }
                self.showAlert(title: "Are you sure you want to delete this domain?", message: nil,buttonTitles: ["Cancel","Cmonfirm"],highlightedButtonIndex: 1) { idx in
                    if idx == 1 {
                        Toast.showLoading()
                        AdminService.deleteDomain(id: item.id).subscribe(onNext:{ status in
                            Toast.dismiss()
                            if status.success == 1 {
                                let idx = (self.dataArray as! [AdminDomainModel]).firstIndex(of: item) ?? 0
                                self.dataArray.remove(at: idx)
                                self.tableView?.reloadData()
                            } else {
                                Toast.showError(status.message)
                            }
                        },onError: { e in
                            Toast.dismiss()
                            Toast.showError(e.asAPIError.errorInfo().message)
                        }).disposed(by: self.rx.disposeBag)
                        
                    }
                }
              
            }
           
        }
        return cell
        
    }
    


}
