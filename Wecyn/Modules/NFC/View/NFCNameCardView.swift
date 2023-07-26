//
//  NFCNameCardView.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/26.
//

import UIKit
import Kingfisher
class NFCNameCardView: UIView {
    
    let blurImageView = UIImageView()
    
    let avtContentView = UIView()
    let avtImgView = UIImageView()
    
    let qrCodeImgView = UIImageView()
    
    let nameLabel = UILabel()
    
    let phoneIcon = UIImageView()
    let phoneLabel = UILabel()
    
    let mailIcon = UIImageView()
    let mailLabel = UILabel()
    
   
    
    var model:UserInfoModel? {
        didSet {
            guard let model = model else { return }
            
            avtImgView.kf.setImage(with: model.avatar.avatarUrl, placeholder: R.image.proile_user())
            blurImageView.kf.setImage(with: model.avatar.avatarUrl)
            
            let url = "www.terrabyte.sg/wecyn/uid/\(model.id)"
            qrCodeImgView.image = UIImage.sk.QRImage(with: url, size: CGSize(width: 120, height: 120), logoSize: nil)
            
            nameLabel.text = model.full_name
            mailLabel.text = model.email
            phoneLabel.text = model.mobile
            
        }
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isSkeletonable = true
        
        addSubview(blurImageView)
        addSubview(avtContentView)
        avtContentView.addSubview(avtImgView)
        addSubview(qrCodeImgView)
        addSubview(nameLabel)
        addSubview(phoneIcon)
        addSubview(phoneLabel)
        addSubview(mailIcon)
        addSubview(mailLabel)
        
        self.subviews.forEach({ $0.isSkeletonable = true })
        
        blurImageView.contentMode = .scaleAspectFill
        blurImageView.blur(withStyle: .light)
        
        qrCodeImgView.contentMode = .scaleAspectFit
        qrCodeImgView.borderColor = .white
        qrCodeImgView.borderWidth = 2
        qrCodeImgView.addShadow(cornerRadius: 0)
        
        
        avtContentView.addShadow(cornerRadius: 40)
        avtContentView.borderColor = .white
        avtContentView.borderWidth = 2
        
        avtImgView.contentMode = .scaleAspectFit
        avtImgView.cornerRadius = 40
        avtImgView.layer.masksToBounds = true
        
        nameLabel.textColor = R.color.textColor162C46()
        nameLabel.font = UIFont.sk.pingFangSemibold(18)
        
        phoneLabel.textColor = R.color.textColor162C46()
        phoneLabel.font = UIFont.sk.pingFangRegular(15)
        phoneIcon.image = R.image.phoneCircleFill()
        
        mailLabel.textColor = R.color.textColor162C46()
        mailLabel.font = UIFont.sk.pingFangRegular(15)
        mailIcon.image = R.image.envelopeCircleFill()
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        blurImageView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(160)
        }
        
        avtContentView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(80)
            make.bottom.equalTo(blurImageView.snp.bottom).offset(40)
        }
        
        avtImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        qrCodeImgView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(120)
            make.bottom.equalTo(blurImageView.snp.bottom).offset(60)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(avtImgView.snp.bottom).offset(32)
            make.height.equalTo(20)
            make.right.equalToSuperview().offset(-16)
        }
        
        phoneIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(nameLabel.snp.bottom).offset(16)
            make.width.height.equalTo(20)
        }
        
        phoneLabel.snp.makeConstraints { make in
            make.left.equalTo(phoneIcon.snp.right).offset(8)
            make.centerY.equalTo(phoneIcon.snp.centerY)
            make.height.equalTo(16)
            make.right.equalToSuperview().offset(-16)
        }
        
        mailIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(phoneIcon.snp.bottom).offset(16)
            make.width.height.equalTo(20)
        }
        
        mailLabel.snp.makeConstraints { make in
            make.left.equalTo(mailIcon.snp.right).offset(8)
            make.centerY.equalTo(mailIcon.snp.centerY)
            make.height.equalTo(16)
            make.right.equalToSuperview().offset(-16)
        }
        
     
        
       
    }
    

}
