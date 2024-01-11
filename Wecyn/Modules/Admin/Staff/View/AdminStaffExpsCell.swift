//
//  AdminStaffExpsCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/29.
//

import UIKit

class AdminStaffExpsCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var deleteHandler:((AdminStaffExps)->())?
    var editHandler:((AdminStaffExps)->())?
    
    var model:AdminStaffExps! {
        didSet {
            nameLabel.text = model.title_name + "," + model.industry_name
            let endDate = (model.is_current == 1) ? "Present" : model.end_date
            dateLabel.text = model.start_date + " - " + endDate
            descLabel.text = model.desc
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let action1 = UIAction(title: "Edit",image: R.image.pencilLine()!) { [weak self] _ in
            guard let `self` = self,let model = self.model else { return }
            self.editHandler?(model)
        }
       
  
        
        let action2 = UIAction(title: "Delete",image: UIImage.trash?.tintImage(.red),attributes: .destructive) { [weak self] _ in
            guard let `self` = self,let model = self.model else { return }
            self.deleteHandler?(model)
        }
        
        moreButton.showsMenuAsPrimaryAction = true
        let menus = [action1,action2]
        moreButton.menu = UIMenu(children: menus)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
