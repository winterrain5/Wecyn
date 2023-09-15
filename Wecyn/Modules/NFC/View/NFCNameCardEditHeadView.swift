//
//  NFCNameCardEditHeadView.swift
//  Wecyn
//
//  Created by Derrick on 2023/8/25.
//

import UIKit
import ImagePickerSwift
class NFCNameCardEditHeadView: UIView {
    
    let coverImageView = UIImageView()
    
    let avtContentView = UIView()
    let avtImgView = UIImageView()
    
    let avtEditButton = UIButton()
    let coverEditButton = UIButton()
    
    var model:UserInfoModel? {
        didSet {
            guard let model = model else { return }
            
            avtImgView.kf.setImage(with: model.avatar_url, placeholder: R.image.proile_user())
            coverImageView.kf.setImage(with: model.cover_url)
            
        }
    }
    
    var dataUpdateComplete:((CGFloat)->())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        
        addSubview(coverImageView)
        addSubview(avtContentView)
        avtContentView.addSubview(avtImgView)
        
        
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        
        avtContentView.addShadow(cornerRadius: 40)
        avtContentView.borderColor = .white
        avtContentView.borderWidth = 2
        
        avtImgView.contentMode = .scaleAspectFit
        avtImgView.cornerRadius = 40
        
        addSubview(avtEditButton)
        addSubview(coverEditButton)
        
        avtEditButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            
            let option = ImagePickerOptions.default
            option.resizeWidth = 128
            option.allowsEditing = true
            
            let alert = UIAlertController.init(title: "Edit Photo", message: "Select photo from camera or photolibrary", preferredStyle: .actionSheet)
            alert.addAction(title: "Camera",style: .destructive) { _ in
                ImagePicker.show(type: .takePhoto, with: option) { image, path in
                    guard let image = image else { return }
                    self.uploadAvatar(image)
                }
            }
            
            alert.addAction(title: "PhotoLibrary",style: .destructive) { _ in
                ImagePicker.show(type: .selectPhoto, with: option) { image, path in
                    guard let image = image else { return }
                    self.uploadAvatar(image)
                }
            }
            
            alert.addAction(title: "Cancel",style: .cancel)
            
            alert.show()
        }).disposed(by: rx.disposeBag)
        
        coverEditButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            
            let option = ImagePickerOptions.default
            option.resizeWidth = kScreenWidth
            option.allowsEditing = true
            
            let alert = UIAlertController.init(title: "Edit Cover", message: "Select photo from camera or photolibrary", preferredStyle: .actionSheet)
            alert.addAction(title: "Camera",style: .destructive) { _ in
                ImagePicker.show(type: .takePhoto, with: option) { image, path in
                    guard let image = image else { return }
                    self.uploadCover(image)
                }
            }
            
            alert.addAction(title: "PhotoLibrary",style: .destructive) { _ in
                ImagePicker.show(type: .selectPhoto, with: option) { image, path in
                    guard let image = image else { return }
                    self.uploadCover(image)
                }
            }
            
            alert.addAction(title: "Cancel",style: .cancel)
            
            alert.show()
        }).disposed(by: rx.disposeBag)
        
        avtEditButton.imageForNormal = R.image.cameraCircleFill()
        coverEditButton.imageForNormal = R.image.cameraCircleFill()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        coverImageView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(200)
        }
        
        avtContentView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(80)
            make.bottom.equalTo(coverImageView.snp.bottom).offset(40)
        }
        
        avtImgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        coverEditButton.snp.makeConstraints { make in
            make.right.top.equalToSuperview().inset(16)
        }
        avtEditButton.snp.makeConstraints { make in
            make.right.bottom.equalTo(avtContentView)
        }
    }
    
    
    func uploadAvatar(_ image:UIImage) {
        Toast.showLoading()
        guard let base64 = compressionImage(50,image: image) else {
            Toast.showError(withStatus: "Failed to compress image")
            return
        }
        UserService.updateAvatar(photo: base64).subscribe(onNext:{
            if $0.success != 1 {
                Toast.showError(withStatus: $0.message)
            }else {
                self.avtImgView.image = image
                Toast.dismiss()
            }
        },onError: { e in
            Toast.showError(withStatus: e.asAPIError.errorInfo().message)
        }).disposed(by: rx.disposeBag)
    }
    
    func uploadCover(_ image:UIImage) {
        Toast.showLoading()
        guard let base64 = compressionImage(300,image: image) else {
            Toast.showError(withStatus: "Failed to compress image")
            return
        }
        UserService.updateCover(photo: base64).subscribe(onNext:{
            if $0.success != 1 {
                Toast.showError(withStatus: $0.message)
            } else {
                self.coverImageView.image = image
                Toast.dismiss()
            }
            
        },onError: { e in
            Toast.showError(withStatus: e.asAPIError.errorInfo().message)
        }).disposed(by: rx.disposeBag)
    }
    
    func compressionImage(_ size:Int,image:UIImage) -> String? {
        //        guard let data = image.sk.compressDataSize(maxSize: size * 1024), let base64 = UIImage(data: data)?.pngBase64String() else { return nil } //
        //        print("image.kilobytesSize:\(UIImage(data: data)?.kilobytesSize ?? 0),base64Size:\(base64.lengthOfBytes(using: .utf8))")
        //        return base64
        guard let data = image.pngData() else { return nil }
        guard let result = try? ImageCompress.compressImageData(data, limitDataSize: size * 1024 * 1024) else { return nil }
        let base64 = UIImage(data: result)?.pngBase64String()
        print("image.kilobytesSize:\(UIImage(data: data)?.kilobytesSize ?? 0),base64Size:\(base64?.lengthOfBytes(using: .utf8))")
        return base64
    }
    
}


