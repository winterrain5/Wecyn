//
//  PostRepostTypeSheetView.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/22.
//

import UIKit

import EntryKit
class PostRepostTypeSheetView: UIView {

    let repostButton = UIButton()
    let quoteButton = UIButton()
    let cancelButton = UIButton()
    var isRepost:Bool = false
    var repostAction:(()->())?
    var quoteAction:(()->())?
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(repostButton)
        addSubview(quoteButton)
        addSubview(cancelButton)
        
        repostButton.imageForNormal = R.image.post_repost()?.tintImage(R.color.textColor22()!)
        repostButton.titleForNormal = "Repost"
        repostButton.titleColorForNormal = R.color.textColor22()!
        repostButton.contentHorizontalAlignment = .left
        repostButton.titleLabel?.font = UIFont.sk.pingFangRegular(18)
        repostButton.sk.setImageTitleLayout(.imgLeft,spacing: 16)
        
        quoteButton.imageForNormal = UIImage(named: "pencil.line")?.tintImage(R.color.textColor22()!)
        quoteButton.titleForNormal = "Quote"
        quoteButton.titleColorForNormal = R.color.textColor22()!
        quoteButton.contentHorizontalAlignment = .left
        quoteButton.titleLabel?.font = UIFont.sk.pingFangRegular(18)
        quoteButton.sk.setImageTitleLayout(.imgLeft,spacing: 16)
        
        cancelButton.titleForNormal = "Cancel"
        cancelButton.titleColorForNormal = .white
        cancelButton.backgroundColor =  R.color.theamColor()
        cancelButton.titleLabel?.font = UIFont.sk.pingFangMedium(16)
        cancelButton.cornerRadius = 22
        
        repostButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Haptico.selection()
            self.repostAction?()
            EntryKit.dismiss()
        }).disposed(by: rx.disposeBag)
        
        quoteButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Haptico.selection()
            self.quoteAction?()
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
        
        repostButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(30)
            make.height.equalTo(30)
        }
        
        quoteButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(repostButton.snp.bottom).offset(20)
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
    
    static func display(isRepost:Bool,repostAction: (()->())?, quoteAction: (()->())?) {
        let view = PostRepostTypeSheetView()
        view.repostAction = repostAction
        view.quoteAction = quoteAction
        view.isRepost = isRepost
        let size = CGSize(width: kScreenWidth, height: 220 + kBottomsafeAreaMargin)
        EntryKit.display(view: view, size: size, style: .sheet,touchDismiss: true)
    }

    
}
