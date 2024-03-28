//
//  SettingSwitchCell.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/27.
//

import UIKit

enum Settingtype {
    case pin
    case mute
    case clear
    case none
}

class ChatSettingModel {
    var title:String = ""
    var type: Settingtype = .none
    var isOn:Bool = false
    var hasSwitch = false
    var hasArrow = false
    
    init(title: String, type: Settingtype = .none, isOn: Bool = false, hasSwitch: Bool = false, hasArrow: Bool = false) {
        self.title = title
        self.type = type
        self.isOn = isOn
        self.hasSwitch = hasSwitch
        self.hasArrow = hasArrow
    }
}

class ChatSettingCell: UITableViewCell {

    var titleLabel = UILabel().font(.systemFont(ofSize: 16)).color(.black)
    var switchControl = UISwitch()
    var statusChanged: ((ChatSettingModel)->())?
    var model:ChatSettingModel! {
        didSet {
            titleLabel.text = model.title
            switchControl.isOn = model.isOn
            
            switchControl.isHidden = !model.hasSwitch
            accessoryType = model.hasArrow ? .disclosureIndicator : .none
            
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchControl)
        switchControl.rx.controlEvent(.valueChanged).subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.model.isOn = self.switchControl.isOn
            self.statusChanged?(self.model)
        }).disposed(by: rx.disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        switchControl.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }
    
}
