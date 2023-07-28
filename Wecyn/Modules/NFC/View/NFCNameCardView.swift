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
    
    
    var model:UserInfoModel? {
        didSet {
            guard let model = model else { return }
            
            hideSkeleton()
            
            avtImgView.kf.setImage(with: model.avatar.avatarUrl, placeholder: R.image.proile_user())
            blurImageView.kf.setImage(with: model.avatar.avatarUrl)
            
            let url = "www.terrabyte.sg/wecyn/uid/\(model.id)"
            qrCodeImgView.image = UIImage.sk.QRImage(with: url, size: CGSize(width: 120, height: 120), logoSize: nil)
            
            var text:String = model.full_name
            if !model.job_title.isEmpty {
               text = text + "\n" + model.job_title
            }
            if !model.company.isEmpty {
                text = text + "\n" + model.company
            }
            
            nameLabel.text = text
         
            
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
        
        nameLabel.textColor = R.color.textColor162C46()
        nameLabel.font = UIFont.sk.pingFangSemibold(18)
        nameLabel.numberOfLines = 3
        
        showSkeleton()
        
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
            make.right.equalToSuperview().offset(-16)
        }
     
        
       
    }
    

}
