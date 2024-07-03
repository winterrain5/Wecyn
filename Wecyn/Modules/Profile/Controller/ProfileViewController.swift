//
//  ProfileViewController.swift
//  Wecyn
//
//  Created by Derrick on 2024/6/26.
//

import UIKit

struct ProfileModel {
    var image:UIImage?
    var title:String
    var action:String
}

class ProfileViewController: BaseTableController {
    
    let headView = ProfileHeaderView.loadViewFromNib()
    
    var profileData:[[ProfileModel]] = [
        
        [
            ProfileModel(image: UIImage(systemName: "person.text.rectangle.fill"), title: "我的名片".innerLocalized(), action: "myCards"),
            ProfileModel(image: UIImage(systemName: "paperplane.fill"), title: "最近发布".innerLocalized(), action: "activityAction"),
            ProfileModel(image: UIImage(systemName: "macbook.and.iphone"), title: "工作经历".innerLocalized(), action: "workAction"),
            ProfileModel(image: UIImage(systemName: "graduationcap.fill"), title: "教育经历".innerLocalized(), action: "educationAction")
        ],
        [ProfileModel(image: UIImage(systemName:  "gearshape.fill"), title: "设置".innerLocalized(), action: "settingAction")]
        
    ]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let admin =  [ProfileModel(image: UIImage(systemName: "network"), title: "Admin", action: "adminAction")]
        let isAdmin = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)?.is_admin ?? 0
        if isAdmin == 1{
            profileData.insert(admin, at: 0)
        }
        
        self.view.isSkeletonable = true
        
        self.navigation.item.title = "Profile"
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UpdateUserInfo, object: nil, queue: OperationQueue.main) { _ in
            self.refreshData()
        }
        
        refreshData()
    }
    
    override func refreshData() {
        UserService.getUserInfo().subscribe(onNext:{ model in
            UserDefaults.sk.set(object: model, for: UserInfoModel.className)
            self.headView.userInfoModel = model
            self.endRefresh()
        },onError: { e in
            Toast.showError(e.localizedDescription)
        }).disposed(by: rx.disposeBag)
    }
    
    
    override func createListView() {
        configTableview(.insetGrouped)
        
        tableView?.isSkeletonable = true
        
        tableView?.tableHeaderView = headView
        headView.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
                let vc = NFCNameCardController()
            self?.navigationController?.pushViewController(vc)
        }).disposed(by: rx.disposeBag)
        headView.size = CGSize(width: kScreenWidth, height: 232)
        
        tableView?.backgroundColor = R.color.backgroundColor()
        
        registRefreshHeader(colorStyle: .gray)
    }
    
    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight - kTabBarHeight)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        profileData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        profileData[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.accessoryType = .disclosureIndicator
        let model = profileData[indexPath.section][indexPath.row]
        
        cell.imageView?.image = model.image?.withTintColor(.black).withRenderingMode(.alwaysOriginal)
        cell.textLabel?.text = model.title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = profileData[indexPath.section][indexPath.row]
        let sel = Selector(model.action)
        
        if responds(to: sel) {
            perform(sel)
        }
        
        
        
    }
    
    @objc func myCards() {
        let vc = NFCNameCardController()
        self.navigationController?.pushViewController(vc)
    }
    
    @objc func adminAction() {
        let  vc = AdminController()
        self.navigationController?.pushViewController(vc)
    }
    
    
    @objc func activityAction() {
        guard let id = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)?.id.int else {
            return
        }
        let vc = PostUserInfoController(userId: id)
        self.navigationController?.pushViewController(vc)
    }
    
    
    @objc func workAction() {
        let vc = WorkExpViewController()
        self.navigationController?.pushViewController(vc)
    }
    
    
    @objc func educationAction() {
        let vc = EduExpViewController()
        self.navigationController?.pushViewController(vc)
    }
    
    
    @objc func settingAction() {
        let vc = SettingController()
        self.navigationController?.pushViewController(vc)
    }
    
}
