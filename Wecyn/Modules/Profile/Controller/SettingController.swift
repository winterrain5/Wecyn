//
//  SettingController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/8.
//

import UIKit
enum SettingType {
    case Logout
    case Language
    case ColorRemark
    case Privacy
    case About
    case Contact
    case Notification
    case Account
    case TimeZone
    case Haptico
}
class SettingModel {
    
    var title:String
    var detail:String
    var type:SettingType
    init(title: String, type: SettingType, detail: String = "") {
        self.title = title
        self.detail = detail
        self.type = type
        
    }
}

class SettingController: BaseTableController {
    var datas:[[SettingModel]] = []
    
    private var footerView = UIView().then { view in
        view.backgroundColor = R.color.backgroundColor()
        
        let versionLabel = UILabel()
        let infoDictionary = Bundle.main.infoDictionary!
        let majorVersion = infoDictionary["CFBundleShortVersionString"] as? String ?? ""//主程序版本号
        
        versionLabel.text = "版本号".innerLocalized() + "\(majorVersion)\nTerra Systems Pte Ltd"
        versionLabel.font = UIFont.sk.pingFangRegular(14)
        versionLabel.textColor = UIColor(hexString: "828282")
        versionLabel.numberOfLines = 2
        versionLabel.textAlignment = .center
        view.addSubview(versionLabel)
        
        versionLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigation.item.title = "设置".innerLocalized()
        
        
        // general preference
        let notification = SettingModel(title: "通知".innerLocalized(), type: .Notification)
        let language = SettingModel(title: "语言".innerLocalized(), type: .Language,detail: getCurrentLanguage())
        let colorRemark = SettingModel(title: "颜色备注".innerLocalized(), type: .ColorRemark)
        let timezone = SettingModel(title: "时区".innerLocalized(), type: .TimeZone,detail: getTimezone())
        let haptico = SettingModel(title: "震动反馈".innerLocalized(), type: .Haptico)
        datas.append([notification,language,colorRemark,timezone,haptico])
        
//        let account = SettingModel(title: "账户管理".innerLocalized(), type: .Account)
//        datas.append([account])
        
        let privacy = SettingModel(title: "隐私协议".innerLocalized(), type: .Privacy)
        let about = SettingModel(title: "关于Wecyn".innerLocalized(), type: .About)
        let contact = SettingModel(title: "联系我们".innerLocalized(), type: .Contact)
        
        datas.append([privacy,about,contact])
        
       
        
        let logout = SettingModel(title: "登出".innerLocalized(), type: .Logout)
        datas.append([logout])
    }
    func getTimezone() -> String {
  
        let tz = TimeZone.current.secondsFromGMT() / 3600
        
        let name = TimeZone.current.identifier
        if tz > 0 {
            return name + "\nUTC+\(tz)"
        } else {
            return name + "\nUTC-\(tz)"
        }
        
    }
    
    func getCurrentLanguage() -> String {
        let preferredLang = Bundle.main.preferredLocalizations.first! as NSString
        
        switch String(describing: preferredLang) {
        case "en-US", "en-CN", "en":
            return "English"//英文
        case "zh-Hans-US","zh-Hans-CN","zh-Hant-CN","zh-TW","zh-HK","zh-Hans":
            return "简体中文"//中文
        default:
            return "English"
        }
    }
    
    override func createListView() {
        configTableview(.insetGrouped)
        
        tableView?.register(cellWithClass: SettingCell.self)
        tableView?.backgroundColor = R.color.backgroundColor()
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorStyle = .singleLine
        tableView?.rowHeight = 52
        
        tableView?.tableFooterView = footerView
        footerView.size = CGSize(width: kScreenWidth, height: 120)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return  datas.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: SettingCell.self)
        let model = datas[indexPath.section][indexPath.row]
        cell.model = model
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let model = datas[indexPath.section][indexPath.row]
        
        if model.type == .Language {
            let vc = LanguageSettingController()
            self.navigationController?.pushViewController(vc)
        }
        
        if model.type == .ColorRemark {
            let vc = ColorPickerController(selectColor: nil, isAllowEdit: true, action: nil)
            self.navigationController?.pushViewController(vc)
        }
        
        if model.type == .Privacy {
            let vc = WebBrowserController(url: "https://www.terra-systems.com/#/")
            self.navigationController?.pushViewController(vc)
        }
        
        if model.type == .About {
            let vc = WebBrowserController(url: "https://www.terra-systems.com/#/establishment")
            self.navigationController?.pushViewController(vc)
        }
        
        if model.type == .Contact {
            let vc = WebBrowserController(url: "https://www.terra-systems.com/#/contact_us")
            self.navigationController?.pushViewController(vc)
        }
        
        if model.type == .Logout {
            
            func toLoginVc()  {
                Toast.dismiss()
                UserDefaults.sk.removeAllKeyValue()
                let nav = BaseNavigationController(rootViewController: LoginController())
                UIApplication.shared.keyWindow?.rootViewController = nav
            }
            
            let alert = UIAlertController(title: "你确定要登出吗？".innerLocalized(), message: nil, preferredStyle: .actionSheet)
            alert.addAction(title: "确认".innerLocalized(),style: .destructive) { _ in
                Toast.showLoading()
                IMController.shared.logout {
                    toLoginVc()
                } error: { e in
                    toLoginVc()
                    Toast.showError(e.asAPIError.errorInfo().message)
                    print(e.asAPIError.errorInfo().message)
                }

             
            }
            alert.addAction(title: "取消".innerLocalized(),style: .cancel)
            alert.show()
            
        }
        
    }
    
    
    
}

class SettingCell:UITableViewCell {
    var model:SettingModel! {
        didSet {
         
            titleLabel.textAlignment = .left
            accessoryType = .disclosureIndicator
            switch model.type {
            case .Logout:
                titleLabel.textAlignment = .center
                accessoryType = .none
                switchControl.isHidden = true
            case .Haptico:
                switchControl.isOn = UserDefaults.sk.value(for: UserdefaultKeys.HapticoEnableKey) as? Bool ?? false
                switchControl.isHidden = false
                
                accessoryType = .none
            default:
                switchControl.isHidden = true
                break
            }
            titleLabel.text = model.title
            detailLabel.text = model.detail
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    var titleLabel = UILabel()
    var detailLabel = UILabel()
    var switchControl = UISwitch()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        titleLabel.textColor = R.color.textColor33()
        titleLabel.font = UIFont.sk.pingFangSemibold(16)
        
        contentView.addSubview(detailLabel)
        detailLabel.textColor = R.color.textColor77()
        detailLabel.font = UIFont.sk.pingFangRegular(14)
        detailLabel.textAlignment = .right
        detailLabel.numberOfLines = 2
        
        contentView.addSubview(switchControl)
        switchControl.rx.controlEvent(.valueChanged).subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
           
            if self.model.type == .Haptico {
                UserDefaults.sk.set(value: self.switchControl.isOn, for: UserdefaultKeys.HapticoEnableKey)
            }
            
        }).disposed(by: rx.disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if model.type == .Logout {
            titleLabel.snp.makeConstraints { make in
                make.left.right.top.bottom.equalToSuperview()
            }
        } else {
            titleLabel.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(16)
                make.centerY.equalToSuperview()
            }
            detailLabel.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-16)
                make.centerY.equalToSuperview()
            }
            switchControl.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-16)
                make.centerY.equalToSuperview()
            }
        }
        
        
    }
}
