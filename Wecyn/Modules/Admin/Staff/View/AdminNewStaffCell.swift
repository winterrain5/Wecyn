//
//  AdminNewStaffCell.swift
//  Wecyn
//
//  Created by Derrick on 2024/1/2.
//

import UIKit

class AdminNewStaffCell: UITableViewCell {
    @IBOutlet weak var avatarImgView: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var titlesLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    var model:AdminNewStaffModel? {
        didSet {
            guard let model = model else { return }
            
            avatarImgView.kf.setImage(with: model.user?.avatar.url)
            nameLabel.text = (model.user?.first_name ?? "") + " "  + (model.user?.last_name ?? "")
            titlesLabel.text = "job title: " + (model.title_name ?? "")
            messageLabel.text = model.user_remark
            dateLabel.text = "start date: " + (model.start_date ?? "")
            timeLabel.text = "apply time: " + (model.apply_time ?? "")
        }
    }
    var operateHandler:((Int,AdminNewStaffModel)->())?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let action1 = UIAction(title: "Accept",image: R.image.personFillCheckmark()!) { [weak self] _ in
            guard let `self` = self,let model = self.model else { return }
            self.operateHandler?(1,model)
        }
        let action2 = UIAction(title: "Reject",image: R.image.personFillXmark()!,attributes: .destructive) { [weak self] _ in
            guard let `self` = self,let model = self.model else { return }
            self.operateHandler?(2,model)
        }
        
        moreButton.showsMenuAsPrimaryAction = true
     
        moreButton.menu = UIMenu(children: [action1,action2])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
