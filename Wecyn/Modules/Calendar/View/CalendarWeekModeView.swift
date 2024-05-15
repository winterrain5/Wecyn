//
//  CalendarWeekModeView.swift
//  Wecyn
//
//  Created by Derrick on 2024/5/13.
//

import UIKit
import JZCalendarWeekView

class CalendarWeekModeView: UIView {
    
    var calendarWeekView = WeekModeView()
    var numberofDays:Int = 3
    var initDate:Date = Date()
    var pageDidChange:((Date)->())?
    var models:[EventListModel] = []  {
        didSet {
            models.removeAll(where: { $0.isCrossDayMiddle || $0.isCrossDayEnd })
            let events:[WeekEvent] = models.map({
                return WeekEvent(model: $0)
            })
            // Basic setup
            let allEvents = JZWeekViewHelper.getIntraEventsByDate(originalEvents: events)
            
            calendarWeekView.setupCalendar(numOfDays: numberofDays,
                                           setDate: initDate,
                                           allEvents: allEvents,
                                           scrollType: .pageScroll)
            
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configWeekView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configWeekView() {
        calendarWeekView.baseDelegate = self
        calendarWeekView.numOfDays  = numberofDays
        calendarWeekView.initDate = initDate
        // Optional
        calendarWeekView.updateFlowLayout(JZWeekViewFlowLayout(hourGridDivision: JZHourGridDivision.noneDiv))
        
        addSubview(calendarWeekView)
    }
    
    func updateWeekView(to date:Date) {
        calendarWeekView.updateWeekView(to: date)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        calendarWeekView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}

extension CalendarWeekModeView: JZBaseViewDelegate {
    
    func initDateDidChange(_ weekView: JZCalendarWeekView.JZBaseWeekView, initDate: Date) {
       
    }
    
    func pageDidChange(_ weekView: JZBaseWeekView) {
        let dates = weekView.getDatesInCurrentPage(isScrolling: false)
        let date = dates.first?.toString(format:"yyyy-MM-dd HH:mm:ss").toDate(format: "yyyy-MM-dd HH:mm:ss",isZero: true) ?? Date()
        print(date)
        pageDidChange?(date)
    }
}
class WeekModeView: JZBaseWeekView {
    
    override func registerViewClasses() {
        super.registerViewClasses()
        
        self.collectionView.register(cellWithClass: WeekModeCell.self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: WeekModeCell.self, for: indexPath)
        
        let event = getCurrentEvent(with: indexPath) as? WeekEvent
        cell.event = event
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let event = getCurrentEvent(with: indexPath) as? WeekEvent
        guard let model = event?.model else { return }
        let vc = CalendarEventDetailController(eventModel: model)
        UIViewController.sk.getTopVC()?.navigationController?.pushViewController(vc, animated: true)
    }
}

class WeekModeCell: UICollectionViewCell {
    let titleLabel = UILabel().color(.white).font(.systemFont(ofSize: 12,weight: .semibold))
    
    var event: WeekEvent? {
        didSet {
            guard let event = event else { return }
            let time = event.startDate.toString(format:"HH:mm") + " - " + event.endDate.toString(format: "HH:mm")
            titleLabel.text = event.model.title + "\n" + time
            guard let color = event.model.colorHexString else { return }
            backgroundColor = UIColor.init(hexString: color)?.withAlphaComponent(0.8)
        }
    }
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview().inset(2)
        }
    }
}

class WeekEvent: JZBaseEvent {

    var model:EventListModel
    init(model:EventListModel) {
        self.model = model
        if model.isCrossDay {
            
        }
        let startDate = model.start_date!
        let endDate = model.end_date!
        // If you want to have you custom uid, you can set the parent class's id with your uid or UUID().uuidString (In this case, we just use the base class id)
        super.init(id: model.id.string, startDate: startDate, endDate: endDate)
    }

    override func copy(with zone: NSZone?) -> Any {
        return WeekEvent(model: model)
    }
}
