//
//  BusinessCardShareByQRCodeView.swift
//  Wecyn
//
//  Created by Derrick on 2024/6/28.
//

import UIKit
import JXPagingView
import SwiftExtensionsLibrary
class BusinessCardShareByQRCodeView: BasePagingView {
    
    let container = UIView()
    let imageContainer = UIView()
    let qrcodeImageView = UIImageView()
    let shareButton = UIButton()
    let bottomLabel = UILabel()
    let model = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        addSubview(container)
        container.backgroundColor = R.color.theamColor()
        container.addSubview(qrcodeImageView)
        qrcodeImageView.contentMode = .scaleAspectFill
        
        container.addSubview(imageContainer)
        imageContainer.backgroundColor = .white
        imageContainer.cornerRadius = 15
        
        let url = APIHost.share.WebpageUrl + "/card/\(model?.uuid ?? "")"
        qrcodeImageView.image = UIImage.sk.QRImage(with: url, size: CGSize(width: 200, height: 200), logoSize: CGSize(width: 40, height: 40),logoImage: R.image.appicon()!,logoRoundCorner: 8)
        imageContainer.addSubview(qrcodeImageView)
        
        addSubview(bottomLabel)
        bottomLabel.text = "将相机对准二维码。".innerLocalized()
        bottomLabel.textColor = R.color.textColor66()
        bottomLabel.font = UIFont.systemFont(ofSize: 16)
        
        addSubview(shareButton)
        shareButton.titleForNormal = "分享".innerLocalized()
        shareButton.titleColorForNormal = .black
        shareButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        shareButton.backgroundColor =  R.color.backgroundColor()
        shareButton.sk.setImageTitleLayout(.imgRight, spacing: 12)
        shareButton.imageForNormal = UIImage.systemImage("square.and.arrow.up").withTintColor(.black, renderingMode: .alwaysOriginal)
        shareButton.rx.tap.subscribe(onNext:{ [weak self] in
            Haptico.selection()
            guard let image = self?.qrcodeImageView.image else { return }
            let vc = VisualActivityViewController(image: image)
            vc.previewImageSideLength = 40
            UIViewController.sk.getTopVC()?.present(vc, animated: true)
        }).disposed(by: rx.disposeBag)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        container.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.height.width.equalTo(260)
            make.centerX.equalToSuperview()
        }
        container.shadow(cornerRadius: 20, color: R.color.theamColor()!, offset: CGSize(width: 5, height: 20), radius: 30, opacity: 0.4)
        
        imageContainer.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(horizontal: 30, vertical: 30))
        }
        
        qrcodeImageView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(horizontal: 30, vertical: 30))
        }
        
        bottomLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(container.snp.bottom).offset(40)
        }
        
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(bottomLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(260)
            make.height.equalTo(60)
        }
        shareButton.shadow(cornerRadius: 16, color: UIColor.black.withAlphaComponent(0.2), offset: CGSize(width: 10, height: 10), radius: 20, opacity: 1)
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


