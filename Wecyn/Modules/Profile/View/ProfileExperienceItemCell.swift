//
//  ProfileExperienceItemCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/12.
//

import UIKit

class ProfileExperienceItemCell: UITableViewCell {

    private let imgView = UIImageView()
    let moreButton = UIButton().then { button in
        button.imageForNormal = UIImage.ellipsis?.withTintColor(R.color.iconColor()!,renderingMode: .alwaysOriginal).scaled(toWidth: 18)
        button.contentHorizontalAlignment = .right
        button.showsMenuAsPrimaryAction  = true
    }
    private let jobLabel = UILabel().then { label in
        label.textColor = R.color.textColor33()
        label.font = UIFont.sk.pingFangRegular(13)
    }
    private let companyLabel =  UILabel().then { label in
        label.textColor = R.color.textColor33()
        label.font = UIFont.sk.pingFangSemibold(16)
    }
    private let timeLabel =  UILabel().then { label in
        label.textColor = R.color.textColor33()
        label.font = UIFont.sk.pingFangRegular(12)
    }
    private let descLabel =  UILabel().then { label in
        label.textColor = R.color.textColor33()
        label.font = UIFont.sk.pingFangRegular(12)
    }
    
    var model:UserExperienceInfoModel? {
        didSet {
            guard let model = model else { return }
            if model.org_avatar.url == nil {
                imgView.contentMode = .center
                imgView.image = R.image.org_placeholder()
            } else {
                imgView.contentMode = .scaleAspectFit
                imgView.kf.setImage(with: model.org_avatar.url)
            }
            
            companyLabel.text = model.org_name
            jobLabel.text = model.title_name + " " + model.industry_name
            timeLabel.text = model.start_date_format + " - " + (model.is_current == 1 ? "Present" : model.end_date_format)
            descLabel.text = model.desc
            
            
        }
    }
    var deleteHandler:((UserExperienceInfoModel)->())?
    var editHandler:((UserExperienceInfoModel)->())?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(imgView)
        contentView.addSubview(moreButton)
        contentView.addSubview(jobLabel)
        contentView.addSubview(companyLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(descLabel)
        
        let action1 = UIAction(title: "Edit",image: R.image.pencilLine()!) { [weak self] _ in
            guard let `self` = self,let model = self.model else { return }
            self.editHandler?(model)
        }
        let action2 = UIAction(title: "Delete",image: UIImage.trash?.tintImage(.red),attributes: .destructive) { [weak self] _ in
            guard let `self` = self,let model = self.model else { return }
            self.deleteHandler?(model)
        }
        
        moreButton.menu = UIMenu(children: [action1,action2])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
       
        companyLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().inset(50)
            make.height.equalTo(32)
        }
        
        moreButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(30)
            make.centerY.equalTo(companyLabel)
        }
        
        jobLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.top.equalTo(companyLabel.snp.bottom).offset(2)
            make.right.equalToSuperview().inset(16)
            make.height.equalTo(19)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.top.equalTo(jobLabel.snp.bottom).offset(2)
            make.right.equalToSuperview().inset(16)
            make.height.equalTo(19)
        }
        
        descLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.top.equalTo(timeLabel.snp.bottom).offset(2)
            make.right.equalToSuperview().inset(16)
            make.bottom.greaterThanOrEqualToSuperview().inset(12)
        }
    }

}
    
