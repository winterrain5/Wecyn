//
//  CalendarEventHeadView.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/20.
//

import UIKit
import FSCalendar

class CalendarEventHeadView: UIView {
    
    
    var weekModeCalendar = FSCalendar()
    var monthModeCalendar = FSCalendar()
    let changeScopButton = UIButton()
    var gregorian = NSCalendar(identifier: .gregorian)
    var dateSelected:((CalendarViewMode,Date)->())!
    var monthChanged:((Date)->())!
    var scopChanged:((CGFloat,FSCalendarScope)->())!
    var eventDates:[[EventListModel]] = [] {
        didSet {
            weekModeCalendar.reloadData()
            monthModeCalendar.reloadData()
        }
    }
    
    var calendarHeight:CGFloat = 175
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       
        configWeekModeCalendar()
        configMonthModeCalendar()
      
        changeScopButton.imageForNormal = R.image.chevronCompactUp()!
        changeScopButton.imageForSelected = R.image.chevronCompactDown()!
        changeScopButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.changeScopButton.isSelected.toggle()
            if self.weekModeCalendar.scope == .week {
                self.setCalendarScope(.month)
            } else {
                self.setCalendarScope(.week)
            }
            
        }).disposed(by: rx.disposeBag)
        self.addSubview(changeScopButton)
      
      
    }
    
    func configWeekModeCalendar() {
       
        configCalendarDelegate(weekModeCalendar)
        
        configCalendarAppearance(weekModeCalendar)
        
        configCalendarOtherProperty(weekModeCalendar)
        
        weekModeCalendar.register(FSCalendarCell.self, forCellReuseIdentifier: "FSCalendarCell")
        weekModeCalendar.scrollDirection = .horizontal
        self.addSubview(weekModeCalendar)
    }
    
    func configMonthModeCalendar() {
        configCalendarDelegate(monthModeCalendar)
        
        configCalendarAppearance(monthModeCalendar)
        monthModeCalendar.appearance.titleSelectionColor = .black
        
        configCalendarOtherProperty(monthModeCalendar)
        
        monthModeCalendar.register(MonthModeCalendarCell.self, forCellReuseIdentifier: "MonthModeCalendarCell")
        monthModeCalendar.scrollDirection = .vertical
        self.addSubview(monthModeCalendar)
        monthModeCalendar.isHidden = true
    }
    
    func configCalendarAppearance(_ calendar:FSCalendar) {
        
        calendar.appearance.selectionColor = R.color.theamColor()
        calendar.appearance.titleDefaultColor = R.color.textColor33()!
        calendar.appearance.titleFont = UIFont.sk.pingFangRegular(14)
        calendar.appearance.caseOptions = .weekdayUsesUpperCase
        calendar.appearance.weekdayFont = UIFont.sk.pingFangRegular(14)
        calendar.appearance.weekdayTextColor = R.color.textColor33()!
        calendar.appearance.titlePlaceholderColor = UIColor(hexString: "dfdfdf")
        
        if calendar == weekModeCalendar {
            calendar.appearance.titleTodayColor = .white
        } else {
            calendar.appearance.titleTodayColor = .red
        }
    }
    
    func configCalendarDelegate(_ calendar:FSCalendar){
        calendar.dataSource = self
        calendar.delegate = self
    }
    
    func configCalendarOtherProperty(_ calendar:FSCalendar) {
        calendar.firstWeekday = 1
        calendar.locale = Locale.current
        calendar.select(Date())
        
        calendar.appearance.borderRadius = 0.2
        calendar.headerHeight = 0
        
        if calendar == weekModeCalendar {
            calendar.placeholderType = .fillSixRows
        } else {
            calendar.placeholderType = .none
        }
        calendar.scope = .month
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        monthModeCalendar.frame = CGRect(x: 0, y: 0, width: self.width, height: kScreenHeight - kTabBarHeight - kNavBarHeight)

        weekModeCalendar.snp.remakeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(self.calendarHeight)
        }
        changeScopButton.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(weekModeCalendar.snp.bottom)
            make.height.equalTo(20)
        }
       
    }


}

extension CalendarEventHeadView:FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        if calendar == weekModeCalendar {
            let cell = calendar.dequeueReusableCell(withIdentifier: FSCalendarCell.className, for: date, at: position)
            return cell
        } else {
            let cell = calendar.dequeueReusableCell(withIdentifier: MonthModeCalendarCell.className, for: date, at: position)
            let monthModeCell = cell as! MonthModeCalendarCell
            let models = eventDates.filter({
                guard let startDate = $0.first?.start_date else { return false }
                return date.month == startDate.month && date.day == startDate.day
            }).first
            
            if let models = models {
                monthModeCell.models = models
            }
            return cell
        }
     
    }
    
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let date = calendar.currentPage // 当前页的最后一天
        monthChanged(date)
    }
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        
        for models in eventDates {
            guard let _date = models.first?.start_date else { break }
            
            if _date.month == date.month && _date.day == date.day{
                let colors = models.map({ UIColor(hexString: $0.colorHexString ?? "" ) ?? .clear })
                return colors
            }
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        for models in eventDates {
            guard let _date = models.first?.start_date else { break }
            if _date.month == date.month && _date.day == date.day {
                let count = models.count
                return count
            }
        }
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if calendar == weekModeCalendar {
            dateSelected(.schedule,date)
        } else {
            dateSelected(.month,date)
        }
        
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
       
        if calendar == weekModeCalendar {
            self.calendarHeight = bounds.size.height
            UIView.animate(withDuration: 0.5) {
                self.setNeedsLayout()
                self.layoutIfNeeded()
                self.scopChanged(bounds.size.height,self.weekModeCalendar.scope)
            }
        }
       
       
    }
    
    func setCalendarScope(_ scope:FSCalendarScope) {
       
        weekModeCalendar.setScope(scope, animated: true)
        
    }
    
    func setCalendarMode(_ mode:CalendarViewMode) {
        
        if mode ==  .month {
            monthModeCalendar.isHidden = false
            monthModeCalendar.alpha = 1
            
            weekModeCalendar.isHidden = true
            changeScopButton.isHidden = true
        } else  {
            monthModeCalendar.isHidden = true
            monthModeCalendar.alpha = 0
            
            weekModeCalendar.isHidden = false
            changeScopButton.isHidden = false
        }
     
    }
    
    
    func setCalendarSelectDate(_ date:Date) {
        monthModeCalendar.select(date, scrollToDate: true)
        weekModeCalendar.select(date, scrollToDate: true)
    }
}
