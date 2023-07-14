//
//  CalendarEventRepeatUntilController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/13.
//

import UIKit

class CalendarEventRepeatUntilModel {
    var title:String
    var value:String
    var isSelect:Bool
    init(title: String, value: String = "", isSelect: Bool = false) {
        self.title = title
        self.value = value
        self.isSelect = isSelect
    }
}

class CalendarEventRepeatUntilController: BaseTableController {
    
    var selectComplete:((Int,RWMRecurrenceEnd?)->())?
    var datas:[[CalendarEventRepeatUntilModel]] = []
    var selectIndex:Int = -1
    var selectDate: Date?
    var end:RWMRecurrenceEnd?
    
    init(selectIndex:Int, end:RWMRecurrenceEnd?) {
        self.selectIndex = selectIndex
        self.end = end
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addLeftBarButtonItem()
        self.leftButtonDidClick = { [weak self] in
            guard let `self` = self else { return }
            self.selectComplete?(self.selectIndex, self.end)
            self.navigationController?.popViewController(animated: true)
        }
        
        
        
        let m1 = CalendarEventRepeatUntilModel(title: "Forever")
        let m2 = CalendarEventRepeatUntilModel(title: "Date")
        let m3 = CalendarEventRepeatUntilModel(title: "Count", value: "1")
        datas.append([m1,m2,m3])
        
        datas.flatMap({ $0 }).enumerated().forEach({ [weak self] in
            guard let `self` = self else { return }
            $1.isSelect = $0 == self.selectIndex
        })
        
        self.navigation.item.title = "Repeat Until"
        
        guard let end = end else { return }
        if end.count > 0 && self.selectIndex == 2 {
            datas[0][2].value = end.count.string
        }
        
        if let date = end.endDate, self.selectIndex == 1{
            datas[0][1].value = date.string(format: "dd MMM yyyy HH:mm")
        }
    }
    
    override func createListView() {
        configTableview(.insetGrouped)
        
        tableView?.register(cellWithClass: UITableViewCell.self)
        tableView?.register(cellWithClass: CalendarEventStepperCell.self)
        tableView?.register(cellWithClass: CalendarEventRepeatUntilDateCell.self)
        
        tableView?.backgroundColor = R.color.backgroundColor()
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorStyle = .singleLine
        tableView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: kBottomsafeAreaMargin + 40, right: 0)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return selectIndex == 1 ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return selectIndex == 1  ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 52
        } else {
            return 240
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 || indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
                
                let model = datas[indexPath.section][indexPath.row]
                cell.textLabel?.text = model.title
                cell.textLabel?.font = UIFont.sk.pingFangRegular(15)
                cell.textLabel?.textColor = R.color.textColor52()!
                
                cell.accessoryType = model.isSelect ? .checkmark : .none
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withClass: CalendarEventStepperCell.self)
                
                let model = datas[indexPath.section][indexPath.row]
                cell.countModel = model
                cell.stepperCountDidChanged = { [weak self] item, value in
                    guard let `self` = self else { return }
                    
                    self.selectIndex = 2
                    self.datas.flatMap({ $0 }).forEach({ $0.isSelect = false })
                    self.end = RWMRecurrenceEnd(occurrenceCount: value, end: nil)
                    self.tableView?.reloadData()
                    
                }
                
                return cell
            }
            
        } else {
            let cell = tableView.dequeueReusableCell(withClass: CalendarEventRepeatUntilDateCell.self)
            if let end = self.end,let date = end.endDate {
                cell.datePicker.date = date
            }
            
            cell.dateChangedHandler = { [weak self] date in
                guard let `self` = self else { return }
                self.selectIndex = 1
                
                let dateStr = date.string(format: "dd MMM yyyy HH:mm")
                
                self.datas[0][1].value = dateStr
                // count 置为0
                self.datas[0][2].value = "0"
                
                self.end = RWMRecurrenceEnd(occurrenceCount: 1, end: date)
                
                self.tableView?.reloadData()
            }
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        datas.flatMap({ $0 }).forEach({ $0.isSelect = false })
        
        datas[indexPath.section][indexPath.row].isSelect.toggle()
        
        self.selectIndex = indexPath.row
        
        tableView.reloadData()
        
        if indexPath.section == 0 {
            if indexPath.row == 0 { // forever
                self.datas[0][1].value = ""
                self.datas[0][2].value = ""
                self.end = nil
                self.tableView?.reloadData()
            }
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let sectionView = CalendarEventSectionView()
            sectionView.label.text =  datas[0][1].value.isEmpty ? "" : "repeat until to \(datas[0][1].value)"
            return sectionView
        }
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 40 : 20
    }
}

class CalendarEventRepeatUntilDateCell: UITableViewCell {
    var datePicker = UIDatePicker()
    var dateChangedHandler:((Date)->())?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        datePicker.datePickerMode = .dateAndTime
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.date = Date()
        datePicker.locale = Locale(identifier: "en")
        datePicker.minimumDate = Date()
        
        contentView.addSubview(datePicker)
        
        datePicker.rx.controlEvent(.valueChanged).subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.dateChangedHandler?(self.datePicker.date)
        }).disposed(by: rx.disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        datePicker.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
}
