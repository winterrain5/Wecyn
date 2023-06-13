//
//  RegistAddAvatarView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/12.
//

import UIKit
import ImagePickerSwift
class RegistAddAvatarView: UIView {

    @IBOutlet weak var avatarContainer: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var companyLabel: UILabel!
    
    @IBOutlet weak var locationlLabel: UILabel!
    
    @IBOutlet weak var addPhotoButton: UIButton!
  
    @IBOutlet weak var skipLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarContainer.addShadow(cornerRadius: 21)
        
        addPhotoButton.addShadow(cornerRadius: 20)
        
        skipLabel.sk.setSpecificTextUnderLine("Skip", color: R.color.textColor52()!)
        
        addPhotoButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            let option = ImagePickerOptions.default
            option.resizeWidth = 128
            option.resizeScale = 1
            ImagePicker.show(type: .selectPhoto, with: option) { image, path in
                self.avatarImageView.image = image
            }
        }).disposed(by: rx.disposeBag)
        
        skipLabel.rx.tapGesture().when(.recognized).subscribe(onNext:{ _ in
            let main = MainController()
            UIApplication.shared.keyWindow?.rootViewController = main
        }).disposed(by: rx.disposeBag)
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
}
