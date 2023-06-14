//
//  HomeHeaderJobItemCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/13.
//

import UIKit

class HomeHeaderJobItemCell: UICollectionViewCell {

    @IBOutlet weak var shadowView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        shadowView.addShadow(cornerRadius: 13)
    }

}
