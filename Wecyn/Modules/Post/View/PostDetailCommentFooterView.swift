//
//  PostDetailCommentFooterView.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/18.
//

import UIKit

class PostDetailCommentFooterView: UIView {

    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var addCommentButton: UIButton!
    @IBOutlet weak var avatarImgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let user = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className) {
            avatarImgView.kf.setImage(with: user.avatar.url)
        }
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
