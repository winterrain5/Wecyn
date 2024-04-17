//
//  ProfileController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/8.
//

import UIKit
import ParallaxHeader
import PromiseKit
import ImagePickerSwift
import PaddleOCR
import Photos
enum SectionType: Int {
    case Activity
    case Work
    case Education
    case Skills
    case Interests
}

class ProfileController: BaseTableController {
    
   
    private var headerView = ProfileHeaderView.loadViewFromNib()
    private let sectionTitleMap:[Int:LocalizerKey] = [0:.Activity,1:.Experience,2:.Education]
    private let sectionTypes:[SectionType] = [.Activity,.Work,.Education]
    override var preferredStatusBarStyle: UIStatusBarStyle { self.ratio <= 0 ? .lightContent : .darkContent }
    var ratio:CGFloat = 0
    var userPosts:[PostListModel] =  []
    var workExperiences:[UserExperienceInfoModel] = []
    var eduExperiences:[UserExperienceInfoModel] = []
    private lazy var _photoHelper: PhotoHelper = {
        let v = PhotoHelper()
        v.setConfigToPickCard()
        v.didPhotoSelected = { [weak self, weak v] (images: [UIImage], assets: [PHAsset], _: Bool) in
            guard let self else { return }
            
            for (index, asset) in assets.enumerated() {
                switch asset.mediaType {
                case .image:
                    
                    let vc = AddNewBusinessCardController(image: images[index])
                    self.navigationController?.pushViewController(vc)
                    
                default:
                    break
                }
            }
        }

        v.didCameraFinished = { [weak self] (photo: UIImage?, videoPath: URL?) in
            guard let self else { return }
            
            if let photo {
                
                let vc = AddNewBusinessCardController(image: photo)
                self.navigationController?.pushViewController(vc)
                
            }
        }
        return v
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addRightBarItem()
       
        
        self.navigation.bar.alpha = 0
        
        refreshData()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UpdateUserInfo, object: nil, queue: OperationQueue.main) { _ in
            self.refreshData()
        }
        
    }
    
    func addRightBarItem() {
     
        let setting = UIButton()
        setting.imageForNormal = R.image.gearCircleFill()
        setting.rx.tap.subscribe(onNext:{
            let vc = SettingController()
            self.navigationController?.pushViewController(vc)
        }).disposed(by: rx.disposeBag)
        let settingItem = UIBarButtonItem(customView: setting)
        
        
        let fixItem = UIBarButtonItem.fixedSpace(width: 22)
        
        let scan = UIButton()
        scan.imageForNormal = R.image.viewfinderCircleFill()
        scan.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            
            
            
            let alert = UIAlertController.init(title: "Scan BusinessCard", message: "Select photo from camera or photolibrary", preferredStyle: .actionSheet)
            
            alert.addAction(title: "Camera",style: .destructive) { _ in
                self.showImagePickerController(sourceType: .camera)
            }
            alert.addAction(title: "PhotoLibrary",style: .destructive) { _ in
                self.showImagePickerController(sourceType: .photoLibrary)
            }
            
            
            alert.addAction(title: "Cancel",style: .cancel)
            
            alert.show()
           
            
        
        }).disposed(by: rx.disposeBag)
        let scanItem = UIBarButtonItem(customView: scan)
        
        self.navigation.item.rightBarButtonItems = [settingItem,fixItem,scanItem]
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
                    let index = IndexPath(row: row, section: SectionType.Education.rawValue)
                    self.eduExperiences.removeAll(model)
                    self.tableView?.deleteRows(at: [index], with: .none)
                } else {
                    let row = self.workExperiences.firstIndex(of: model) ?? 0
                    let index = IndexPath(row: row, section: SectionType.Work.rawValue)
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
        return 3
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
            cell.footerView.likeHandler = { [weak self] in
                self?.updateRow($0)
            }
            cell.footerView.commentHandler = { [weak self] in
                guard let `self` = self else { return }
                let vc = PostDetailViewController(postModel: $0,isBeginEdit: true)
                self.navigationController?.pushViewController(vc)
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
                let sectionView = ProfileSectionView(title: title,type: sectionTypes[section])
                return sectionView
            }
        } else {
            if let title = sectionTitleMap[section] {
                let sectionView = ProfileSectionView(title: title,type: sectionTypes[section])
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
        if indexPath.section  == SectionType.Activity.rawValue {
            guard let model = userPosts.first else { return }
            let vc = PostDetailViewController(postModel: model)
            self.navigationController?.pushViewController(vc)
            vc.deletePostFromDetailComplete = { [weak self] _ in
                self?.deletePost()
            }
        }
        
        if indexPath.section ==  SectionType.Education.rawValue {
            let vc = ProfileAddEduExperienceController(model: self.eduExperiences[indexPath.row])
            vc.profileEduDataUpdated = {  [weak self] in
                self?.getUserInfo()
            }
            self.navigationController?.pushViewController(vc)
        }
        
        if indexPath.section ==  SectionType.Work.rawValue {
            let vc = ProfileAddWorkExperienceController(model: self.workExperiences[indexPath.row])
            vc.profileWorkDataUpdated = {  [weak self] in
                self?.getUserInfo()
            }
            self.navigationController?.pushViewController(vc)
        }
        
    }
    
    func updateRow(_ model:PostListModel) {
        let item = userPosts.firstIndex(of: model) ?? 0
        self.tableView?.reloadRows(at: [IndexPath(item: item, section: SectionType.Activity.rawValue)], with: .none)
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
    
    private func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        if case .camera = sourceType {
            _photoHelper.presentCamera(byController: UIViewController.sk.getTopVC()!)
        } else {
            _photoHelper.presentPhotoLibrary(byController: UIViewController.sk.getTopVC()!)
        }
    }
    
   
}
