//
//  RegistAddAvatarView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/12.
//

import UIKit
import ImagePickerSwift
import RxRelay
class RegistAddAvatarView: UIView {

    @IBOutlet weak var avatarContainer: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var companyLabel: UILabel!
    
    @IBOutlet weak var locationlLabel: UILabel!
    
    @IBOutlet weak var addPhotoButton: LoadingButton!
  
    @IBOutlet weak var skipLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let registModel = UserDefaults.sk.get(of: RegistRequestModel.self, for: RegistRequestModel.className) {
            nameLabel.text = registModel.first_name?.appending(registModel.last_name ?? "")
            companyLabel.text = (registModel.job_title  ?? "" ) + " at " + (registModel.recent_company ?? "")
            locationlLabel.text = (registModel.country ?? "" ) + "," + (registModel.city ?? "")
        }
        
        avatarContainer.addShadow(cornerRadius: 21)
        
        addPhotoButton.addShadow(cornerRadius: 20)
        
        skipLabel.sk.setSpecificTextUnderLine("Skip", color: R.color.textColor52()!)
      
        addPhotoButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            let option = ImagePickerOptions.default
            option.resizeWidth = 128
            option.allowsEditing = true
            ImagePicker.show(type: .selectPhoto, with: option) { image, path in
                guard let image = image else { return }
                self.avatarImageView.image = image
                self.upload(image)
            }
        }).disposed(by: rx.disposeBag)
        
        skipLabel.rx.tapGesture().when(.recognized).subscribe(onNext:{ _ in
            let main = MainController()
            UIApplication.shared.keyWindow?.rootViewController = main
        }).disposed(by: rx.disposeBag)
        
    }
    
    func upload(_ image:UIImage) {
        addPhotoButton.startAnimation()
        guard let base64 = image.jpegBase64String(compressionQuality: 0.4) else { return }
        print("image.kilobytesSize:\(image.kilobytesSize),base64Size:\(base64.lengthOfBytes(using: .utf8))")
        UserService.updateAvatar(photo: base64).subscribe(onNext:{
            if $0.success == 1 {
                Toast.showSuccess(withStatus: "Upload Success")
            } else {
                Toast.showError(withStatus: $0.message)
            }
            self.addPhotoButton.stopAnimation()
        },onError: { e in
            self.addPhotoButton.stopAnimation()
        }).disposed(by: rx.disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
}
