//
//  CalendarHeaderView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/15.
//

import UIKit

class CalendarHeaderView: UIView {

    var calendarView = CalendarView.loadViewFromNib()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(calendarView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        calendarView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(20)
        }
        
    }

}
