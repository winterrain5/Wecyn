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
    @IBOutlet weak var addButton: UIButton!
    
    
    @IBOutlet weak var calendar: FSCalendar!
    var gregorian = NSCalendar(identifier: .gregorian)
    
    var dateSelected:((Date)->())!
    var monthChanged:((Date)->())!
    var eventDates:[[EventListModel]] = [] {
        didSet {
            calendar.reloadData()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let currentDate = Date()
        
        calendar.dataSource = self
        calendar.delegate = self
        
        calendar.appearance.selectionColor = R.color.theamColor()
        calendar.appearance.titleDefaultColor = R.color.textColor52()!
        calendar.appearance.titleFont = UIFont.sk.pingFangSemibold(15)
        calendar.appearance.caseOptions = .weekdayUsesUpperCase
        calendar.scope = .month
        calendar.appearance.borderRadius = 0.2
        calendar.rowHeight = (kScreenWidth - 36) / 7
        calendar.placeholderType = .none
        calendar.headerHeight = 0
        calendar.appearance.weekdayFont = UIFont.sk.pingFangSemibold(15)
        calendar.appearance.weekdayTextColor = R.color.textColor162C46()!
        
        calendar.appearance.todayColor = R.color.theamColor()?.withAlphaComponent(0.4)
        calendar.appearance.todaySelectionColor = R.color.theamColor()?.withAlphaComponent(0.4)
        
        calendar.firstWeekday = 1
        calendar.register(FSCalendarCell.self, forCellReuseIdentifier: "FSCalendarCell")
        self.calendar.locale = NSLocale.init(localeIdentifier: "en") as Locale
        
       
        dateLabel.text = currentDate.string(format: "MMM yyyy")
        
        preButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            let pre = self.calendar.currentPage.adding(.month, value: -1)
            self.calendar.setCurrentPage(pre, animated: true)
        }).disposed(by: rx.disposeBag)
        
        nextButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            let next = self.calendar.currentPage.adding(.month, value: 1)
            self.calendar.setCurrentPage(next, animated: true)
            
        }).disposed(by: rx.disposeBag)
        
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
        dateLabel.text = date.string(format: "MMM yyyy")
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
    
}
