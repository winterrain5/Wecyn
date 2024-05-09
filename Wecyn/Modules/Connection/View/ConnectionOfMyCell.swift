//
//  ConnectionOfMyCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/19.
//

import UIKit

class ConnectionOfMyCell: UITableViewCell {
   
    var imgView = UIImageView()
    var nameLabel = UILabel()
    var model: FriendListModel? {
        didSet {
            guard let model = model else { return }
            if model.id == 0 {
                imgView.image = R.image.file_trans()
                nameLabel.text = "文件传输助手".innerLocalized()
            } else {
                imgView.kf.setImage(with: model.avatar_url,placeholder: R.image.proile_user()!)
                nameLabel.text = model.remark.isEmpty ? model.full_name : "\(model.full_name) (\(model.remark))"
            }
            
            nameLabel.sk.setSpecificTextColor("(\(model.remark))", color: R.color.textColor77()!)
        }
    }
    
    var selectionMentionModel: FriendUserInfoModel? {
        didSet {
            guard let model = selectionMentionModel else { return }
            imgView.kf.setImage(with: model.avatar.url,placeholder: R.image.proile_user()!)
            nameLabel.text = model.remark.isEmpty ? model.full_name : "\(model.full_name) (\(model.remark))"
            nameLabel.sk.setSpecificTextColor("(\(model.remark))", color: R.color.textColor77()!)
        }
     
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(imgView)
        contentView.addSubview(nameLabel)
        imgView.sk.cornerRadius = 18
        imgView.contentMode = .scaleAspectFill
        nameLabel.textColor = R.color.textColor33()
        nameLabel.font = UIFont.sk.pingFangRegular(16)
        self.isSkeletonable =  true
        self.subviews.forEach({ $0.isSkeletonable = true })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(23)
        }
    }
}
