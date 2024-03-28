//
//  NotificationCell.swift
//  Wecyn
//
//  Created by Derrick on 2024/2/27.
//

import UIKit

class NotificationCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var shadowView: UIView!
    var model:NotificationModel! {
        didSet {
            titleLabel.text = model.title
            timeLabel.text = model.create_time
            contentLabel.text = model.content
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        shadowView.addShadow(cornerRadius: 8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
