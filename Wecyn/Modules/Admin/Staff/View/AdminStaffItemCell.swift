//
//  AdminStaffItemCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/29.
//

import UIKit

class AdminStaffItemCell: UITableViewCell {
    @IBOutlet weak var avatarImgView: UIImageView!
    
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var titlesLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    var editHandler:((AdminStaffModel)->())?
    
    var model:AdminStaffModel? {
        didSet {
            guard let model = model else { return }
            
            avatarImgView.kf.setImage(with: model.user?.avatar.url)
            let roleName = (model.role == nil) ? "Normal Staff" : (model.role?.dept_full_path ?? "")
            nameLabel.text = (model.user?.first_name ?? "") + " "  + (model.user?.last_name ?? "") + "(\(roleName))"
            titlesLabel.text = model.titles
            departmentLabel.text = model.dept?.full_path
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        let action1 = UIAction(title: "Edit",image: R.image.pencilLine()!) { [weak self] _ in
            guard let `self` = self,let model = self.model else { return }
            
            let vc = AdminEditStaffController(model: model)
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            UIViewController.sk.getTopVC()?.present(nav, animated:true)
        }
    
        moreButton.showsMenuAsPrimaryAction = true
   
        moreButton.menu = UIMenu(children: [action1])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
