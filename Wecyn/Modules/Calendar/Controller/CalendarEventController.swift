//
//  CalendarEventController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/20.
//

import UIKit

import RxSwift
import RxLocalizer
import PopMenu
import FSCalendar

enum DateFormat:String {
    /// dd-MM-yyyy HH:mm
    case ddMMyyyyHHmm = "dd-MM-yyyy HH:mm"
    /// yyyy-MM-dd HH:mm:ss
    case yyyyMMddHHmmss = "yyyy-MM-dd HH:mm:ss"
    /// dd-MM-yyyy
    case ddMMyyyy = "dd-MM-yyyy"
}

var CalendarBelongUserId:Int = 0
var CalendarBelongUserName:String = ""
class CalendarEventController: BaseTableController {
    
    let headerView = CalendarEventHeadView()
    let requestModel = EventListRequestModel()
    var friendList:[FriendListModel] = []
    let userTitleView = CalendarNavBarUserView()
    var selectAssistant = AssistantInfo()
    var assistants: [AssistantInfo] = []
    let UserModel = UserDefaults.userModel
    var calendarChangeDate = Date()
    let headerHeight = 215.cgFloat
    var isTaped:Bool = false
    var currentScope:FSCalendarScope = .week
    let monthLabel = UILabel()
    var isDataLoaded = false
    var latesMonth:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CalendarBelongUserId = UserModel?.id.int ?? 0
        CalendarBelongUserName = UserModel?.full_name ?? ""
        
        requestModel.start_date = calendarChangeDate.toString()
        requestModel.current_user_id = CalendarBelongUserId
        
        selectAssistant.id = UserModel?.id.int ?? 0
        selectAssistant.name = UserModel?.full_name ?? ""
        selectAssistant.avatar = UserModel?.avatar ?? ""
        
        
        let searchButton = UIButton()
        searchButton.size = CGSize(width: 36, height: 36)
        searchButton.imageForNormal = R.image.magnifyingglass()
        searchButton.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
            let vc = EventSearchViewController()
            self.navigationController?.pushViewController(vc, animated: false)
        }).disposed(by: rx.disposeBag)
        let searchItem = UIBarButtonItem(customView: searchButton)
        self.navigation.item.rightBarButtonItem = searchItem
        
        
        monthLabel.textColor = R.color.textColor52()!
        monthLabel.size = CGSize(width: 60, height: 30)
        monthLabel.textAlignment = .left
        monthLabel.font = UIFont.sk.pingFangSemibold(20)
        monthLabel.text = calendarChangeDate.toString(format: "MMM")
        self.navigation.item.leftBarButtonItem = UIBarButtonItem(customView: monthLabel)
        
        userTitleView.size = CGSize(width: kScreenWidth * 0.7, height: 40)
        userTitleView.selectAssistantHanlder = { [weak self] assistant in
            guard let `self` = self else { return }
            CalendarBelongUserId = assistant.id
            CalendarBelongUserName = assistant.name
            
            self.selectAssistant = assistant
            
            self.requestModel.current_user_id = assistant.id
            
            self.refreshData()
        }
        self.navigation.item.titleView = userTitleView
        
        
        
        CalendarMenuView.addMenu(originView: self.view)

       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAssistants()
        latesMonth = 0
        refreshData()
    }
    
    override func refreshData() {
        
        if latesMonth == calendarChangeDate.month, isBeginLoad == false {
            return
        }
        
        self.dataArray.removeAll()
        
        latesMonth = calendarChangeDate.month
        
        let eventList = ScheduleService.eventList(model: requestModel)
        
        let sd = calendarChangeDate.startOfCurrentMonth()
        let ed = sd.endOfCurrentMonth()
        requestModel.start_date = sd.string(withFormat: DateFormat.ddMMyyyy.rawValue)
        requestModel.end_date = ed.string(withFormat: DateFormat.ddMMyyyy.rawValue)
        
        eventList.subscribe(onNext:{ events in
            Asyncs.async {
                var datas = events
                //重复事件处理
                datas.forEach { data in
                    if data.is_repeat == 1 {
                        data.isParentData = true
                        var copyed:[EventListModel] = data.rruleObject?.occurrences(rrulestr:data.rrule_str, between: sd, and: ed).map({
                            let model = data.copyed($0)
                            return model
                        }) ?? []
                        copyed.removeAll(where: { copymodel in
                            data.exdatesObject.contains(where: { copymodel.start_date?.day == $0?.day })
                        })
                        datas.append(contentsOf: copyed)
                    } else {
                        let day:Double = 24 * 60 * 60
                        if data.duration >= day {
                            let count = data.duration / day + 1
                            data.isParentData = true
                            var copyed:[EventListModel] = []
                            for i in 0..<count.int {
                                guard let start_date = data.start_date,let end_date = data.end_date else { return }
                                let startDate = start_date.adding(.day, value: i)
                                let endDate = (i == count.int - 1) ? end_date : nil
                                let model = data.copyed(startDate,endDate: endDate,isCrossDays: true)
                                model.isCrossDayStart = i == 0
                                model.isCrossDayEnd = i == (count.int - 1)
                                model.isCrossDayMiddle =  i > 0 && i < (count.int - 1)
                                model.isCrossDay = true
                                copyed.append(model)
                            }
                            datas.append(contentsOf: copyed)
                        }
                    }
                }
                datas.removeAll(where: { $0.isParentData })
                
                /// 日历事件显示
                var dict:[String:[EventListModel]] = [:]
                datas.forEach { model in
                    let key = model.start_time.date(withFormat: DateFormat.ddMMyyyyHHmm.rawValue)?.toString(format: DateFormat.ddMMyyyy.rawValue) ?? ""
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
            } mainTask: {
                self.headerView.eventDates = self.dataArray as! [[EventListModel]]
                
                self.endRefresh(.NoData, emptyString: "No Events")
                
                if !self.isDataLoaded {
                    self.scrollToSection(false)
                }
                self.isDataLoaded = true
            }

            
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype,emptyString: e.asAPIError.errorInfo().message)
            self.hideSkeleton()
        }).disposed(by: rx.disposeBag)
        
        
    }
    
    func scrollToSection(_ animated:Bool = true){
        let datas = self.dataArray as! [[EventListModel]]
        if datas.count == 0 { return }
        let section = datas.firstIndex(where: {
            return $0.first?.start_date?.day == self.calendarChangeDate.day && $0.first?.start_date?.month == self.calendarChangeDate.month
        })?.uInt ?? 0
        self.tableView?.scrollToRow(at: IndexPath(row: 0, section: Int(section)), at: .top, animated: animated)
    }
    
    func getAssistants() {
        ScheduleService.recieveAssistantList().subscribe(onNext:{ models in
            self.userTitleView.assistants = models
            self.assistants = models
        }).disposed(by: rx.disposeBag)
    }
    
    
    override func createListView() {
        super.createListView()
        
        registRefreshHeader()
        
        headerView.frame.origin = CGPoint(x: 0, y: kNavBarHeight)
        headerView.size = CGSize(width: kScreenWidth, height: headerHeight)
        self.view.addSubview(headerView)
        headerView.dateSelected = { [weak self] date in
            guard let `self` = self else { return }
            self.isTaped = true
            self.calendarChangeDate = date
            self.scrollToSection()
        }
        
        headerView.monthChanged = { [weak self] date in
            guard let `self` = self else { return }
            self.calendarChangeDate = date
            self.monthLabel.text = date.toString(format: "MMM")
            self.refreshData()
        }
        
        headerView.scopChanged = { [weak self] height,scope in
            self?.currentScope = scope
            let totalH = height + 20
            self?.headerView.frame.size.height = totalH
            self?.tableView?.frame = CGRect(x: 0, y: kNavBarHeight + totalH, width: kScreenWidth, height: kScreenHeight - kNavBarHeight - kTabBarHeight - totalH)
        }
        
        tableView?.separatorStyle = .singleLine
        tableView?.separatorColor = R.color.seperatorColor()!
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kBottomsafeAreaMargin + kTabBarHeight + 10, right: 0)
        
        tableView?.isSkeletonable = true
        tableView?.register(nibWithCellClass: CaledarItemCell.self)
        cellIdentifier = CaledarItemCell.className
    }
    
    override func listViewFrame() -> CGRect {
        return CGRect(x: 0, y: kNavBarHeight + headerHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight - kTabBarHeight - headerHeight)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let datas = self.dataArray as! [[EventListModel]]
        if datas.count > 0,section < datas.count, datas[section].count > 0 {
            return datas[section].count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 92
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: CaledarItemCell.self)
        let datas = self.dataArray as! [[EventListModel]]
        if datas.count > 0,indexPath.section < datas.count,datas[indexPath.section].count > 0 {
            cell.model = (self.dataArray as! [[EventListModel]])[indexPath.section][indexPath.row]
        }
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let datas = self.dataArray as! [[EventListModel]]
        if  datas.count > 0,section < datas.count, datas[section].count > 0 {
            guard let dataDate = datas[section].first?.start_time.date(withFormat: DateFormat.ddMMyyyyHHmm.rawValue) else {
                return nil
            }
            let view = UIView()
            let label = UILabel().font(UIFont.sk.pingFangRegular(14))
            
            if dataDate.isInToday{
                label.text = "Today " + dataDate.toString(format: "dd MMM EEE")
                label.textColor = R.color.theamColor()
                view.backgroundColor = UIColor(hexString: "#d0ebe9")
                
            } else {
                label.text = dataDate.toString(format: "dd MMM EEE")
                label.textColor = R.color.textColor52()!
                view.backgroundColor = R.color.backgroundColor()!
            }
            
            view.addSubview(label)
            label.frame = CGRect(x: 16, y: 0, width: 200, height: 30)
            
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let datas = self.dataArray as! [[EventListModel]]
        if  datas.count > 0,indexPath.section < datas.count, datas[indexPath.section].count > 0, indexPath.row < datas[indexPath.section].count {
            let model = datas[indexPath.section][indexPath.row]
            
            let vc = CalendarEventDetailController(eventModel:model)
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
       
    }
    var lastContentOffsetY:CGFloat = 0


    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastContentOffsetY = scrollView.contentOffset.y
        isTaped = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isTaped { return }
        if scrollView.contentOffset.y > lastContentOffsetY{ // 上滑
            self.headerView.setCalendarScope(.week)
        }
    }
    deinit {
        CalendarBelongUserId = 0
        CalendarBelongUserName = ""
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -headerHeight * 0.5
    }
}


class CalendarNavBarUserView: UIView {
    let avatar = UIImageView()
    let nameLabel = UILabel()
    let arrow = UIImageView()
    var assistants: [AssistantInfo] = [] {
        didSet {
            let selfModel = AssistantInfo()
            selfModel.id = userModel?.id.int ?? 0
            selfModel.name = userModel?.full_name ?? ""
            selfModel.avatar = userModel?.avatar ?? ""
            assistants.insert(selfModel, at: 0)
            
        }
    }
    let userModel = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)
    var selectRow = 0
    var selectAssistantHanlder:((AssistantInfo)->())!
    
    lazy var menu:CalendarAssistantMenu = {
        let originView = UIViewController.sk.getTopVC()?.view
        let menu = CalendarAssistantMenu(assistants: assistants, originView: originView!, selectRow: self.selectRow)
        return menu
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(avatar)
        addSubview(nameLabel)
        addSubview(arrow)
        
        avatar.kf.setImage(with: userModel?.avatar.avatarUrl,placeholder: R.image.proile_user())
        avatar.cornerRadius = 12
        avatar.contentMode = .scaleAspectFill
        
        nameLabel.text = userModel?.full_name
        nameLabel.textColor = R.color.textColor52()
        nameLabel.font = UIFont.sk.pingFangRegular(14)
        nameLabel.width = userModel?.full_name.widthWithConstrainedWidth(height: 40, font: nameLabel.font) ?? 0
        
        arrow.image = R.image.triangleFill()
        
        rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            self?.showMenu()
        }).disposed(by: rx.disposeBag)
        
       
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameLabel.height = 40
        nameLabel.y = 0
        nameLabel.center.x = self.center.x
        
        avatar.frame = CGRect(x: nameLabel.x - 38, y: 0, width: 24, height: 24)
        avatar.center.y = self.center.y
        
        arrow.frame = CGRect(x: nameLabel.frame.maxX + 8, y: 0, width: 15, height: 11)
        arrow.center.y = self.center.y
        
        
    }
    
    func showMenu() {
      
        if menu.isShowed {
            self.arrow.rotate(toAngle: -180, ofType: .degrees,  duration: 0.25)
            menu.hideMenu()
            return
        }
        
        if assistants.count == 0 {
            return
        }
        self.arrow.rotate(toAngle: 180, ofType: .degrees, duration: 0.25)
        
        
        
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
