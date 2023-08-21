//
//  CreatePostToolBar.swift
//  Wecyn
//
//  Created by Derrick on 2023/8/18.
//

import UIKit

class CreatePostToolBar: UIView {

    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var hastagButton: UIButton!
    @IBOutlet weak var atButton: UIButton!
    @IBOutlet weak var emojiButton: UIButton!
    @IBOutlet weak var imageButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadow(ofColor: R.color.backgroundColor()!,radius: 6, offset: CGSize(width: 0, height: -6))
    }
}
