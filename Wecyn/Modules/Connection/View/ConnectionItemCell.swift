//
//  ConnectionItemCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/16.
//

import UIKit
class ConnectionItemCell: UICollectionViewCell {
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var avatarImgView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    var model: FriendUserInfoModel? {
        didSet {
            guard let model = model else { return }
            
            avatarImgView.kf.setImage(with: model.avatar.url,placeholder: R.image.proile_user()!)
            nameLabel.text = model.full_name
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.textAlignment = .center
        shadowView.addShadow(cornerRadius: 13)
        connectButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            
            NetworkService.addFriend(userId: self.model?.id ?? 0).subscribe(onNext:{ status in
                if status.success == 1 {
                    Toast.showSuccess( "Send Apply Success")
                } else {
                    Toast.showMessage(status.message)
                }
            }).disposed(by: self.rx.disposeBag)
            
        }).disposed(by: rx.disposeBag)
    }

}
