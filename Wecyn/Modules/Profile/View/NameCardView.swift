//
//  NameCardView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/12.
//

import UIKit
import EntryKit
import IQKeyboardManagerSwift
class NameCardView: UIView {
    
    private let qrcodeView = NameCardQRCodeView.loadViewFromNib()
    private let namecardContentView = NameCardContentView.loadViewFromNib()
    private let namecardEditView = NameCardEditView.loadViewFromNib()
    private let bottomView = UIScrollView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(bottomView)
        bottomView.addSubview(qrcodeView)
        bottomView.backgroundColor = .clear
    
        addSubview(namecardContentView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeToEditView), name: NSNotification.Name.init("Profile_Change_NameCard_To_Edit"), object: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bottomHeight:CGFloat = kScreenHeight == 667 ? 400 : 470
        self.bottomView.frame = CGRect(x: 0, y: kScreenHeight - bottomHeight, width: kScreenWidth, height: bottomHeight)
        self.bottomView.contentSize = CGSize(width: kScreenWidth, height: bottomHeight)
        
        qrcodeView.frame = bottomView.bounds
        
        namecardContentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(bottomView.snp.top).inset(-20)
            make.height.equalTo(220)
        }
        
    }
    
    
    static func showNameCard() {
        let view = NameCardView()
        UIApplication.shared.keyWindow?.addSubview(view)
        view.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        view.alpha = 0
        UIView.animate(withDuration: 0.2, delay: 0) {
            view.alpha = 1
        } completion: { flag in
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }
    
   @objc func changeToEditView() {
       
       if bottomView.subviews.contains(where: { $0 is NameCardEditView }) {
           return
       }
       
       bottomView.removeSubviews()
       bottomView.addSubview(namecardEditView)
       namecardEditView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 550)
       bottomView.contentSize = CGSize(width: kScreenWidth, height: 550)
       
       
       namecardEditView.nameTf.rx.text.bind(to: self.namecardContentView.nameLabel.rx.text).disposed(by: rx.disposeBag)
       
       namecardEditView.companyTf.rx.text.orEmpty.asDriver().drive(namecardContentView.companyLabel.rx.text).disposed(by: rx.disposeBag)
       namecardEditView.emailTf.rx.text.orEmpty.asDriver().drive(namecardContentView.emailLabel.rx.text).disposed(by: rx.disposeBag)
       namecardEditView.mobileNoTf.rx.text.orEmpty.asDriver().drive(namecardContentView.mobileNoLabel.rx.text).disposed(by: rx.disposeBag)
       namecardEditView.officeNoTf.rx.text.orEmpty.asDriver().drive(namecardContentView.officeNoLabel.rx.text).disposed(by: rx.disposeBag)
       namecardEditView.locationTf.rx.text.orEmpty.asDriver().drive(namecardContentView.locationLabel.rx.text).disposed(by: rx.disposeBag)
       namecardEditView.websiteTf.rx.text.orEmpty.asDriver().drive(namecardContentView.websiteLabel.rx.text).disposed(by: rx.disposeBag)
     
       
    }
    
    static func dismissNameCard() {
        UIViewController.sk.getTopVC()?.dismiss(animated: true)
    }
}

