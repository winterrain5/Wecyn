//
//  AdminStaffExpsCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/29.
//

import UIKit

class AdminStaffExpsCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    var model:AdminStaffExps! {
        didSet {
            nameLabel.text = model.title_name
            var endDate = (model.is_current == 1) ? "Present" : model.end_date
            dateLabel.text = model.end_date + " - " + endDate
            descLabel.text = model.desc
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
