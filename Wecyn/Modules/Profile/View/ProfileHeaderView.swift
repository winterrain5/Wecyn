//
//  ProfileHeaderView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/8.
//

import UIKit

class ProfileHeaderView: UIView {

    @IBOutlet weak var userAvatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var viewNamecardButton: UIButton!
    
    @IBOutlet weak var viewCalendarButton: UIButton!
    
    @IBOutlet weak var addNewSectionButton: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewNamecardButton.titleForNormal = Localizer.localized(for: .view_namecard)
        viewCalendarButton.titleForNormal = Localizer.localized(for: .view_calendar)
        addNewSectionButton.titleForNormal = Localizer.localized(for: .add_new_section)
        
        viewNamecardButton.rx.tap.subscribe(onNext: {
//            NameCardView.showNameCard()
            let vc = EditViewController()
            vc.modalPresentationStyle = .fullScreen
            UIViewController.sk.getTopVC()?.present(vc, animated: true)
        }).disposed(by: rx.disposeBag)
        
        viewCalendarButton.rx.tap.subscribe(onNext:{
            
        }).disposed(by: rx.disposeBag)
        
        addNewSectionButton.rx.tap.subscribe(onNext:{
            
        }).disposed(by: rx.disposeBag)
        
        [viewNamecardButton,viewCalendarButton,addNewSectionButton].forEach({
            $0?.addShadow(cornerRadius: 5)
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
   
    
   
}


