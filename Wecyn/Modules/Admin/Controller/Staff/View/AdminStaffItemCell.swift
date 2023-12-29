//
//  AdminStaffItemCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/29.
//

import UIKit

class AdminStaffItemCell: UITableViewCell {
    @IBOutlet weak var avatarImgView: UIImageView!
    
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var titlesLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var model:AdminStaffModel? {
        didSet {
            guard let model = model else { return }
            
            avatarImgView.kf.setImage(with: model.user?.avatar.url)
            nameLabel.text = (model.user?.first_name ?? "") + " "  + (model.user?.last_name ?? "")
            titlesLabel.text = model.titles
            departmentLabel.text = model.dept?.full_path
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
