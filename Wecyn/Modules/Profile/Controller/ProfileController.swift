//
//  ProfileController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/8.
//

import UIKit
import ParallaxHeader
class ProfileController: BaseTableController {
    
    enum SectionType: Int {
        case Activity
        case Skills
        case Experience
        case Education
        case Interests
    }

    private var headerView = ProfileHeaderView.loadViewFromNib()
    private let sectionTitleMap:[Int:LocalizerKey] = [0:.Activity,1:.Skills,2:.Experience,3:.Education,4:.Interests]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addRightBarItem()
       
        getUserInfo()
        
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
        headerView.uplodaImageComplete = { [weak self] in
            guard let `self` = self else { return }
            self.getUserInfo()
        }

        self.tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kTabBarHeight + 10, right: 0)
        self.tableView?.register(cellWithClass: ProfileSkillsItemCell.self)
        self.tableView?.register(cellWithClass: ProfileExperienceItemCell.self)
        self.tableView?.register(cellWithClass: ProfileInterestsItemsCell.self)
        self.tableView?.register(cellWithClass: ProfileEducationItemCell.self)
        
        
    }
    
    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - kTabBarHeight)
    }

    func getUserInfo() {
        UserService.getUserInfo().subscribe(onNext:{ model in
            UserDefaults.sk.set(object: model, for: UserInfoModel.className)
            self.headerView.userInfoModel = model
        }).disposed(by: rx.disposeBag)
    }
 

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SectionType.Activity.rawValue { return 0 }
        if section == SectionType.Skills.rawValue { return 1 }
        
        return 2
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
        return UITableViewCell()
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == SectionType.Activity.rawValue {
            let view = ProfileNoActivitySectionView()
            return view
        } else {
            if let title = sectionTitleMap[section] {
                let sectionView = ProfileSectionView(title: title)
                return sectionView
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == SectionType.Activity.rawValue {
            return 88
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
