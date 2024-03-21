//
//  AdminDomainCell.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/20.
//

import UIKit

class AdminDomainCell: UITableViewCell {
    let nameLabel = UILabel()
    let timeLabel = UILabel()
    let deleteButton = UIButton()
    var deleteHandler:((AdminDomainModel) -> ())?
    var model:AdminDomainModel! {
        didSet {
            nameLabel.text = model.domain
            timeLabel.text = model.create_time
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLabel)
        nameLabel.font = UIFont.systemFont(ofSize: 18)
        nameLabel.textColor = .black
        
        contentView.addSubview(timeLabel)
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        timeLabel.textColor = .secondaryLabel
        
        contentView.addSubview(deleteButton)
        deleteButton.imageForNormal = R.image.trashFill()?.tintImage(.gray)
        deleteButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.deleteHandler?(self.model)
        }).disposed(by: rx.disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(8)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview().inset(8)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
    }
}
