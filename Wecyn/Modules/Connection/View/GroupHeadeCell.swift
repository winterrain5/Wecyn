//
//  GroupHeadeCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/10.
//

import UIKit
class GroupHeadeCell: UITableViewCell {

    var groupNameLabel = UILabel()
    var arrowButton = UIButton()
    var deleteButton = UIButton()
    var editButton = UIButton()
    var model:GroupListModel = GroupListModel(){
        didSet {
            groupNameLabel.text = model.name + "(\(model.count))"
            arrowButton.imageForNormal = model.isExpand ? R.image.calendar_item_arrow_down() : R.image.calendar_item_arrow_right()
        }
    }
    var indexPath:IndexPath = IndexPath(row: 0, section: 0)
    var arrowButtonDidClickHandler:((IndexPath)->())?
    var deleteButtonDidClickHandler:((GroupListModel)->())?
    var addButtonDidClickHandler:((GroupListModel)->())?
    var editButtonDidClickHandler:((IndexPath)->())?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(groupNameLabel)
        groupNameLabel.textColor = R.color.textColor52()
        groupNameLabel.font = UIFont.sk.pingFangRegular(16)
        
        contentView.addSubview(arrowButton)
        arrowButton.imageForNormal = R.image.calendar_item_arrow_right()
        
        contentView.addSubview(deleteButton)
        deleteButton.imageForNormal = R.image.connection_delete()
        
        contentView.addSubview(editButton)
        editButton.imageForNormal = R.image.profile_edit_userinfo()
        
        arrowButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.model.isExpand.toggle()
            self.arrowButtonDidClickHandler?(self.indexPath)
        }).disposed(by: rx.disposeBag)
        
        deleteButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            
            let alert = UIAlertController(style: .actionSheet,title: "Are you sure you want to delete this group?")
            alert.addAction(title: "Confirm",style: .destructive) { _ in
                self.deleteButtonDidClickHandler?(self.model)
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.show()
            
        }).disposed(by: rx.disposeBag)
        
        

        editButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.editButtonDidClickHandler?(self.indexPath)
        }).disposed(by: rx.disposeBag)
        
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        groupNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        
        arrowButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.right.equalTo(arrowButton.snp.left).offset(-4)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        
        editButton.snp.makeConstraints { make in
            make.right.equalTo(deleteButton.snp.left).offset(-4)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
        }
    }
    
}
