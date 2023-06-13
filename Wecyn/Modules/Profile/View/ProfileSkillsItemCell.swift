//
//  ProfileSkillsItemCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/12.
//

import UIKit
import TTGTags
class ProfileSkillsItemCell: UITableViewCell {

    let tagView = UIView()
    let skills =  ["User Interface Design ","User Experience", "Adobe Photoshop","Adobe Illustrator","Web Design"]
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(tagView)
        skills.forEach({
            let label = UILabel()
            label.borderWidth = 1
            label.borderColor = R.color.theamColor()!
            label.text = $0
            label.textAlignment = .center
            label.textColor = R.color.theamColor()!
            label.font = UIFont.sk.pingFangSemibold(12)
            label.addShadow(cornerRadius: 8)
            tagView.addSubview(label)
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tagView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tagView.subviews.enumerated().forEach { i,label in
            let marign = 30.cgFloat
            let spacing = 10.cgFloat
            let width = (kScreenWidth - 70) / 2
            let height = 36.cgFloat
            let row = i / 2
            let col = i % 2
            let x = marign + (width + spacing) * col.cgFloat
            let y = spacing + (height + spacing) * row.cgFloat
            label.frame = CGRect(x: x, y: y, width: width, height: height)
        }
    }
}
