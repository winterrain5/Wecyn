//
//  AdminRoleItemCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/15.
//

import UIKit

class AdminRoleItemCell: UITableViewCell {

    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var permissionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    var deleteHandler:((AdminRoleItemModel)->())?
    var editHandler:((AdminRoleItemModel)->())?
    var model:AdminRoleItemModel? {
        didSet {
            nameLabel.text = model?.name
            permissionLabel.text = AdminPermission.allPermission(code: model?.permission ?? [])
            
            let action1 = UIAction(title: "Edit",image: R.image.pencilLine()!) { [weak self] _ in
                guard let `self` = self,let model = self.model else { return }
                self.editHandler?(model)
            }
            let action2 = UIAction(title: "Delete",image: UIImage.trash?.tintImage(.red),attributes: .destructive) { [weak self] _ in
                guard let `self` = self,let model = self.model else { return }
                self.deleteHandler?(model)
            }
            
            remarkLabel.text = model?.remark
            
            moreButton.showsMenuAsPrimaryAction = true
            let menus = [action1,action2]
        
            moreButton.menu = UIMenu(children: menus)
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
