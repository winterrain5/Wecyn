//
//  HomeItemCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/13.
//

import UIKit

class HomeItemCell: UITableViewCell {

    @IBOutlet weak var followButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        followButton.addShadow(cornerRadius: 5)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
