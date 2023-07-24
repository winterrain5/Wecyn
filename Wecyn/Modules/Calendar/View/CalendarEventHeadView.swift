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
    var gregorian = NSCalendar(identifier: .gregorian)
    var dateSelected:((Date)->())!
    var monthChanged:((Date)->())!
    var eventDates:[[EventListModel]] = [] {
        didSet {
            calendar.reloadData()
        }
    }
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
        calendar.rowHeight = (kScreenWidth - 36) / 7
        calendar.placeholderType = .none
        calendar.headerHeight = 0
        calendar.appearance.weekdayFont = UIFont.sk.pingFangRegular(14)
        calendar.appearance.weekdayTextColor = R.color.textColor52()!
        
        calendar.appearance.todayColor = R.color.theamColor()?.withAlphaComponent(0.4)
        calendar.appearance.todaySelectionColor = R.color.theamColor()?.withAlphaComponent(0.4)
        
        calendar.firstWeekday = 1
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "FSCalendarCell")
        self.calendar.locale = NSLocale.init(localeIdentifier: "en") as Locale
        
        
        calendar.sk.addBorderBottom(borderWidth: 1, borderColor: .lightText)
        
        self.addSubview(calendar)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        calendar.frame =  self.bounds
        calendar.height = self.bounds.height - 1
    }


}

extension CalendarEventHeadView:FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "FSCalendarCell", for: date, at: position)
        return cell
    }
    
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let date = calendar.currentPage
        if let changeDate = date.string().date(withFormat: "dd/MM/yyyy HH:mm") {
            monthChanged(changeDate)
        }
        
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
        calendar.frame = CGRect(origin: calendar.frame.origin, size: bounds.size)
        self.layoutIfNeeded()
    }
    
    func setCalendarScope(_ scope:FSCalendarScope) {
        calendar.setScope(scope, animated: true)
    }
}
