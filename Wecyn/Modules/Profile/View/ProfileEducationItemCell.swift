//
//  ProfileEducationItemCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/12.
//

import UIKit

class ProfileEducationItemCell: UITableViewCell {
    let shadowView = UIView()
    private let imgView = UIImageView()
    private let schoolLabel = UILabel().then { label in
        label.text = "Nanyang Polytechnic"
        label.textColor = R.color.textColor33()
        label.font = UIFont.sk.pingFangSemibold(16)
        label.isSkeletonable = true
    }
    private let majorLabel =  UILabel().then { label in
        label.text = "High School Diploma, \nInteraction Design"
        label.numberOfLines = 1
        label.textColor = R.color.textColor33()
        label.font = UIFont.sk.pingFangRegular(13)
        label.isSkeletonable = true
    }
    private let timeLabel =  UILabel().then { label in
        label.text = "2016-2019"
        label.textColor = R.color.textColor33()
        label.font = UIFont.sk.pingFangRegular(12)
        label.isSkeletonable = true
    }
    private let descLabel =  UILabel().then { label in
        label.textColor = R.color.textColor33()
        label.font = UIFont.sk.pingFangRegular(12)
        label.isSkeletonable = true
    }
    let moreButton = UIButton().then { button in
        button.imageForNormal = UIImage.ellipsis?.withTintColor(R.color.iconColor()!,renderingMode: .alwaysOriginal).scaled(toWidth: 18)
        button.contentHorizontalAlignment = .right
        button.showsMenuAsPrimaryAction  = true
        button.isSkeletonable = true
    }
    
    let certImgView = UIImageView()
    var certImgViewWH:CGFloat = 0
    
    var deleteHandler:((UserExperienceInfoModel)->())?
    var editHandler:((UserExperienceInfoModel)->())?
    var applyForCertificationHandler:((UserExperienceInfoModel)->())?
    var model:UserExperienceInfoModel? {
        didSet {
            guard let model = model else { return }
            
            if model.org_avatar.url == nil {
                imgView.contentMode = .center
                imgView.image = R.image.edu_placeholder()
            } else {
                imgView.contentMode = .scaleAspectFit
                imgView.kf.setImage(with: model.org_avatar.url)
            }
            
            schoolLabel.text = model.org_name
            majorLabel.text = model.degree_name + " " + model.field_name
            timeLabel.text = model.start_date_format + " - " + (model.is_current == 1 ? "Present" : model.end_date_format)
            descLabel.text = model.desc
            
            
            let action0 = UIAction(title: "Apply for certification",image: R.image.checkmarkSealFill()?.scaled(toWidth: 20)!) {  [weak self]  _ in
                guard let `self` = self,let model = self.model else { return }
                self.applyForCertificationHandler?(model)
            }
            let action1 = UIAction(title: "Edit",image: R.image.pencilLine()!) { [weak self] _ in
                guard let `self` = self,let model = self.model else { return }
                self.editHandler?(model)
            }
            let action2 = UIAction(title: "Delete",image: UIImage.trash?.tintImage(.red),attributes: .destructive) { [weak self] _ in
                guard let `self` = self,let model = self.model else { return }
                self.deleteHandler?(model)
            }
            
            // 必须有org_id且必须在职（is_current=1）
            moreButton.isHidden =  model.status != 0
            certImgView.isHidden = model.status == 0
            certImgViewWH = model.status == 0 ? 0 : 16
            /// 0 未申请认证，1 已认证，2 待认证）
            if model.status == 1 {
                certImgView.image = R.image.checkmarkSealFill()?.scaled(toWidth: 12)
            } else {
                certImgView.image = R.image.checkmarkSealFillGray()
            }
            
            self.isUserInteractionEnabled = model.status == 0
            if model.org_id > 0 && model.is_current == 1 {
                moreButton.menu = UIMenu(children: [action0,action1,action2])
            } else {
                moreButton.menu = UIMenu(children: [action1,action2])
            }
            
            
            setNeedsLayout()
            layoutIfNeeded()
            
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(shadowView)
        shadowView.backgroundColor = .white
        shadowView.addSubview(imgView)
        shadowView.addSubview(schoolLabel)
        shadowView.addSubview(majorLabel)
        shadowView.addSubview(timeLabel)
        shadowView.addSubview(descLabel)
        shadowView.addSubview(moreButton)
        shadowView.addSubview(certImgView)
        certImgView.contentMode = .scaleAspectFit
        
        shadowView.isSkeletonable = true
        imgView.isSkeletonable = true
        certImgView.isSkeletonable = true
        contentView.isSkeletonable = true
        isSkeletonable = true
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        shadowView.shadow(cornerRadius: 8, color: .black.withAlphaComponent(0.1), offset: CGSize(width: 0, height: 5), radius: 8, opacity: 1)
        
        shadowView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        imgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        schoolLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().inset(50)
            make.height.equalTo(32)
        }
        
        
        moreButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(30)
            make.centerY.equalTo(schoolLabel)
        }
        
        
        certImgView.snp.remakeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.top.equalTo(schoolLabel.snp.bottom).offset(6)
            make.width.equalTo(certImgViewWH)
            make.height.equalTo(12)
        }
        
        majorLabel.snp.makeConstraints { make in
            make.left.equalTo(certImgView.snp.right)
            make.centerY.equalTo(certImgView.snp.centerY)
            make.right.equalToSuperview().inset(16)
            make.height.equalTo(19)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.top.equalTo(majorLabel.snp.bottom).offset(2)
            make.right.equalToSuperview().inset(16)
            make.height.equalTo(19)
        }
        descLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.top.equalTo(timeLabel.snp.bottom).offset(2)
            make.right.equalToSuperview().inset(16)
            make.bottom.greaterThanOrEqualToSuperview().inset(16)
        }
    }

}
