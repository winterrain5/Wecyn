//
//  NFCNameCardEditHeadView.swift
//  Wecyn
//
//  Created by Derrick on 2023/8/25.
//

import UIKit
import ImagePickerSwift
import AnyImageKit
class NFCNameCardEditHeadView: UIView {
    
    let coverImageView = UIImageView()
    
    let avtContentView = UIView()
    let avtImgView = UIImageView()
    
    let avtEditButton = UIButton()
    let coverEditButton = UIButton()
    
    var editAvatar = false
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
        
        avtImgView.contentMode = .scaleAspectFill
        avtImgView.cornerRadius = 40
        
        addSubview(avtEditButton)
        addSubview(coverEditButton)
        
        func presentCapture() {
            var option = CaptureOptionsInfo()
            var photoInfo = EditorPhotoOptionsInfo()
            photoInfo.toolOptions = [.crop]
            option.editorPhotoOptions =  photoInfo
            let vc = ImageCaptureController(options: option, delegate: self)
            vc.modalPresentationStyle = .fullScreen
            UIViewController.sk.getTopVC()?.present(vc, animated: true)
        }
        func presentImagePicker() {
            var option = PickerOptionsInfo()
            
            var photoOption = EditorPhotoOptionsInfo()
            photoOption.toolOptions = [.crop]
           
            option.editorOptions = .photo
            option.editorPhotoOptions = photoOption
            option.selectLimit = 1
            
            let vc = ImagePickerController(options: option, delegate: self)
            vc.modalPresentationStyle = .fullScreen
            UIViewController.sk.getTopVC()?.present(vc, animated: true)
        }
        avtEditButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            
            let alert = UIAlertController.init(title: "Edit Photo", message: "Select photo from camera or photolibrary", preferredStyle: .actionSheet)
            alert.addAction(title: "Camera",style: .destructive) { _ in
                presentCapture()
                self.editAvatar = true
            }
            
            alert.addAction(title: "PhotoLibrary",style: .destructive) { _ in
               presentImagePicker()
                self.editAvatar = true
            }
            
            
            alert.addAction(title: "Cancel",style: .cancel)
            
            alert.show()
        }).disposed(by: rx.disposeBag)
        
        coverEditButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            
            let alert = UIAlertController.init(title: "Edit Cover", message: "Select photo from camera or photolibrary", preferredStyle: .actionSheet)
            alert.addAction(title: "Camera",style: .destructive) { _ in
                presentCapture()
                self.editAvatar = false
            }
            
            alert.addAction(title: "PhotoLibrary",style: .destructive) { _ in
                presentImagePicker()
                self.editAvatar = false
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
        let base64 = image.compressionImageToBase64(150)
        UserService.updateAvatar(photo: base64).subscribe(onNext:{
            if $0.success != 1 {
                Toast.showError($0.message)
            }else {
                self.avtImgView.image = image
                NotificationCenter.default.post(name: NSNotification.Name.UpdateUserInfo, object: nil)
                Toast.dismiss()
            }
        },onError: { e in
            Toast.dismiss()
            Toast.showError(e.asAPIError.errorInfo().message)
        }).disposed(by: rx.disposeBag)
    }
    
    func uploadCover(_ image:UIImage) {
        Toast.showLoading()
        let base64 = image.compressionImageToBase64(250)
        UserService.updateCover(photo: base64).subscribe(onNext:{
            if $0.success != 1 {
                Toast.showError($0.message)
            } else {
                self.coverImageView.image = image
                NotificationCenter.default.post(name: NSNotification.Name.UpdateUserInfo, object: nil)
                Toast.dismiss()
            }
            
        },onError: { e in
            Toast.dismiss()
            Toast.showError(e.asAPIError.errorInfo().message)
        }).disposed(by: rx.disposeBag)
    }
    
}


extension NFCNameCardEditHeadView: ImageCaptureControllerDelegate {
    func imageCapture(_ capture: ImageCaptureController, didFinishCapturing result: CaptureResult) {
        if result.type == .photo {
            guard let photoData = try? Data(contentsOf: result.mediaURL) else { return }
            guard let image = UIImage(data: photoData) else { return }
            if editAvatar {
                uploadAvatar(image)
            } else {
                uploadCover(image)
            }
        }
        capture.dismiss(animated: true, completion: nil)
    }
}
extension NFCNameCardEditHeadView: ImagePickerControllerDelegate {
    func imagePicker(_ picker: ImagePickerController, didFinishPicking result: PickerResult) {
        guard let image = result.assets.first?.image else  { return }
        if editAvatar {
            uploadAvatar(image)
        } else {
            uploadCover(image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
