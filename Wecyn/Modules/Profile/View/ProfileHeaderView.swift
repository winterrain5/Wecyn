//
//  ProfileHeaderView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/8.
//

import UIKit
import ImagePickerSwift
class ProfileHeaderView: UIView {

    @IBOutlet weak var backImgView: UIImageView!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var viewNamecardButton: UIButton!
    
    @IBOutlet weak var viewCalendarButton: UIButton!
    
    @IBOutlet weak var addNewSectionButton: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    
    var uplodaImageComplete:(()->())?
    var userInfoModel: UserInfoModel? {
        didSet {
            guard let userInfoModel = userInfoModel else { return }
            
            nameLabel.text = userInfoModel.first_name + " " + userInfoModel.last_name
            jobTitleLabel.text = userInfoModel.org_name + "-" + userInfoModel.title
            userAvatarImageView.kf.setImage(with: userInfoModel.avatar.url)
            backImgView.kf.setImage(with: userInfoModel.cover.url)
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewNamecardButton.titleForNormal = Localizer.localized(for: .view_namecard)
        viewCalendarButton.titleForNormal = Localizer.localized(for: .view_calendar)
        addNewSectionButton.titleForNormal = Localizer.localized(for: .add_new_section)
        
        viewNamecardButton.rx.tap.subscribe(onNext: {
            let vc = NFCNameCardController()
            UIViewController.sk.getTopVC()?.navigationController?.pushViewController(vc)
        }).disposed(by: rx.disposeBag)
        
        viewCalendarButton.rx.tap.subscribe(onNext:{
            let vc = CalendarEventController()
            UIViewController.sk.getTopVC()?.navigationController?.pushViewController(vc)
        }).disposed(by: rx.disposeBag)
        
        addNewSectionButton.rx.tap.subscribe(onNext:{
//            let vc = NFCController()
//            UIViewController.sk.getTopVC()?.navigationController?.pushViewController(vc)
        }).disposed(by: rx.disposeBag)
        
        [viewNamecardButton,viewCalendarButton,addNewSectionButton].forEach({
            $0?.addShadow(cornerRadius: 5)
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
   
  
   
}


