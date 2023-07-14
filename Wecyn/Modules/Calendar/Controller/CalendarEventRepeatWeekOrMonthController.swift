//
//  CalendarEventRepeatWeekOrMonthController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/13.
//

import UIKit

class WeekOrMonthModel {
    var title:String
    var value:Int
    var isSelect = false
    
    init(title: String, value: Int, isSelect: Bool = false) {
        self.title = title
        self.value = value
        self.isSelect = isSelect
    }
    
}
let MonthData = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
let WeekData = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
class CalendarEventRepeatWeekOrMonthController: BaseTableController {
    
    enum WeekOrMonthType {
        case Week
        case Month
    }
    var datas:[WeekOrMonthModel] = []
    
    var type:WeekOrMonthType
    var selectIndexs:[Int] = [0]
    var selectComplete:(([Int])->())?
    init(type:WeekOrMonthType,selectIndexs:[Int] = [0]) {
        self.type = type
        self.selectIndexs = selectIndexs
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
            self.selectComplete?(self.selectIndexs)
            self.navigationController?.popViewController(animated: true)
        }
        
        
        if type == .Month {
            datas = MonthData.enumerated().map({
                let isSelect = self.selectIndexs.contains($0)
                return WeekOrMonthModel(title: $1, value: $0, isSelect: isSelect)
            })
            self.navigation.item.title = "ByMonth"
        } else {
            
            datas = WeekData.enumerated().map({
                let isSelect = self.selectIndexs.contains($0)
                return WeekOrMonthModel(title: $1, value: $0, isSelect: isSelect)
            })
            self.navigation.item.title = "ByWeekday"
        }
        
    }
    
    override func createListView() {
        configTableview(.insetGrouped)
        
        tableView?.rowHeight = 52
        tableView?.register(cellWithClass: UITableViewCell.self)
        
        tableView?.backgroundColor = R.color.backgroundColor()
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorStyle = .singleLine
        tableView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: kBottomsafeAreaMargin + 40, right: 0)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
        let model = datas[indexPath.row]
        cell.textLabel?.text = model.title
        cell.textLabel?.font = UIFont.sk.pingFangRegular(15)
        cell.textLabel?.textColor = R.color.textColor52()!
        
        cell.accessoryType = model.isSelect ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.selectIndexs.removeAll()
        
        datas[indexPath.row].isSelect.toggle()
        
        tableView.reloadData()
        
        datas.enumerated().forEach({ [weak self] in
            guard let `self` = self else { return }
            if  $1.isSelect {
                self.selectIndexs.append($0)
            }
        })
    }
}
