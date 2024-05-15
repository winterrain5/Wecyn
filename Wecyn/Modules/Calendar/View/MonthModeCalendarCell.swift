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
                if (model.is_repeat == 1) && model.repeat_idx == 0 {
                    self.layer.zPosition = 10000
                    contentView.clipsToBounds = false
                    clipsToBounds = false
                } else {
                    contentView.clipsToBounds = true
                    clipsToBounds = true
                }

                view.model = model
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
        let margin = 2.cgFloat
        titleView.subviews.enumerated().forEach { idx,view in
            let y = ( viewHeight + margin ) * idx.cgFloat
            let itemView = view as! MonthModelCalendarItemView
            let text = itemView.model.title
            let itemWidth = text.widthWithConstrainedWidth(height: 20, font: UIFont.systemFont(ofSize: 12))
            let width:CGFloat
            if idx == titleView.subviews.count - 1 {
                width = self.width
            } else {
                width = (itemWidth >= self.width) ? self.width : itemWidth
            }
            
            view.frame = CGRect(x: 0, y: y, width: width, height: viewHeight)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleView.removeSubviews()
    }
    
}

class MonthModelCalendarItemView: UIView {
    
    let label = UILabel().color(.white).font(UIFont.systemFont(ofSize: 12))

    var model: EventListModel = EventListModel() {
        didSet {
        
            backgroundColor =  UIColor(hexString: EventColor.allColor[model.color])?.withAlphaComponent(0.8)
            
            let text = model.title
            if model.isCrossDay {
                if model.isCrossDayStart {
                    label.text = text
                } else {
                    label.text = ""
                }
            } else if model.is_repeat == 1 {
                if model.repeat_idx == 0 {
                    layer.zPosition = 10000
                    label.text = text
                } else {
                    label.text = ""
                }
            } else {
                label.text = text
            }
        }
    }
    
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = false
        addSubview(label)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
        }
    }
}
