//
//  ProfileSectionView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/8.
//

import UIKit

class ProfileSectionView: UIView {
    
    private let title: LocalizerKey!
    private let titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        $0.textColor = R.color.textColor52()!
    }
    
    private lazy var addButton = UIButton()
    private lazy var editButton = UIButton().then({
        $0.imageForNormal = R.image.profile_edit_userinfo()
    })
    
    init(title:LocalizerKey) {
        self.title = title
        
        super.init(frame: .zero)
        
        addSubview(titleLabel)
        titleLabel.text = Localizer.localized(for: title)
        
        if title == .Skills || title == .Experience {
            addSubview(editButton)
            addSubview(addButton)
        }
        
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
        
        if title == .Skills || title == .Experience {
            editButton.snp.makeConstraints { make in
                make.right.equalToSuperview().inset(16)
                make.centerY.equalTo(titleLabel)
                make.height.width.equalTo(32)
            }
            
            addButton.snp.makeConstraints { make in
                make.right.equalTo(editButton.snp.right).inset(16)
                make.centerY.equalTo(titleLabel)
                make.height.width.equalTo(32)
            }
        }
    }
}
