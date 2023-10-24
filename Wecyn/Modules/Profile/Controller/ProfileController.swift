//
//  ProfileController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/8.
//

import UIKit
import ParallaxHeader
import PromiseKit
enum SectionType: Int {
    case Activity
    case Skills
    case Work
    case Education
    case Interests
}

class ProfileController: BaseTableController {
    
   
    private var headerView = ProfileHeaderView.loadViewFromNib()
    private let sectionTitleMap:[Int:LocalizerKey] = [0:.Activity,1:.Skills,2:.Experience,3:.Education,4:.Interests]
    private let sectionType:[SectionType] = [.Activity,.Skills,.Work,.Education,.Interests]
    override var preferredStatusBarStyle: UIStatusBarStyle { self.ratio == 0 ? .lightContent : .darkContent }
    var ratio:CGFloat = 0
    var userPosts:[PostListModel] =  []
    var workExperiences:[UserExperienceInfoModel] = []
    var eduExperiences:[UserExperienceInfoModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        addRightBarItem()
       
        
        self.navigation.bar.alpha = 0
        
        refreshData()
    }
    
    func addRightBarItem() {
     
        let setting = UIButton()
        setting.imageForNormal = R.image.gearshape()
        setting.rx.tap.subscribe(onNext:{
            let vc = SettingController()
            self.navigationController?.pushViewController(vc)
        }).disposed(by: rx.disposeBag)
        let settingItem = UIBarButtonItem(customView: setting)
        
        self.navigation.item.rightBarButtonItem = settingItem
    }
    
    override func createListView() {
        
        configTableview(.grouped)
    
        self.tableView?.tableHeaderView = headerView
        headerView.size = CGSize(width: kScreenWidth, height: 320)
   

        self.tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kTabBarHeight + 10, right: 0)
        self.tableView?.register(cellWithClass: HomePostItemCell.self)
        self.tableView?.register(cellWithClass: ProfileSkillsItemCell.self)
        self.tableView?.register(cellWithClass: ProfileExperienceItemCell.self)
        self.tableView?.register(cellWithClass: ProfileInterestsItemsCell.self)
        self.tableView?.register(cellWithClass: ProfileEducationItemCell.self)
        registRefreshHeader(colorStyle: .gray)
        
    }
    
    override func refreshData() {
        getUserInfo().then({
            self.getUserPost()
        }).done {
            self.endRefresh()
        }.catch { e in
            print(e)
        }
        
    }
    @discardableResult
    func getUserPost() -> Promise<Void>{
        return Promise.init { resolver in
            PostService.postList().subscribe(onNext:{
                self.userPosts = $0
                self.tableView?.reloadData()
                resolver.fulfill_()
            },onError: { e in
                resolver.reject(APIError.networkError(e))
            }).disposed(by: self.rx.disposeBag)
        }
       
    }
    @discardableResult
    func getUserInfo() -> Promise<Void>{
        return Promise.init { resolver in
            UserService.getUserInfo().subscribe(onNext:{ model in
                UserDefaults.sk.set(object: model, for: UserInfoModel.className)
                self.headerView.userInfoModel = model
                self.workExperiences = model.work_exp
                self.eduExperiences = model.edu_exp
                self.tableView?.reloadData()
                resolver.fulfill_()
            },onError: { e in
                resolver.reject(APIError.networkError(e))
            }).disposed(by: rx.disposeBag)
        }
        
    }
    
    func deleteUserExperience(_ model:UserExperienceInfoModel,type:Int) {
        UserService.deleteUserExperience(id: model.id, type: type).subscribe(onNext:{
            if $0.success == 1 {
                Toast.showSuccess("successfully deleted")
                if type == 1 {
                    let row = self.eduExperiences.firstIndex(of: model) ?? 0
                    let index = IndexPath(row: row, section: 3)
                    self.eduExperiences.removeAll(model)
                    self.tableView?.deleteRows(at: [index], with: .none)
                } else {
                    let row = self.workExperiences.firstIndex(of: model) ?? 0
                    let index = IndexPath(row: row, section: 2)
                    self.workExperiences.removeAll(model)
                    self.tableView?.deleteRows(at: [index], with: .none)
                }
            } else {
                Toast.showError($0.message)
            }
        }).disposed(by: rx.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - kTabBarHeight)
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SectionType.Activity.rawValue {
            return self.userPosts.first == nil ? 0 : 1
        }
        if section == SectionType.Skills.rawValue { return 0 }
        if section == SectionType.Work.rawValue { return self.workExperiences.count }
        if section == SectionType.Education.rawValue { return self.eduExperiences.count }
        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == SectionType.Activity.rawValue {
            return self.userPosts.first?.cellHeight ?? 0
        }
        if indexPath.section == SectionType.Skills.rawValue {
            return 150
        }
        if indexPath.section == SectionType.Work.rawValue {
            return 115
        }
        if indexPath.section == SectionType.Education.rawValue {
            return 115
        }
        if indexPath.section == SectionType.Interests.rawValue {
            return 75
        }
        return 44
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SectionType.Skills.rawValue{ // skill
            let cell = tableView.dequeueReusableCell(withClass: ProfileSkillsItemCell.self)
            return cell
        }
        if indexPath.section == SectionType.Work.rawValue { // experience
            let cell = tableView.dequeueReusableCell(withClass: ProfileExperienceItemCell.self)
            if self.workExperiences.count > 0 {
                cell.model = workExperiences[indexPath.row]
                cell.deleteHandler = { [weak self] in
                    self?.deleteUserExperience($0, type: 2)
                }
                cell.editHandler = { [weak self] in
                    let vc = ProfileAddWorkExperienceController(model: $0)
                    vc.profileWorkDataUpdated = {  [weak self] in
                        self?.getUserInfo()
                    }
                    self?.navigationController?.pushViewController(vc)
                }
            }
            return cell
        }
        if indexPath.section == SectionType.Education.rawValue {
            let cell = tableView.dequeueReusableCell(withClass: ProfileEducationItemCell.self)
            if self.eduExperiences.count > 0 {
                cell.model = eduExperiences[indexPath.row]
                cell.deleteHandler = { [weak self] in
                    self?.deleteUserExperience($0, type: 1)
                }
                cell.editHandler = { [weak self] in
                    let vc = ProfileAddEduExperienceController(model: $0)
                    vc.profileEduDataUpdated = {  [weak self] in
                        self?.getUserInfo()
                    }
                    self?.navigationController?.pushViewController(vc)
                }
            }
            return cell
        }
        if indexPath.section == SectionType.Interests.rawValue {
            let cell = tableView.dequeueReusableCell(withClass: ProfileInterestsItemsCell.self)
            return cell
        }
        if indexPath.section == SectionType.Activity.rawValue {
            let cell = tableView.dequeueReusableCell(withClass: HomePostItemCell.self)
            cell.model = self.userPosts.first
            cell.userInfoView.updatePostType = { [weak self] _ in
                self?.tableView?.reloadData()
            }
            cell.userInfoView.deleteHandler = { [weak self] _ in
                self?.deletePost()
            }
            return cell
        }
        return UITableViewCell()
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == SectionType.Activity.rawValue {
            if self.userPosts.first == nil {
                let view = ProfileNoActivitySectionView()
                view.createPostBtn.rx.tap.subscribe(onNext:{ [weak self] in
                    guard let `self` = self else { return }
                    let vc = CreatePostViewController()
                    let nav = BaseNavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    UIViewController.sk.getTopVC()?.present(nav, animated: true)
                    vc.addCompleteHandler = {
                        self.userPosts.insert($0, at: 0)
                        self.tableView?.reloadData()
                    }
                }).disposed(by: self.rx.disposeBag)
                return view
            }
            if let title = sectionTitleMap[section] {
                let sectionView = ProfileSectionView(title: title,type: sectionType[section])
                return sectionView
            }
        } else {
            if let title = sectionTitleMap[section] {
                let sectionView = ProfileSectionView(title: title,type: sectionType[section])
                sectionView.profileAddDataHandler = { [weak self] type in
                    switch type {
                    case .Work:
                        let vc = ProfileAddWorkExperienceController()
                        vc.profileWorkDataUpdated = {  [weak self] in
                            self?.getUserInfo()
                        }
                        self?.navigationController?.pushViewController(vc)
                    case .Education:
                        let vc = ProfileAddEduExperienceController()
                        vc.profileEduDataUpdated = {  [weak self] in
                            self?.getUserInfo()
                        }
                        self?.navigationController?.pushViewController(vc)
                    default:
                        print(type)
                    }
                }
                return sectionView
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == SectionType.Activity.rawValue {
            if self.userPosts.first == nil {
                return 88
            }
            return 42
        }
        return 42
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let line = UIView().backgroundColor(UIColor(hexString: "#d9d9d9")!).frame(.init(x: 16, y: 0, width: kScreenWidth - 32, height: 1))
        let container = UIView()
        container.addSubview(line)
        return container
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == SectionType.Interests.rawValue ? 0 : 1
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section  == 0 {
            guard let model = userPosts.first else { return }
            let vc = PostDetailViewController(postModel: model)
            self.navigationController?.pushViewController(vc)
            vc.deletePostFromDetailComplete = { [weak self] _ in
                self?.deletePost()
            }
        }
        
    }
    
    func deletePost() {
        if self.userPosts.count > 0 {
            self.userPosts.remove(at: 0)
            self.tableView?.reloadData()
            if self.userPosts.count == 0 {
                self.refreshData()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        ratio = scrollView.contentOffset.y /  kNavBarHeight
        self.navigation.bar.alpha = ratio
        setNeedsStatusBarAppearanceUpdate()
        
    }
}
