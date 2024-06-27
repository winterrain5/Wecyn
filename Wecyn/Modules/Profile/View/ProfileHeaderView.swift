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
    
    @IBOutlet weak var jobTitleLabel: UILabel!
    
    @IBOutlet weak var rightArrowImageView: UIImageView!
    
    var uplodaImageComplete:(()->())?
    var userInfoModel: UserInfoModel? {
        didSet {
            guard let userInfoModel = userInfoModel else { return }
            
            nameLabel.text = userInfoModel.first_name + " " + userInfoModel.last_name
            jobTitleLabel.text = userInfoModel.headline
            userAvatarImageView.kf.setImage(with: userInfoModel.avatar.url)
            backImgView.kf.setImage(with: userInfoModel.cover.url)
            backImgView.blur(withStyle: .light)
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
   
}


