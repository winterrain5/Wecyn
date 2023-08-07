//
//  ProfileHeaderView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/8.
//

import UIKit
import ImagePickerSwift
class ProfileHeaderView: UIView {

    @IBOutlet weak var backImgView: UIImageView!
    @IBOutlet weak var userAvatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var viewNamecardButton: UIButton!
    
    @IBOutlet weak var viewCalendarButton: UIButton!
    
    @IBOutlet weak var addNewSectionButton: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    
    var uplodaImageComplete:(()->())?
    var userInfoModel: UserInfoModel? {
        didSet {
            guard let userInfoModel = userInfoModel else { return }
            
            nameLabel.text = userInfoModel.first_name + " " + userInfoModel.last_name
            userAvatarImageView.kf.setImage(with: userInfoModel.avatar.avatarUrl,placeholder: R.image.proile_user()!)
            backImgView.kf.setImage(with: userInfoModel.avatar.avatarUrl,placeholder: R.image.proile_user()!)
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewNamecardButton.titleForNormal = Localizer.localized(for: .view_namecard)
        viewCalendarButton.titleForNormal = Localizer.localized(for: .view_calendar)
        addNewSectionButton.titleForNormal = Localizer.localized(for: .add_new_section)
        backImgView.blur(withStyle: .light)
        
        userAvatarImageView.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
            
            let option = ImagePickerOptions.default
            option.resizeWidth = 128
            option.allowsEditing = true
            
            let alert = UIAlertController.init(title: "Add a Photo", message: "Select photo from camera or photolibrary", preferredStyle: .actionSheet)
            alert.addAction(title: "Camera",style: .default) { _ in
                ImagePicker.show(type: .takePhoto, with: option) { image, path in
                    guard let image = image else { return }
                    self.userAvatarImageView.image = image
                    self.upload(image)
                }
            }
            
            alert.addAction(title: "PhotoLibrary",style: .default) { _ in
                ImagePicker.show(type: .selectPhoto, with: option) { image, path in
                    guard let image = image else { return }
                    self.userAvatarImageView.image = image
                    self.upload(image)
                }
            }
            
            alert.addAction(title: "Cancel",style: .cancel)
            
            alert.show()
           
        }).disposed(by: rx.disposeBag)
        
        viewNamecardButton.rx.tap.subscribe(onNext: {
            let vc = NFCNameCardController()
            let nav = BaseNavigationController(rootViewController: vc)
            UIViewController.sk.getTopVC()?.present(nav, animated: true)
        }).disposed(by: rx.disposeBag)
        
        viewCalendarButton.rx.tap.subscribe(onNext:{
            let vc = CalendarEventController()
            UIViewController.sk.getTopVC()?.navigationController?.pushViewController(vc)
        }).disposed(by: rx.disposeBag)
        
        addNewSectionButton.rx.tap.subscribe(onNext:{
            let vc = NFCController()
            UIViewController.sk.getTopVC()?.navigationController?.pushViewController(vc)
        }).disposed(by: rx.disposeBag)
        
        [viewNamecardButton,viewCalendarButton,addNewSectionButton].forEach({
            $0?.addShadow(cornerRadius: 5)
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
   
    
    func upload(_ image:UIImage) {
        Toast.showLoading()
        guard let base64 = image.jpegBase64String(compressionQuality: 0.4) else { return }
        print("image.kilobytesSize:\(image.kilobytesSize),base64Size:\(base64.lengthOfBytes(using: .utf8))")
        UserService.updateAvatar(photo: base64).subscribe(onNext:{
            if $0.success == 1 {
                Toast.showSuccess(withStatus: "Upload Success")
                self.uplodaImageComplete?()
            } else {
                Toast.showError(withStatus: $0.message)
            }
        },onError: { e in
            Toast.showError(withStatus: e.asAPIError.errorInfo().message)
        }).disposed(by: rx.disposeBag)
    }
   
}


