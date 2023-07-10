//
//  GroupItemCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/10.
//

import UIKit

class GroupItemCell: UITableViewCell {

    var imgView = UIImageView()
    var nameLabel = UILabel()
    var deletebutton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(imgView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(deletebutton)
        imgView.sk.cornerRadius = 20
        imgView.contentMode = .scaleAspectFill
        nameLabel.textColor = R.color.textColor52()
        nameLabel.font = UIFont.sk.pingFangRegular(15)
        deletebutton.imageForNormal = R.image.connection_delete()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.centerY.equalToSuperview()
        }
        deletebutton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
}
