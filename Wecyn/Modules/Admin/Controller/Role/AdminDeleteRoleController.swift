//
//  AdminDeleteRoleController.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/18.
//

import UIKit

class AdminDeleteRoleController: BaseTableController {
    var model:AdminRoleItemModel!
    var datas:[AdminRoleItemModel] = []
    let saveButton = UIButton()
    var deleteSuccessfuly:((AdminRoleItemModel)->())?
    required init(model:AdminRoleItemModel,datas:[AdminRoleItemModel]) {
        super.init(nibName: nil, bundle: nil)
        self.model = model
        self.datas = datas
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        datas.removeAll(where: { [weak self] in
            $0.id == self?.model.id
        })
        self.endRefresh()

        self.addLeftBarButtonItem(image: R.image.xmark()!)
        self.leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }

        saveButton.isEnabled = false
        saveButton.imageForNormal = R.image.checkmark()
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        saveButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }

            AdminService.deleteRole(id: self.model.id,toId: self.datas.filter({ $0.isSelected }).first?.id).subscribe(onNext:{
                if $0.success == 1 {
                    Toast.showSuccess("successfully deleted")
                    self.returnBack()
                    self.deleteSuccessfuly?(self.model)
                } else {
                    Toast.showError($0.message)
                }

            },onError: { e in
                Toast.showError(e.asAPIError.errorInfo().message)

            }).disposed(by: self.rx.disposeBag)

        }).disposed(by: rx.disposeBag)
        
        
    }
    
    override func createListView() {
        super.createListView()
        
        addSingleSeparator()
        
        tableView?.register(cellWithClass: UITableViewCell.self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
        cell.textLabel?.text = datas[indexPath.row].name
        cell.accessoryType = datas[indexPath.row].isSelected ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        datas.forEach({
            $0.isSelected = false
        })
        datas[indexPath.row].isSelected.toggle()
        tableView.reloadData()
        saveButton.isEnabled = true
    }

}
