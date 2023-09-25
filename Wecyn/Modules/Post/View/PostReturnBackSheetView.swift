//
//  PostReturnBackSheetView.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/19.
//

import UIKit
import EntryKit
class PostReturnBackSheetView: UIView {

    let deleteButton = UIButton()
    let saveButton = UIButton()
    let cancelButton = UIButton()
    
    var deleteAction:(()->())?
    var saveAction:(()->())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(deleteButton)
        addSubview(saveButton)
        addSubview(cancelButton)
        
        deleteButton.imageForNormal = UIImage.trash?.tintImage(.red)
        deleteButton.titleForNormal = "Delete"
        deleteButton.titleColorForNormal = .red
        deleteButton.contentHorizontalAlignment = .left
        deleteButton.titleLabel?.font = UIFont.sk.pingFangRegular(18)
        deleteButton.sk.setImageTitleLayout(.imgLeft,spacing: 16)
        
        
        saveButton.imageForNormal = UIImage.square_and_arrow_down?.tintImage(R.color.textColor22()!)
        saveButton.titleForNormal = "Save draft"
        saveButton.titleColorForNormal = R.color.textColor22()!
        saveButton.contentHorizontalAlignment = .left
        saveButton.titleLabel?.font = UIFont.sk.pingFangRegular(18)
        saveButton.sk.setImageTitleLayout(.imgLeft,spacing: 16)
        
        cancelButton.titleForNormal = "Cancel"
        cancelButton.titleColorForNormal = .white
        cancelButton.backgroundColor =  R.color.theamColor()
        cancelButton.titleLabel?.font = UIFont.sk.pingFangMedium(16)
        cancelButton.cornerRadius = 22
        
        deleteButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Haptico.selection()
            self.deleteAction?()
            EntryKit.dismiss()
        }).disposed(by: rx.disposeBag)
        
        saveButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Haptico.selection()
            self.saveAction?()
            EntryKit.dismiss()
        }).disposed(by: rx.disposeBag)
        
        cancelButton.rx.tap.subscribe(onNext:{
            EntryKit.dismiss()
        }).disposed(by: rx.disposeBag)
        
    
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        deleteButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(30)
            make.height.equalTo(30)
        }
        
        saveButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(deleteButton.snp.bottom).offset(20)
            make.height.equalTo(30)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-(kBottomsafeAreaMargin +  16))
        }
        
        sk.addCorner(conrners: [.topLeft,.topRight], radius: 22)
    }
    
    static func display(deleteAction: (()->())?, saveAction: (()->())?) {
        let view = PostReturnBackSheetView()
        view.deleteAction = deleteAction
        view.saveAction = saveAction
        let size = CGSize(width: kScreenWidth, height: 220 + kBottomsafeAreaMargin)
        EntryKit.display(view: view, size: size, style: .sheet,touchDismiss: true)
    }

    
}
