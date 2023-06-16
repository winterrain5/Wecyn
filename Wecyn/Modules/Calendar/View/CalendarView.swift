//
//  CalendarView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/15.
//

import UIKit
import FSCalendar
class CalendarView: UIView {
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var preButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var shareButton: UIButton!
    
    
    @IBOutlet weak var calendar: FSCalendar!
    var gregorian = NSCalendar(identifier: .gregorian)
    let dateFormatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let currentDate = Date()
        
        calendar.dataSource = self
        calendar.delegate = self
        
        calendar.appearance.selectionColor = R.color.theamColor()
        calendar.appearance.titleDefaultColor = R.color.textColor52()!
        calendar.appearance.titleFont = UIFont.sk.pingFangSemibold(15)
        calendar.appearance.caseOptions = .weekdayUsesUpperCase
        calendar.appearance.eventDefaultColor = .clear
        calendar.scope = .month
        calendar.appearance.borderRadius = 0.2
        calendar.rowHeight = (kScreenWidth - 36) / 7
        calendar.placeholderType = .none
        calendar.headerHeight = 0
        calendar.appearance.weekdayFont = UIFont.sk.pingFangSemibold(15)
        calendar.appearance.weekdayTextColor = R.color.textColor162C46()!
        calendar.firstWeekday = 1
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "FSCalendarCell")
        self.calendar.locale = NSLocale.init(localeIdentifier: "en") as Locale
        
       
        dateFormatter.dateFormat = "MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "en")
        dateLabel.text = dateFormatter.string(from: currentDate)
        
        print(currentDate.string(withFormat: "MMMM yyyy"))
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addShadow(cornerRadius: 22)
    }

}

extension CalendarView:FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "FSCalendarCell", for: date, at: position)
        return cell
    }
    
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let date = calendar.currentPage
        dateLabel.text = dateFormatter.string(from: date)
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
    
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
    }
    
}
