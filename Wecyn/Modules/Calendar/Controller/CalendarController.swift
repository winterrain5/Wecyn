//
//  CalendarController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/15.
//

import UIKit
import RxSwift
enum DataViewType {
    case Timeline
    case UpComing
}
class CalendarController: BaseTableController {
    let currentDate = Date().string(withFormat: "yyyy-MM-dd")
    let headerView = CalendarHeaderView()
    let sectionView = CalendarSectionView.loadViewFromNib()
    var startDate:String?
    var endDate:String?
    var friendList:[FriendListModel] = []
    var dataViewType: DataViewType = .UpComing
    var isSelectCalendar = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startDate = currentDate
        
        let label = UILabel().text("Calendar").color(R.color.textColor162C46()!).font(UIFont.sk.pingFangSemibold(20))
        self.navigation.item.leftBarButtonItem = UIBarButtonItem(customView: label)
    
        let searchView = NavbarSearchView(placeholder: "Search Event Title")
        searchView.size = CGSize(width: kScreenWidth * 0.45, height: 36)
        self.navigation.item.titleView = searchView
        searchView.isSearchable = false
        searchView.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
            let vc = EventSearchViewController()
            self.navigationController?.pushViewController(vc, animated: false)
        }).disposed(by: rx.disposeBag)
        
        addRightBarItems()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadNewData()
    }
    
    override func refreshData() {
        let eventList = ScheduleService.eventList(keyword: nil,
                                                    startDate: startDate,
                                                    endDate: endDate)
        let friendList = FriendService.friendList()
        
        Observable.zip(eventList,friendList).subscribe(onNext:{ events,friends in
            events.forEach({ event in
                
                let friend = friends.first(where: { $0.id == event.creator_id })
                event.creator_name = String.fullName(first: friend?.fn ?? "", last: friend?.ln ?? "")
                event.creator_avatar = friend?.avt ?? ""
            })
            var datas = events
            
            if self.isSelectCalendar {
                // 删除开始时间不是当天的事件
                datas.removeAll(where: {
                    !($0.start_time.date(withFormat: "yyyy-MM-dd HH:mm:ss")?.isWithin(0, .day, of: self.startDate?.date(withFormat: "yyyy-MM-dd") ?? Date()) ?? false)
                })
                self.dataArray = datas
            } else {
                var dict:[String:[EventListModel]] = [:]
                datas.forEach { model in
                    let key = model.start_time.date(withFormat: "yyyy-MM-dd HH:mm:ss")?.string(withFormat: "yyyy-MM-dd") ?? ""
                    if dict[key] != nil {
                        dict[key]?.append(model)
                    } else {
                        dict[key] = [model]
                    }
                }
                dict.values.sorted(by: {
                    guard let start = $0.first?.start_time.date(withFormat: "yyyy-MM-dd HH:mm:ss"),let end = $1.first?.start_time.date(withFormat: "yyyy-MM-dd HH:mm:ss") else {
                        return false
                    }
                    return start.compare(end)  ==  .orderedAscending
                }).forEach({ self.dataArray.append($0) })
            }
           
            self.endRefresh(.NoData, emptyString: "No Events")
            
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype)
        }).disposed(by: rx.disposeBag)
        
     
    }
    
    override func createListView() {
        super.createListView()
        
        registRefreshHeader()
        
        headerView.size = CGSize(width: kScreenWidth, height: 280)
        tableView?.tableHeaderView = headerView
        headerView.calendarView.dateSelected = { [weak self] date in
            guard let `self` = self else { return }
            
            self.isSelectCalendar = true
            self.startDate = date.string(withFormat: "yyyy-MM-dd")
            self.endDate = date.string(withFormat: "yyyy-MM-dd")
            self.loadNewData()
        }
        
        sectionView.dateRangeFilter = { start, end in
            self.dataViewType = .Timeline
            self.isSelectCalendar = false
            self.startDate = start
            self.endDate = end
            self.loadNewData()
        }
        
        sectionView.dataViewTypeChanged = { type in
            self.dataViewType = type
            self.isSelectCalendar = false
            if type == .Timeline {
                self.startDate = nil
                self.endDate = nil
            } else {
                self.startDate = self.currentDate
                self.endDate = nil
            }
            self.loadNewData()
        }
        
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kBottomsafeAreaMargin + kTabBarHeight, right: 0)
        
        tableView?.register(nibWithCellClass: CaledarItemCell.self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.isSelectCalendar ? 2 : self.dataArray.count + 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else {
            if self.isSelectCalendar {
                return self.dataArray.count
            } else {
                if self.dataArray.count > 0 {
                    return (self.dataArray as! [[EventListModel]])[section - 1].count
                }
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 113
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: CaledarItemCell.self)
        if self.isSelectCalendar, dataArray.count > 0 {
            let model = dataArray[indexPath.row] as? EventListModel
            cell.model = model
        } else {
            if self.dataArray.count > 0,indexPath.section >= 1 {
                cell.model = (self.dataArray as! [[EventListModel]])[indexPath.section - 1][indexPath.row]
            }
        }
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return sectionView
        } else {
            if self.isSelectCalendar { return nil }
            if self.dataArray.count > 0,section >= 1  {
                let view = UIView().backgroundColor(.white)
                let label = UILabel().color(R.color.textColor52()!).font(UIFont.sk.pingFangSemibold(15))
                view.addSubview(label)
                label.frame = CGRect(x: 28, y: 0, width: 100, height: 30)
                label.text = (self.dataArray as! [[EventListModel]])[section - 1].first?.start_time.date(withFormat: "yyyy-MM-dd HH:mm:ss")?.string(withFormat: "dd MMM yyyy")
                return view
            }
            return nil
           
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return dataViewType == .UpComing ? 50 : 104
        } else {
            return isSelectCalendar ? 0 : 30
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var model:EventListModel!
        if isSelectCalendar {
            model = dataArray[indexPath.row] as? EventListModel
        } else {
            model = (dataArray as! [[EventListModel]])[indexPath.section - 1][indexPath.row]
        }
        let vc = EventDetailController(eventModel:model)
        let nav = BaseNavigationController(rootViewController: vc)
        vc.container.operateCompleteHandler = { [weak self] in
            guard let `self` = self else { return }
            self.loadNewData()
        }
        self.present(nav, animated: true)
    }
    
}


