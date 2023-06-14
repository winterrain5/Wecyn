//
//  JobItemCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/13.
//

import UIKit

class JobItemCell: UITableViewCell {

    @IBOutlet weak var shaowView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        shaowView.addShadow(cornerRadius: 16)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
