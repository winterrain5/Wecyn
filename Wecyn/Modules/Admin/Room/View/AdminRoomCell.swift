//
//  AdminRoomCell.swift
//  Wecyn
//
//  Created by Derrick on 2024/1/9.
//

import UIKit

class AdminRoomCell: UITableViewCell {

    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var departmentLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    var deleteHandler:((AdminRoomModel)->())?
    var editHandler:((AdminRoomModel)->())?
    var model:AdminRoomModel? {
        didSet {
            guard let model = model else { return }
            nameLabel.text = model.name
            departmentLabel.text = model.dept.name
            addressLabel.text = model.dept.addr
            remarkLabel.text = model.remark
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let action1 = UIAction(title: "Edit",image: R.image.pencilLine()!) { [weak self] _ in
            guard let `self` = self,let model = self.model else { return }
            self.editHandler?(model)
        }
       
        let action2 = UIAction(title: "QR Code",image: R.image.qrcode()!) { [weak self] _ in
          
        }
        
        let action3 = UIAction(title: "Delete",image: UIImage.trash?.tintImage(.red),attributes: .destructive) { [weak self] _ in
            guard let `self` = self,let model = self.model else { return }
            self.deleteHandler?(model)
        }
        
        moreButton.showsMenuAsPrimaryAction = true
        let menus = [action1,action2,action3]
        moreButton.menu = UIMenu(children: menus)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
        
    }
    
}
