//
//  AdminStaffExpsController.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/29.
//

import UIKit

class AdminStaffExpsController: BaseTableController {

    
    required init(datas:[AdminStaffExps]) {
        super.init(nibName: nil, bundle: nil)
        self.dataArray = datas
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigation.item.title = "Experience"
        
        self.endRefresh(self.dataArray.count,emptyString: "No Experience")
       
    }

    
    override func createListView() {
        super.createListView()
        
        
        
        tableView?.register(nibWithCellClass: AdminStaffExpsCell.self)
        
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
        let cell = tableView.dequeueReusableCell(withClass: AdminStaffExpsCell.self)
        
        if self.dataArray.count > 0 {
            cell.model = self.dataArray[indexPath.row] as? AdminStaffExps
            cell.editHandler = {
                let vc = AdminEditStaffExpController(model: $0)
                let nav = BaseNavigationController(rootViewController: vc)
                nav.modalPresentationStyle  = .fullScreen
                UIViewController.sk.getTopVC()?.present(nav, animated: true)
                vc.updateComplete = { [weak self] updated in
                    let models = self?.dataArray as! [AdminStaffExps]
                    models.forEach({
                        if $0.id == updated.id {
                            $0.industry_name = updated.industry_name
                            $0.title_name = updated.title_name
                            $0.desc = updated.desc
                        }
                    })
                    self?.tableView?.reloadData()
                }
            }
            
            cell.deleteHandler = { [weak self] in
                self?.deleteExp($0)
            }
            
        }
   
        return cell
        
    }
    
    func deleteExp(_ item:AdminStaffExps) {

        func deleteRow(_ item:AdminStaffExps) {
            let idx = (self.dataArray as! [AdminStaffExps]).firstIndex(of: item) ?? 0
            self.dataArray.remove(at: idx)
            self.tableView?.deleteRows(at: [IndexPath(row: idx, section: 0)], with: .automatic)
        }
        let alert = UIAlertController(title: "Are you sure you want to delete this experience?",message: nil, preferredStyle: .actionSheet)
        alert.addAction(title: "Delete directly",style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            AdminService.deleteStaffExp(id: item.id).subscribe(onNext:{
                
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
    
        alert.addAction(title: "Cancel",style: .cancel) { _ in
            
        }
        
        alert.show()
        
    }

}
