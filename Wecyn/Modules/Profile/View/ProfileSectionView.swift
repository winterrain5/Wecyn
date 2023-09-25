//
//  ProfileSectionView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/8.
//

import UIKit

class ProfileSectionView: UIView {
    
    private var title: LocalizerKey!
    private var type: SectionType!
    private let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        $0.textColor = R.color.textColor33()!
    }
    
    private lazy var addButton = UIButton()
    private lazy var editButton = UIButton()
    
    required init(title:LocalizerKey,type:SectionType) {
        super.init(frame: .zero)
        
        self.title = title
        self.type = type
        
        addSubview(titleLabel)
        titleLabel.text = Localizer.localized(for: title)
        
        
        addSubview(editButton)
        addSubview(addButton)
        
        if type == .Activity {
            editButton.imageForNormal = R.image.chevronRight()?.scaled(toHeight: 12)
            editButton.titleForNormal = "More"
        } else {
            editButton.imageForNormal = R.image.squareAndPencil()
            editButton.titleForNormal = ""
        }
        
        editButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            if self.type == .Activity {
                let user = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)
                let vc = PostUserInfoController(userId: user?.id.int ?? 0)
                UIViewController.sk.getTopVC()?.navigationController?.pushViewController(vc)
            }
        }).disposed(by: rx.disposeBag)
        
        editButton.titleColorForNormal = R.color.iconColor()
        editButton.titleLabel?.font = UIFont.sk.pingFangRegular(14)
        editButton.sk.setImageTitleLayout(.imgRight,spacing: 6)
        backgroundColor = .white
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(25)
            make.top.equalToSuperview().offset(14)
            make.height.equalTo(21)
        }
        
        editButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalTo(titleLabel)
            make.height.equalTo(32)
        }
        
        addButton.snp.makeConstraints { make in
            make.right.equalTo(editButton.snp.right).inset(16)
            make.centerY.equalTo(titleLabel)
            make.height.equalTo(32)
        }
    }
}
