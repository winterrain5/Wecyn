//
//  CalendarEventRepeatController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/12.
//

import UIKit
import EventKit
enum CalendarFrequencyType: String {
    case Not
    case Daily
    case Weekly
    case Monthly
    case Yearly
    
    var unit: String {
        switch self {
        case .Not:
            return ""
        case .Daily:
            return "day"
        case .Weekly:
            return "week"
        case .Monthly:
            return "month"
        case .Yearly:
            return "year"
        }
    }
    
    func toString() -> String {
        switch self {
        case .Not: return ""
        case .Daily: return "DAILY"
        case .Weekly: return "WEEKLY"
        case .Monthly: return "MONTHLY"
        case .Yearly: return "YEARLY"
        }
    }
}
enum CalendarRepeatCellType {
    case Frequency
    case Interval
    case Byweekday
    case Bymonth
    case Until
}
class EventRepeatModel {
    var title:String
    var frequencyType: CalendarFrequencyType?
    var cellType:CalendarRepeatCellType
    var isSelect:Bool
    var value: String
    
    init(title: String, cellType:CalendarRepeatCellType, value: String = "", frequencyType: CalendarFrequencyType? = nil, isSelect:Bool = false) {
        self.title = title
        self.cellType = cellType
        self.value = value
        self.frequencyType = frequencyType
        self.isSelect = isSelect
    }
}



class CalendarEventRepeatController: BaseTableController {
    
    var models:[[EventRepeatModel]] = []
    var selectFrequencyModel:EventRepeatModel!
    var rrule:RecurrenceRule?
    let sectionView = CalendarEventSectionView()
    var untilSelectIndex:Int = -1
    var repeatSelectComplete:((RecurrenceRule?)->())?
    init(rrule:RecurrenceRule?) {
        self.rrule = rrule
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigation.item.title = "Repeat"
        
        let none = EventRepeatModel(title: "None", cellType: .Frequency, frequencyType: .Not,isSelect: true)
        let daily = EventRepeatModel(title: "Daily", cellType: .Frequency, frequencyType: .Daily)
        let weekly = EventRepeatModel(title: "Weekly", cellType: .Frequency, frequencyType: .Weekly)
        let monthly = EventRepeatModel(title: "Monthly", cellType: .Frequency, frequencyType: .Monthly)
        let yearly = EventRepeatModel(title: "Yearly", cellType: .Frequency, frequencyType: .Yearly)
        
        let freSection = [none,daily,weekly,monthly,yearly]
        models.append(freSection)
        
        if let rrule = self.rrule {
            models.flatMap({ $0 }).forEach({
                if $0.frequencyType?.toString() == rrule.frequency.toString()  {
                    $0.isSelect = true
                    self.selectFrequencyModel = $0
                } else {
                    $0.isSelect = false
                }
            })
            addOtherSection(self.selectFrequencyModel)
            repeatDescription()
        } else {
            
            self.selectFrequencyModel = none
        }
        
        
        
        let saveButton = UIButton()
        saveButton.size = CGSize(width: 30, height: 30)
        saveButton.contentMode = .right
        saveButton.imageForNormal = R.image.checkmark()
        saveButton.rx.tap.subscribe(onNext:{ [weak self] in
            self?.repeatSelectComplete?(self?.rrule)
            self?.returnBack()
        }).disposed(by: rx.disposeBag)
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        
        self.addLeftBarButtonItem(image: R.image.xmark()!)
        self.leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }
        
    }
    
    func addDaySection() -> [EventRepeatModel]{
        var section: [EventRepeatModel]  = []
        let interval = EventRepeatModel(title: "Interval", cellType: .Interval, value: "1")
        let until = EventRepeatModel(title: "Until", cellType: .Until)
        section.append(contentsOf: [interval,until])
        section.forEach({ $0.frequencyType = .Daily })
        return section
    }
    
    func addWeekSection() -> [EventRepeatModel]{
        var section: [EventRepeatModel]  = []
        
        let interval = EventRepeatModel(title: "Interval", cellType: .Interval, value: "1")
        let until = EventRepeatModel(title: "Until", cellType: .Until)
        let byweekday = EventRepeatModel(title: "By Weekday", cellType: .Byweekday)
        let bymonth = EventRepeatModel(title: "By Month", cellType: .Bymonth)
        
        section.append(contentsOf: [interval,byweekday,bymonth,until])
        section.forEach({ $0.frequencyType = .Weekly })
        return section
    }
    
    func addMonthSection() -> [EventRepeatModel]{
        var section: [EventRepeatModel]  = []
        
        let interval = EventRepeatModel(title: "Interval", cellType: .Interval, value: "1")
        let until = EventRepeatModel(title: "Until", cellType: .Until)
        let byweekday = EventRepeatModel(title: "By Weekday", cellType: .Byweekday)
        let bymonth = EventRepeatModel(title: "By Month", cellType: .Bymonth)
        
        section.append(contentsOf: [interval,byweekday,bymonth,until])
        section.forEach({ $0.frequencyType = .Monthly })
        return section
    }
    
    func addYearSection() -> [EventRepeatModel]{
        var section: [EventRepeatModel]  = []
        let interval = EventRepeatModel(title: "Interval", cellType: .Interval, value: "1")
        let until = EventRepeatModel(title: "Until", cellType: .Until)
        section.append(contentsOf: [interval,until])
        section.forEach({ $0.frequencyType = .Yearly })
        return section
    }
    
    override func createListView() {
        configTableview(.insetGrouped)
        
        tableView?.register(cellWithClass: CalendarEventFrequencyCell.self)
        tableView?.register(cellWithClass: CalendarEventArrowCell.self)
        tableView?.backgroundColor = R.color.backgroundColor()
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorStyle = .singleLine
        tableView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: kBottomsafeAreaMargin + 40, right: 0)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        52
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section][indexPath.row]
        
        switch model.cellType {
        case .Frequency:
            let cell = tableView.dequeueReusableCell(withClass: CalendarEventFrequencyCell.self)
            cell.model = model
            return cell
        case .Interval:
            let cell = CalendarEventStepperCell()
            cell.model = model
            cell.selectionStyle = .none
            cell.stepperIntervalDidChanged = { [weak self] item,value in
                guard let `self` = self else { return }
                if item.cellType == .Interval {
                    self.rrule?.interval = value
                }
                
                self.repeatDescription()
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withClass: CalendarEventArrowCell.self)
            cell.model = model
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        Haptico.selection()
        
        models.flatMap({ $0 }).forEach({ $0.isSelect = false })
        
        let model = models[indexPath.section][indexPath.row]
        
       
        if model.cellType == .Frequency {
            model.isSelect.toggle()
            self.selectFrequencyModel = models.flatMap({ $0 }).filter({ $0.isSelect }).first
           
            addOtherSection(model)
            
            rrule?.interval = 1
            rrule?.recurrenceEnd = EKRecurrenceEnd(occurrenceCount: 1)
            
            repeatDescription()
        }
        
        
        if model.cellType == .Byweekday {
            var selectIndexs:[Int] = []
            if model.value.isEmpty == false {
                selectIndexs = model.value.split(separator: ",").map({ String($0).int ?? 0 })
            }
            let vc = CalendarEventSingelChooseController(type: .Week, selectIndexs: selectIndexs)
            vc.selectComplete = { [weak self] weekIdx in
                guard let `self` = self else { return }
                
                let weekdays = weekIdx.map({
                    EKWeekday(rawValue: $0 + 1)!
                })
                
                self.rrule?.byweekday = weekdays.count == 0 ? [] : weekdays
                
                let value = weekIdx.map({ $0.string }).joined(separator: ",")
                self.models[1][1].value = value
                
                self.repeatDescription()
                self.tableView?.reloadRows(at: [IndexPath(row: 1, section: 1)], with: .none)
                
            }
            
            self.navigationController?.pushViewController(vc)
        }
        
        if model.cellType == .Bymonth {
            var selectIndexs:[Int] = []
            if model.value.isEmpty == false {
                selectIndexs = model.value.split(separator: ",").map({ String($0).int ?? 0 })
            }
            let vc = CalendarEventSingelChooseController(type: .Month, selectIndexs: selectIndexs)
            vc.selectComplete = { [weak self] monthIdx in
                guard let `self` = self else { return }
                
                self.rrule?.bymonth = monthIdx.map({ $0 + 1 })
                
                let value = monthIdx.map({ $0.string }).joined(separator: ",")
                self.models[1][2].value = value
                
                self.repeatDescription()
                self.tableView?.reloadRows(at: [IndexPath(row: 2, section: 1)], with: .none)
            }
            self.navigationController?.pushViewController(vc)
        }
        
        if model.cellType == .Until {
            let vc = CalendarEventRepeatUntilController(selectIndex: self.untilSelectIndex, end: self.rrule?.recurrenceEnd)
            vc.selectComplete = { idx, end in
                self.untilSelectIndex = idx
                if end?.endDate != nil {
                    self.models[1].last?.value = end?.endDate?.toString(format: "dd MMM yyyy") ?? ""
                } else {
                    if (end?.occurrenceCount ?? 0) > 1 {
                        let unit = (end?.occurrenceCount ?? 0) > 0 ? "times" : "time"
                        self.models[1].last?.value = (end?.occurrenceCount.string ?? "") + " \(unit)"
                    } else {
                        self.models[1].last?.value = "Forever"
                    }
                }
                
                
                self.rrule?.recurrenceEnd = end
                
                self.repeatDescription()
                self.tableView?.reloadSections(IndexSet(integer: 1), with: .none)
            }
            self.navigationController?.pushViewController(vc)
        }
        
    }
    
    func addOtherSection(_ model:EventRepeatModel) {
        func removeLast() {
            if models.count == 2 {
                models.removeLast()
            }
        }
        switch model.frequencyType {
        case .Not:
            removeLast()
            rrule = nil
        case .Daily:
            removeLast()
            models.append(addDaySection())
            rrule = RecurrenceRule(frequency: .daily)
        case .Weekly:
            removeLast()
            models.append(addWeekSection())
            rrule = RecurrenceRule(frequency: .weekly)
        case .Monthly:
            removeLast()
            models.append(addMonthSection())
            rrule = RecurrenceRule(frequency: .monthly)
        case .Yearly:
            removeLast()
            models.append(addYearSection())
            rrule = RecurrenceRule(frequency: .yearly)
        case .none:
            Logger.debug("none")
        }
        tableView?.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 { return nil }
        if selectFrequencyModel.frequencyType == .Not {
            return nil
        }
        return sectionView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 { return 20}
        if selectFrequencyModel.frequencyType == .Not {
            return 20
        }
        return 80
    }
    
    func repeatDescription(){
        /// Repeat every 2 days in January and May on Monday for 10 times
        /// Repeat every 1 day in January and May on Monday, Friday until July 19, 2023
        guard let rrule = rrule else { return }
        let rule = rrule.toRRuleString()
        print("rrule text:\(rule)")
        sectionView.label.text = rrule.toText()
        
    }
}

class CalendarEventFrequencyCell: UITableViewCell {
    
    var model:EventRepeatModel! {
        didSet {
            self.textLabel?.text = model.title
            self.accessoryType = model.isSelect ? .checkmark : .none
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textLabel?.textColor = R.color.textColor33()
        self.textLabel?.font = UIFont.sk.pingFangRegular(16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

class CalendarEventStepperCell: UITableViewCell {
    var stepper = UIStepper()
    var detailLabel = UILabel()
    var model:EventRepeatModel? {
        didSet {
            guard let model = model else { return }
            self.textLabel?.text = model.title
            
            updateIntervalData()
        }
    }
    var countModel:CalendarEventRepeatUntilModel? {
        didSet {
            guard let model = countModel else { return }
            self.textLabel?.text = model.title
            
            updateCountData()
        }
    }
    var stepperIntervalDidChanged:((EventRepeatModel,Int)->())?
    var stepperCountDidChanged:((CalendarEventRepeatUntilModel,Int)->())?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textLabel?.textColor = R.color.textColor33()
        self.textLabel?.font = UIFont.sk.pingFangRegular(16)
        
        contentView.addSubview(stepper)
        contentView.addSubview(detailLabel)
        detailLabel.textColor = R.color.textColor77()
        detailLabel.font = UIFont.sk.pingFangRegular(16)
        stepper.value = 1
        stepper.minimumValue = 1
        stepper.maximumValue = 999
        stepper.addTarget(self, action: #selector(stepperDidChanged), for: .valueChanged)
    
    }
    
    @objc func stepperDidChanged() {
        
        Haptico.selection()
        if let model = self.model {
            model.value =  stepper.value.int.string
            self.updateIntervalData()
            self.stepperIntervalDidChanged?(model,stepper.value.int)
        }
        
        if let model = self.countModel {
            model.value =  stepper.value.int.string
            self.updateCountData()
            self.stepperCountDidChanged?(model,stepper.value.int)
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateIntervalData() {
        guard let model = model,let value =  model.value.double() else { return }
        
        if model.cellType == .Interval {
            let hass = value > 1 ? "s" : ""
            detailLabel.text = model.value + " " + (model.frequencyType?.unit ?? "") + hass
        }
    }
    
    func updateCountData() {
        guard let model = countModel,let value =  model.value.double() else { return }
        
        let unit = value > 1 ? "times" : "time"
        if value == 0 {
            detailLabel.text = ""
        } else {
            detailLabel.text = model.value + " " + unit
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stepper.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        detailLabel.snp.makeConstraints { make in
            make.right.equalTo(stepper.snp.left).offset(-16)
            make.centerY.equalToSuperview()
        }
    }
}
class CalendarEventArrowCell: UITableViewCell {
    
    var detailLabel = UILabel()
    var model: EventRepeatModel! {
        didSet  {
            self.textLabel?.text = model.title
            if model.value.isEmpty {
                detailLabel.text = ""
                return
            }
            switch model.cellType {
            case .Until:
                detailLabel.text = model.value
            case .Byweekday:
                var value:[String] = []
                model.value.split(separator: ",").map({ String($0).int ?? 0 }).forEach({
                    value.append(WeekData[$0])
                })
                detailLabel.text = value.joined(separator: ",")
            case .Bymonth:
                var value:[String] = []
                model.value.split(separator: ",").map({ String($0).int ?? 0 }).forEach({
                    value.append(MonthData[$0])
                })
                detailLabel.text = value.joined(separator: ",")
            default:
                Logger.debug(model.cellType)
            }
            
        }
    }
    var removeAttandance:((Attendees)->())?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.textLabel?.textColor = R.color.textColor33()
        self.textLabel?.font = UIFont.sk.pingFangRegular(16)
        
        detailLabel.textColor = R.color.textColor77()
        detailLabel.font = UIFont.sk.pingFangRegular(16)
        
        contentView.addSubview(detailLabel)
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        detailLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.bottom.equalToSuperview()
        }
        
        
    }
}
class CalendarEventSectionView: UIView {
    
    var label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        label.textColor = R.color.textColor77()
        label.font = UIFont.sk.pingFangRegular(12)
        label.numberOfLines = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(8)
        }
    }
}


