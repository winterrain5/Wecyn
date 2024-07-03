//
//  WorkExpViewController.swift
//  Wecyn
//
//  Created by Derrick on 2024/6/27.
//

import UIKit

class WorkExpViewController: BaseTableController {
    
    

    var workExperiences:[UserExperienceInfoModel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigation.item.title = "Work Experience"

        self.view.isSkeletonable = true
        
        refreshData()
    
        addRightBarItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    func addRightBarItem() {
     
        let add = UIButton()
        add.imageForNormal = R.image.plusCircle()
        add.rx.tap.subscribe(onNext:{ [weak self] in
            let vc = ProfileAddWorkExperienceController()
            vc.profileWorkDataUpdated = {
                self?.refreshData()
            }
            self?.navigationController?.pushViewController(vc)
        }).disposed(by: rx.disposeBag)
        let addItem = UIBarButtonItem(customView: add)
        
        
        self.navigation.item.rightBarButtonItem = addItem
    }
    
    override func createListView() {
        super.createListView()
        self.tableView?.isSkeletonable = true
        
        self.cellIdentifier = ProfileExperienceItemCell.className
        self.tableView?.register(cellWithClass: ProfileExperienceItemCell.self)
        registRefreshHeader(colorStyle: .gray)
        
        
    }
    
    override func refreshData() {
        self.showSkeleton()
        UserService.getUserInfo().subscribe(onNext:{ model in
            UserDefaults.sk.set(object: model, for: UserInfoModel.className)
          
            self.workExperiences = model.work_exp
            self.endRefresh(.NoData, emptyString: "No Work Experience")
            self.hideSkeleton()
            
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype, emptyString: e.asAPIError.errorInfo().message)
            self.hideSkeleton()
        }).disposed(by: rx.disposeBag)
        
    }

 
    
    func deleteUserExperience(_ model:UserExperienceInfoModel) {
        UserService.deleteUserExperience(id: model.id, type: 2).subscribe(onNext:{
            if $0.success == 1 {
                Toast.showSuccess("successfully deleted")
                let row = self.workExperiences.firstIndex(of: model) ?? 0
                let index = IndexPath(row: row, section: 0)
                self.workExperiences.removeAll(where: { $0.id == model.id })
                self.tableView?.deleteRows(at: [index], with: .none)
            } else {
                Toast.showError($0.message)
            }
        }).disposed(by: rx.disposeBag)
    }
    

    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        return self.workExperiences.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      
        return 148
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ProfileExperienceItemCell.self)
        if self.workExperiences.count > 0 {
            cell.model = workExperiences[indexPath.row]
            cell.deleteHandler = { [weak self] in
                self?.deleteUserExperience($0)
            }
            cell.editHandler = { [weak self] in
                let vc = ProfileAddWorkExperienceController(model: $0)
                vc.profileWorkDataUpdated = {  [weak self] in
                    self?.refreshData()
                }
                self?.navigationController?.pushViewController(vc)
            }
            cell.applyForCertificationHandler = { [weak self] in
                let vc = ApplyForCertificationController(model: $0)
                let nav = BaseNavigationController(rootViewController: vc)
                UIViewController.sk.getTopVC()?.present(nav, animated: true)
                vc.updateComplete = {
                    self?.tableView?.reloadData()
                }
            }
        }
        return cell
        
    }

    
  
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ProfileAddWorkExperienceController(model: self.workExperiences[indexPath.row])
        vc.profileWorkDataUpdated = {  [weak self] in
            self?.refreshData()
        }
        self.navigationController?.pushViewController(vc)
        
    }
    



    

}
