//
//  MonthModeCalendarCell.swift
//  Wecyn
//
//  Created by Derrick on 2024/5/11.
//

import UIKit
import FSCalendar

class MonthModeCalendarCell: FSCalendarCell {
    var titleView = UIView()

    var models:[EventListModel] = [] {
        didSet {
            models.enumerated().forEach { idx,model in
                
                let view = MonthModelCalendarItemView()
                view.model = model
                view.layer.zPosition = 100
                titleView.addSubview(view)
            }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    override init!(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.removeSubviews()
        contentView.addSubview(titleLabel)
        
        contentView.addSubview(titleView)
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        titleLabel.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
        }
        titleView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom)
        }
        let viewHeight = 20.cgFloat
        let margin = 4.cgFloat
        titleView.subviews.enumerated().forEach { idx,view in
            let y = viewHeight * idx.cgFloat + margin
            view.frame = CGRect(x: 0, y: y, width: self.width, height: viewHeight)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleView.removeSubviews()
    }
    
}

class MonthModelCalendarItemView: UIView {
    
    let label = UILabel().color(.white).font(UIFont.systemFont(ofSize: 12))

    var model: EventListModel? {
        didSet {
            guard let model = model else { return }
           
            backgroundColor =  UIColor(hexString: EventColor.allColor[model.color])
           
            if model.isCrossDay {
                if model.isCrossDayStart {
                    label.text = model.title
                } else {
                    label.text = ""
                }
            } else if model.is_repeat == 1 {
                if model.repeat_idx == 0 {
                    label.text = model.title
                } else {
                    label.text = ""
                }
            } else {
                label.text = model.title
            }
        }
    }
    
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
