//
//  CalendarEventHeadView.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/20.
//

import UIKit
import FSCalendar

class CalendarEventHeadView: UIView {
    
    
    var calendar = FSCalendar()
    let changeScopButton = UIButton()
    var gregorian = NSCalendar(identifier: .gregorian)
    var dateSelected:((Date)->())!
    var monthChanged:((Date)->())!
    var scopChanged:((CGFloat,FSCalendarScope)->())!
    var eventDates:[[EventListModel]] = [] {
        didSet {
            calendar.reloadData()
        }
    }
    
    var calendarHeight:CGFloat = 195
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        calendar.dataSource = self
        calendar.delegate = self
        
        calendar.appearance.selectionColor = R.color.theamColor()
        calendar.appearance.titleDefaultColor = R.color.textColor52()!
        calendar.appearance.titleFont = UIFont.sk.pingFangRegular(14)
        calendar.appearance.caseOptions = .weekdayUsesUpperCase
        calendar.scope = .month
        calendar.appearance.borderRadius = 0.2
        calendar.placeholderType = .fillSixRows
        calendar.headerHeight = 0
        calendar.appearance.weekdayFont = UIFont.sk.pingFangRegular(14)
        calendar.appearance.weekdayTextColor = R.color.textColor52()!
        calendar.appearance.titlePlaceholderColor = UIColor(hexString: "dfdfdf")
        calendar.appearance.titleTodayColor = R.color.textColor52()!
        calendar.appearance.todayColor = .white
        
        calendar.firstWeekday = 1
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "FSCalendarCell")
        calendar.locale = NSLocale.init(localeIdentifier: "en") as Locale
        calendar.select(Date())
    
        self.addSubview(calendar)
        
      
        changeScopButton.imageForNormal = R.image.chevronCompactUp()!
        changeScopButton.imageForSelected = R.image.chevronCompactDown()!
        changeScopButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.changeScopButton.isSelected.toggle()
            if self.calendar.scope == .week {
                self.setCalendarScope(.month)
            } else {
                self.setCalendarScope(.week)
            }
            
        }).disposed(by: rx.disposeBag)
        self.addSubview(changeScopButton)
      
      
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        calendar.snp.remakeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(self.calendarHeight)
        }
        changeScopButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(calendar.snp.bottom)
            make.height.equalTo(20)
        }
       
    }


}

extension CalendarEventHeadView:FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "FSCalendarCell", for: date, at: position)
        return cell
    }
    
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let date = calendar.currentPage // 当前页的最后一天
        print("currentPage:\(date)")
        monthChanged(date)
    }
    
    //  func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
    //    if dataArray.map({ $0.date ?? Date() }).contains(date) {
    //      return true
    //    }
    //    return false
    //  }
    
    //  func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
    //    if dataArray.map({ $0.date ?? Date() }).contains(date) {
    //      return R.color.black333()
    //    }
    //    return R.color.gray82()
    //  }
    
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
        dateSelected(date)
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeight = bounds.size.height
        UIView.animate(withDuration: 0.5) {
            self.setNeedsLayout()
            self.layoutIfNeeded()
            self.scopChanged(bounds.size.height,self.calendar.scope)
        }
       
    }
    
    func setCalendarScope(_ scope:FSCalendarScope) {
        calendar.setScope(scope, animated: true)
    }
    
    func setCalendarSelectDate(_ date:Date) {
        calendar.select(date, scrollToDate: true)
    }
}
