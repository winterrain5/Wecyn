//
//  LanguageSettingController.swift
//  Wecyn
//
//  Created by Derrick on 2023/8/4.
//

import UIKit

class LanguageSettingController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel()
        label.textColor = R.color.textColor52()
        label.numberOfLines = 0
        label.font = UIFont.sk.pingFangRegular(15)
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(32 + kNavBarHeight)
        }
        
        
        label.text = currentLanguageSetting()
    }
    
    func currentLanguageSetting() -> String {
        let preferredLang = Bundle.main.preferredLocalizations.first! as NSString
        
        switch String(describing: preferredLang) {
        case "en-US", "en-CN", "en":
            return "The Wecyn app uses the same language that is currently set on your device\n\nYour language setting is currently set to English. If you've accidentally changed the language to one you don't understand, do the following:\n· Go to home screen of your device.\n·Open device Settings.\n· Search for the Language setting.\n· Pick a Language from the list.\n· Confirm your selection.\n\nOnce the language setting on the device has changed, the Wecyn App will automatically update the language.";
        case "zh-Hans-US","zh-Hans-CN","zh-Hant-CN","zh-TW","zh-HK","zh-Hans":
            return "Wecyn APP 使用的语言与您设备上当前设置的语言相同\n您的语言设置为简体中文．如果您不小心将语言更改为您不掌握的语言，请执行以下操作：\n\n· 前往设备的主屏幕。\n· 打开设备设置。\n· 搜索语言设置。\n· 从列表中选择一种语言。\n· 确认选择。\n\n如果设备上的语言设置发生更改，Wecyn APP 将自动更新语言。";
        default:
            return "The Wecyn app uses the same language that is currently set on your device\n\nYour language setting is currently set to English. If you've accidentally changed the language to one you don't understand, do the following:\n· Go to home screen of your device.\n·Open device Settings.\n· Search for the Language setting.\n· Pick a Language from the list.\n· Confirm your selection.\n\nOnce the language setting on the device has changed, the Wecyn App will automatically update the language.";
        }
    }
    
    
}
