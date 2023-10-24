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
    let subLabel =  UILabel()
    
    var model:UserInfoModel? {
        didSet {
            guard let model = model else { return }
            
            hideSkeleton()
            
            avtImgView.kf.setImage(with: model.avatar.url, placeholder: R.image.proile_user(),options: [.forceRefresh])
            blurImageView.kf.setImage(with: model.cover.url,options: [.forceRefresh])
            //10.1.3.144:5173/card/a65ab2f2-e348-4e5b-b1cd-eeba7f644cd2
            let url = APIHost.share.WebpageUrl + "/card/\(model.uuid)"
            qrCodeImgView.image = UIImage.sk.QRImage(with: url, size: CGSize(width: 120, height: 120), logoSize: nil)
            
            nameLabel.text = model.full_name
         
            var text = ""
            if !model.title.isEmpty {
               text = text + model.title
            }
            if !model.org_name.isEmpty {
                text = text + "  " + model.org_name
            }
            
            subLabel.text = text
            
            if text.isEmpty == false {
                subLabel.isHidden = false
                subLabel.snp.makeConstraints { make in
                    make.left.equalToSuperview().offset(16)
                    make.right.equalToSuperview().offset(-16)
                    make.top.equalTo(nameLabel.snp.bottom).offset(4)
                }
                
                UIView.animate(withDuration: 0) {
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                } completion: { flag in
                    print(self.subLabel.frame.maxY)
                    self.dataUpdateComplete?(self.subLabel.frame.maxY + 16)
                }

                
            } else {
                subLabel.isHidden = true
                UIView.animate(withDuration: 0) {
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                } completion: { flag in
                    print(self.nameLabel.frame.maxY)
                    self.dataUpdateComplete?(self.nameLabel.frame.maxY + 16)
                }
            }
            
        }
    }
    
    var dataUpdateComplete:((CGFloat)->())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isSkeletonable = true
        
        addSubview(blurImageView)
        addSubview(avtContentView)
        avtContentView.addSubview(avtImgView)
        addSubview(qrCodeImgView)
        addSubview(nameLabel)
        addSubview(subLabel)
        
        self.subviews.forEach({ $0.isSkeletonable = true })
        
        blurImageView.contentMode = .scaleAspectFill
        blurImageView.clipsToBounds = true
        
        qrCodeImgView.contentMode = .scaleAspectFit
        qrCodeImgView.borderColor = .white
        qrCodeImgView.borderWidth = 2
        qrCodeImgView.addShadow(cornerRadius: 0)
        
        avtContentView.addShadow(cornerRadius: 40)
        avtContentView.borderColor = .white
        avtContentView.borderWidth = 2
        
        avtImgView.contentMode = .scaleAspectFit
        avtImgView.cornerRadius = 40
       
        
        nameLabel.textColor = R.color.textColor22()
        nameLabel.font = UIFont.sk.pingFangSemibold(18)
        nameLabel.numberOfLines = 3
        
        subLabel.textColor = R.color.textColor22()
        subLabel.font = UIFont.sk.pingFangSemibold(15)
        subLabel.numberOfLines = 2
        
        showSkeleton()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        blurImageView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(200)
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
            make.top.equalTo(avtImgView.snp.bottom).offset(16)
            make.right.equalToSuperview().offset(-16)
        }
     
        
       
    }
    

}
