//
//  BusinessCardCell.swift
//  Wecyn
//
//  Created by Derrick on 2024/6/28.
//

import UIKit
import MMBAlertsPickers
class BusinessCardCell: UICollectionViewCell {

    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    var data:UserInfoModel? {
        didSet {
            guard let data = data else { return }
            nameLabel.text = data.full_name
            titleLabel.text = data.headline
            emailLabel.text = data.email
            backgroundImageView.kf.setImage(with: data.cover_url)
            profileImageView.kf.setImage(with: data.avatar_url)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        shareButton.rx.tap.subscribe(onNext:{
            Haptico.selection()
            let vc = BusinessCardShareController()
            UIViewController.sk.getTopVC()?.present(vc, animated: true)
            
        }).disposed(by: rx.disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        shadow(cornerRadius: 16, color: .black.withAlphaComponent(0.2), offset: CGSize(width: 0, height: 2), radius: 10, opacity: 1)
    }

}
