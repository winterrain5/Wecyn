//
//  ProfileController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/8.
//

import UIKit
import ParallaxHeader
enum SectionType: Int {
    case Activity
    case Skills
    case Experience
    case Education
    case Interests
}

class ProfileController: BaseTableController {
    
   
    private var headerView = ProfileHeaderView.loadViewFromNib()
    private let sectionTitleMap:[Int:LocalizerKey] = [0:.Activity,1:.Skills,2:.Experience,3:.Education,4:.Interests]
    private let sectionType:[SectionType] = [.Activity,.Skills,.Experience,.Education,.Interests]
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    var latesdPost:PostListModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        addRightBarItem()
       
        
        self.navigation.bar.alpha = 0
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
        UserService.getUserInfo().subscribe(onNext:{ model in
            UserDefaults.sk.set(object: model, for: UserInfoModel.className)
            self.headerView.userInfoModel = model
            PostService.postList(userId: model.id.int).subscribe(onNext:{
                self.latesdPost = $0.first
                self.tableView?.reloadData()
            }).disposed(by: self.rx.disposeBag)
        }).disposed(by: rx.disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
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
            return self.latesdPost == nil ? 0 : 1
        }
        if section == SectionType.Skills.rawValue { return 0 }
        
        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == SectionType.Activity.rawValue {
            return self.latesdPost?.cellHeight ?? 0
        }
        if indexPath.section == SectionType.Skills.rawValue {
            return 150
        }
        if indexPath.section == SectionType.Experience.rawValue {
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
        if indexPath.section == SectionType.Experience.rawValue { // experience
            let cell = tableView.dequeueReusableCell(withClass: ProfileExperienceItemCell.self)
            return cell
        }
        if indexPath.section == SectionType.Education.rawValue {
            let cell = tableView.dequeueReusableCell(withClass: ProfileEducationItemCell.self)
            return cell
        }
        if indexPath.section == SectionType.Interests.rawValue {
            let cell = tableView.dequeueReusableCell(withClass: ProfileInterestsItemsCell.self)
            return cell
        }
        if indexPath.section == SectionType.Activity.rawValue {
            let cell = tableView.dequeueReusableCell(withClass: HomePostItemCell.self)
            cell.model = self.latesdPost
            return cell
        }
        return UITableViewCell()
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == SectionType.Activity.rawValue {
            if self.latesdPost == nil {
                let view = ProfileNoActivitySectionView()
                return view
            }
            if let title = sectionTitleMap[section] {
                let sectionView = ProfileSectionView(title: title,type: sectionType[section])
                return sectionView
            }
        } else {
            if let title = sectionTitleMap[section] {
                let sectionView = ProfileSectionView(title: title,type: sectionType[section])
                return sectionView
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == SectionType.Activity.rawValue {
            if self.latesdPost == nil {
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let ratio = scrollView.contentOffset.y /  kNavBarHeight
        self.navigation.bar.alpha = ratio
    }
}
