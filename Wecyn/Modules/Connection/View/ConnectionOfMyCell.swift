//
//  ConnectionOfMyCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/19.
//

import UIKit

class ConnectionOfMyCell: UITableViewCell {
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var shadowView: UIView!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var connectDurationLabel: UILabel!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    var deleteFriendHandler: ((FriendListModel)->())!
    
    var model: FriendListModel? {
        didSet {
            guard let model = model else { return }
            avatarView.kf.setImage(with: model.avatar.avatarUrl,placeholder: R.image.proile_user()!)
            nameLabel.text = model.full_name
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        shadowView.addShadow(cornerRadius: 12)
        deleteButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.deleteFriendHandler(self.model!)
        }).disposed(by: rx.disposeBag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
