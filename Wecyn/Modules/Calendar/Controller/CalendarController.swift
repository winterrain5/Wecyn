//
//  CalendarController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/15.
//

import UIKit
import RxSwift
import RxLocalizer
import PopMenu
enum DataViewType {
    case Timeline
    case UpComing
}

enum DateFormat:String {
    case ddMMyyyyHHmm = "dd-MM-yyyy HH:mm"
    case ddMMyyyy = "dd-MM-yyyy"
}

var CalendarBelongUserId:Int = 0
var CalendarBelongUserName:String = ""
class CalendarController: BaseTableController {
    let currentDate = Date().string(withFormat: DateFormat.ddMMyyyy.rawValue)
    let headerView = CalendarHeaderView()
    let sectionView = CalendarSectionView.loadViewFromNib()
    let requestModel = EventListRequestModel()
    var friendList:[FriendListModel] = []
    var dataViewType: DataViewType = .UpComing
    var isSelectCalendar = false
    let userTitleView = CalendarNavBarUserView()
    var selectAssistant = AssistantInfo()
    var assistants: [AssistantInfo] = []
    let UserModel = UserDefaults.userModel
    var calendarChangeDate:Date?
    let headerHeight = 280.cgFloat
    override func viewDidLoad() {
        super.viewDidLoad()
        CalendarBelongUserId = UserModel?.id ?? 0
        CalendarBelongUserName = UserModel?.full_name ?? ""
        
        requestModel.start_date = currentDate
        requestModel.current_user_id = CalendarBelongUserId
        
        selectAssistant.id = UserModel?.id ?? 0
        selectAssistant.name = UserModel?.full_name ?? ""
        selectAssistant.avatar = UserModel?.avatar ?? ""

        
        let searchView = UIButton()
        searchView.size = CGSize(width: 36, height: 36)
        searchView.imageForNormal = R.image.connection_search()
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: searchView)
        searchView.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
            let vc = EventSearchViewController()
            self.navigationController?.pushViewController(vc, animated: false)
        }).disposed(by: rx.disposeBag)
        
        userTitleView.size = CGSize(width: kScreenWidth * 0.7, height: 40)
        userTitleView.selectAssistantHanlder = { [weak self] assistant in
            guard let `self` = self else { return }
            CalendarBelongUserId = assistant.id
            CalendarBelongUserName = assistant.name
            
            self.selectAssistant = assistant
            
            self.requestModel.current_user_id = assistant.id
            
            self.loadNewData()
            self.getEventDate(date: self.calendarChangeDate ?? Date())
        }
        self.navigation.item.titleView = userTitleView
        
        
        getEventDate(date: Date())
        getAssistants()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadNewData()
    }
    
    override func refreshData() {
        
        let eventList = ScheduleService.eventList(model: requestModel)
        if isFirstLoad {
            self.view.showSkeleton()
        } else {
            Toast.showLoading()
        }
        eventList.subscribe(onNext:{ events in
            
            var datas = events
            
            if self.isSelectCalendar {
                // 删除开始时间不是当天的事件
                datas.removeAll(where: {
                    !($0.start_time.date(withFormat: DateFormat.ddMMyyyyHHmm.rawValue)?.isWithin(0, .day, of: self.requestModel.start_date?.date(withFormat: "yyyy-MM-dd") ?? Date()) ?? false)
                })
                self.dataArray = datas
            } else {
                var dict:[String:[EventListModel]] = [:]
                datas.forEach { model in
                    let key = model.start_time
                    if dict[key] != nil {
                        dict[key]?.append(model)
                    } else {
                        dict[key] = [model]
                    }
                }
                dict.values.sorted(by: {
                    guard let start = $0.first?.start_time.date(withFormat: DateFormat.ddMMyyyyHHmm.rawValue),let end = $1.first?.start_time.date(withFormat: DateFormat.ddMMyyyyHHmm.rawValue) else {
                        return false
                    }
                    return start.compare(end)  ==  .orderedAscending
                }).forEach({ self.dataArray.append($0) })
            }
            
            self.endRefresh(.NoData, emptyString: "No Events")
            self.hideSkeleton()
            Toast.dismiss()
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype)
            self.hideSkeleton()
            Toast.dismiss()
        }).disposed(by: rx.disposeBag)
        
        
    }
    
    func getAssistants() {
        ScheduleService.recieveAssistantList().subscribe(onNext:{ models in
            self.userTitleView.assistants = models
            self.assistants = models
        }).disposed(by: rx.disposeBag)
    }
    
    func getEventDate(date:Date) {
        let requsetModel = EventListRequestModel()
        let sd = date.startOfCurrentMonth()
        let ed = sd.endOfCurrentMonth()
        requsetModel.start_date = sd.string(withFormat: DateFormat.ddMMyyyy.rawValue)
        requsetModel.end_date = ed.string(withFormat: DateFormat.ddMMyyyy.rawValue)
        requsetModel.current_user_id = CalendarBelongUserId
        ScheduleService.eventList(model: requsetModel).subscribe(onNext:{ models in
            let eventDates = models.map({ ($0.start_time.date(withFormat: DateFormat.ddMMyyyyHHmm.rawValue) ??  Date()).string(withFormat: DateFormat.ddMMyyyyHHmm.rawValue) })
            self.headerView.calendarView.eventDates = eventDates
        }).disposed(by: rx.disposeBag)
    }
    
    
    override func createListView() {
        super.createListView()
        
        registRefreshHeader()
        
        headerView.size = CGSize(width: kScreenWidth, height: headerHeight)
        tableView?.tableHeaderView = headerView
        headerView.calendarView.dateSelected = { [weak self] date in
            guard let `self` = self else { return }
            
            self.isSelectCalendar = true
            self.requestModel.start_date = date.string(withFormat: DateFormat.ddMMyyyy.rawValue)
            self.requestModel.end_date = date.string(withFormat: DateFormat.ddMMyyyy.rawValue)
            self.loadNewData()
        }
        
        headerView.calendarView.addButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            //            let vc:CalendarAddEventController!
            //            if self.selectAssistant.id == self.UserModel?.id {
            //                vc = CalendarAddEventController(calendarBelongName: nil)
            //            } else {
            //                vc = CalendarAddEventController(calendarBelongName: self.selectAssistant.name)
            //            }
            
            let vc = CalendarAddNewEventController()
            self.navigationController?.pushViewController(vc)
        }).disposed(by: rx.disposeBag)
        
        headerView.calendarView.shareButton.rx.tap.subscribe(onNext:{ [weak self] in
            let vc = EventSetAssistantsController()
            let nav = BaseNavigationController(rootViewController: vc)
            self?.present(nav, animated: true)
        }).disposed(by: rx.disposeBag)
        
        headerView.calendarView.monthChanged = { [weak self] date in
            guard let `self` = self else { return }
            self.calendarChangeDate = date
            self.getEventDate(date: date)
        }
        
        sectionView.dateRangeFilter = { [weak self] start, end in
            guard let `self` = self else { return }
            self.dataViewType = .Timeline
            self.isSelectCalendar = false
            self.requestModel.start_date = start
            self.requestModel.end_date = end
            self.loadNewData()
        }
        
        sectionView.dataViewTypeChanged = {[weak self] type in
            guard let `self` = self else { return }
            self.dataViewType = type
            self.isSelectCalendar = false
            if type == .Timeline {
                self.requestModel.start_date = nil
                self.requestModel.end_date = nil
            } else {
                self.requestModel.start_date = self.currentDate
                self.requestModel.end_date = nil
            }
            self.loadNewData()
        }
        
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kBottomsafeAreaMargin + kTabBarHeight, right: 0)
        
        tableView?.isSkeletonable = true
        tableView?.register(nibWithCellClass: CaledarItemCell.self)
        cellIdentifier = CaledarItemCell.className
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
                let datas = self.dataArray as! [[EventListModel]]
                if datas.count > 0, datas[section - 1].count > 0 {
                    return datas[section - 1].count
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
                label.text = (self.dataArray as! [[EventListModel]])[section - 1].first?.start_time.date(withFormat: DateFormat.ddMMyyyyHHmm.rawValue)?.string(format: "dd MMM yyyy")
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
        let vc = CalendarEventDetailController(eventModel:model)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    deinit {
        CalendarBelongUserId = 0
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return headerHeight * 0.5
    }
}


class CalendarNavBarUserView: UIView {
    let avatar = UIImageView()
    let nameLabel = UILabel()
    let arrow = UIImageView()
    var assistants: [AssistantInfo] = [] {
        didSet {
            let selfModel = AssistantInfo()
            selfModel.id = userModel?.id ?? 0
            selfModel.name = userModel?.full_name ?? ""
            selfModel.avatar = userModel?.avatar ?? ""
            assistants.insert(selfModel, at: 0)
            
        }
    }
    let userModel = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)
    var selectRow = 0
    var selectAssistantHanlder:((AssistantInfo)->())!
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(avatar)
        addSubview(nameLabel)
        addSubview(arrow)
        
        avatar.kf.setImage(with: userModel?.avatar.avatarUrl,placeholder: R.image.proile_user()!)
        avatar.cornerRadius = 15
        avatar.contentMode = .scaleAspectFill
        
        nameLabel.text = userModel?.full_name
        nameLabel.textColor = R.color.textColor52()
        nameLabel.font = UIFont.sk.pingFangRegular(14)
        nameLabel.width = userModel?.full_name.widthWithConstrainedWidth(height: 40, font: nameLabel.font) ?? 0
        
        arrow.image = R.image.calendar_item_arrow_down()
        
        rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            self?.arrow.rotate(toAngle: 180, ofType: .degrees, duration: 0.25)
            self?.showMenu()
        }).disposed(by: rx.disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameLabel.height = 40
        nameLabel.y = 0
        nameLabel.center.x = self.center.x
        
        avatar.frame = CGRect(x: nameLabel.x - 38, y: 0, width: 30, height: 30)
        avatar.center.y = self.center.y
        
        arrow.frame = CGRect(x: nameLabel.frame.maxX + 8, y: 0, width: 15, height: 11)
        arrow.center.y = self.center.y
        
        
    }
    
    func showMenu() {
        if assistants.count == 0 {
            return
        }
        let originView = UIViewController.sk.getTopVC()?.view
        let menu = CalendarAssistantMenu(assistants: assistants, originView: originView!, selectRow: self.selectRow)
        menu.showMenu()
        menu.selectComplete = {  [weak self] row in
            guard let `self` = self else { return }
            self.selectRow = row
            self.nameLabel.text = self.assistants[row].name
            self.nameLabel.width = self.assistants[row].name.widthWithConstrainedWidth(height: 40, font: self.nameLabel.font)
            self.layoutIfNeeded()
            self.avatar.kf.setImage(with: self.assistants[row].avatar.avatarUrl,placeholder: R.image.proile_user()!)
            self.selectAssistantHanlder(self.assistants[row])
        }
        
        menu.dissmissHandler = { [weak self] in
            guard let `self` = self else { return }
            self.arrow.rotate(toAngle: -180, ofType: .degrees,  duration: 0.25)
        }
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
