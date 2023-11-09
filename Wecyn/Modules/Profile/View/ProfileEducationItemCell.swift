//
//  ProfileEducationItemCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/12.
//

import UIKit

class ProfileEducationItemCell: UITableViewCell {

    private let imgView = UIImageView()
    private let schoolLabel = UILabel().then { label in
        label.text = "Nanyang Polytechnic"
        label.textColor = R.color.textColor33()
        label.font = UIFont.sk.pingFangSemibold(16)
    }
    private let majorLabel =  UILabel().then { label in
        label.text = "High School Diploma, \nInteraction Design"
        label.numberOfLines = 1
        label.textColor = R.color.textColor33()
        label.font = UIFont.sk.pingFangRegular(13)
    }
    private let timeLabel =  UILabel().then { label in
        label.text = "2016-2019"
        label.textColor = R.color.textColor33()
        label.font = UIFont.sk.pingFangRegular(12)
    }
    private let descLabel =  UILabel().then { label in
        label.textColor = R.color.textColor33()
        label.font = UIFont.sk.pingFangRegular(12)
    }
    let moreButton = UIButton().then { button in
        button.imageForNormal = UIImage.ellipsis?.withTintColor(R.color.iconColor()!,renderingMode: .alwaysOriginal).scaled(toWidth: 18)
        button.contentHorizontalAlignment = .right
        button.showsMenuAsPrimaryAction  = true
    }
    var deleteHandler:((UserExperienceInfoModel)->())?
    var editHandler:((UserExperienceInfoModel)->())?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(imgView)
        contentView.addSubview(schoolLabel)
        contentView.addSubview(majorLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(descLabel)
        contentView.addSubview(moreButton)
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
            
        }
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
        
        
        majorLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.top.equalTo(schoolLabel.snp.bottom).offset(2)
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
            make.bottom.greaterThanOrEqualToSuperview().inset(12)
        }
    }

}
