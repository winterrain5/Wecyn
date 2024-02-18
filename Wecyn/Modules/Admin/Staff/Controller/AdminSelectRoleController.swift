//
//  AdminSelectRoleController.swift
//  Wecyn
//
//  Created by Derrick on 2024/1/10.
//

import UIKit

class AdminSelectRoleController: BaseTableController {

    var selectModel:AdminRoleItemModel?
    var selectComplete:((AdminRoleItemModel)->())?
    required init(selectModel:AdminRoleItemModel?) {
        super.init(nibName: nil, bundle: nil)
        self.selectModel = selectModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadNewData()
        
        self.navigation.item.title = "Select Role"
        self.addLeftBarButtonItem(image: R.image.xmark()!)
        leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }
        
    }
    override func refreshData() {
        
        AdminService.roleList(orgId: Admin_Org_ID,keyword: "").subscribe(onNext:{
            var data = $0
            let normalStaff = AdminRoleItemModel()
            normalStaff.id = 0
            normalStaff.name = "Normal Staff"
            data.insert(normalStaff, at: 0)
            
            data.forEach({
                if  $0.id == self.selectModel?.id {
                    $0.isSelected = true
                }
            })
            
            
            self.dataArray = data
            self.endRefresh($0.count,emptyString: "No Roles")
            
            
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype,emptyString: e.asAPIError.errorInfo().message)
           
        }).disposed(by: rx.disposeBag)
    }
    
    override func createListView() {
        super.createListView()
        
        
        tableView?.register(cellWithClass: UITableViewCell.self)
        
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorInset = .zero
        tableView?.separatorStyle = .singleLine
        
    }
    

    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight )
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
        
        if self.dataArray.count > 0 {
            let model = self.dataArray[indexPath.row] as! AdminRoleItemModel
            cell.textLabel?.text = model.name
            cell.accessoryType = model.isSelected ? .checkmark : .none
        }
  
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let models = self.dataArray as! [AdminRoleItemModel]
        models.forEach({ $0.isSelected = false })
        
        let model = self.dataArray[indexPath.row] as! AdminRoleItemModel
        model.isSelected = true
        tableView.reloadData()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            self.selectComplete?(model)
            
            self.returnBack()
        }
       
    }
}
