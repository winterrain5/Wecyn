//
//  CalendarEventController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/20.
//

import UIKit
import TBDropdownMenu
import RxSwift
import RxLocalizer
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
class CalendarEventController: BaseTableController,DropdownMenuDelegate {
    
    let headerView = CalendarEventHeadView()
    let requestModel = EventListRequestModel()
    var friendList:[FriendListModel] = []
    let userTitleView = CalendarNavBarUserView()
    let UserModel = UserDefaults.userModel
    var calendarChangeDate = Date()
    let headerHeight = 215.cgFloat
    var isTaped:Bool = false
    var currentScope:FSCalendarScope = .week
    let monthLabel = UILabel()
    var isDataLoaded = false
    var latesMonth:Int = 0
    var isWidgetLinkId: Int? = nil
    
    let filterButton = UIButton()
    
    var roomItems:[UserRoomModel] = []
    var roomSelectIndexPath:IndexPath?
    var roomMenu:DropdownMenu?
    
    var assistantItems:[AssistantInfo] = []
    var assistantSelectIndex = 0
    var assistantMenu:DropdownMenu?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.WidgetItemSelected, object: nil, queue: .main) { noti in
            let id = noti.object as? Int
            self.isWidgetLinkId = id
            self.loadNewData()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selectAssistant = UserDefaults.sk.get(of: UserInfoModel.self, for: "selectAssistant") {
            CalendarBelongUserId = selectAssistant.id.int ?? 0
            CalendarBelongUserName = selectAssistant.full_name
        } else {
            CalendarBelongUserId = UserModel?.id.int ?? 0
            CalendarBelongUserName = UserModel?.full_name ?? ""
        }
        
        if let selectRoom = UserDefaults.sk.get(of: MeetingRoom.self, for: "selectRoom") {
            self.requestModel.room_id = selectRoom.id
        }
   
        
        requestModel.start_date = calendarChangeDate.toString()
        requestModel.current_user_id = CalendarBelongUserId
        
        let searchButton = UIButton()
        searchButton.imageForNormal = R.image.magnifyingglass()
        searchButton.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
            let vc = EventSearchViewController()
            self.navigationController?.pushViewController(vc, animated: false)
        }).disposed(by: rx.disposeBag)
        let searchItem = UIBarButtonItem(customView: searchButton)
        
        
        filterButton.showsMenuAsPrimaryAction = true
        filterButton.imageForNormal = R.image.calendar_filter()
        filterButton.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
            Haptico.selection()
            self.getRooms()
            
        }).disposed(by: rx.disposeBag)
        let filterItem = UIBarButtonItem(customView: filterButton)
        
        let fixItem = UIBarButtonItem.fixedSpace(width: 22)
        
        self.navigation.item.rightBarButtonItems = [searchItem,fixItem,filterItem]
        
        
        
        monthLabel.textColor = R.color.textColor33()!
        monthLabel.size = CGSize(width: 60, height: 30)
        monthLabel.textAlignment = .left
        monthLabel.font = UIFont.sk.pingFangSemibold(20)
        monthLabel.text = calendarChangeDate.toString(format: "MMM")
        self.navigation.item.leftBarButtonItem = UIBarButtonItem(customView: monthLabel)
        
        userTitleView.size = CGSize(width: kScreenWidth * 0.7, height: 40)
        self.navigation.item.titleView = userTitleView
        userTitleView.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
            let items = self.assistantItems.map({
                DropdownItem(title: $0.name)
            })
            self.assistantMenu = DropdownMenu(navigationController: self.navigationController!, items: items,selectedRow: self.assistantSelectIndex)
            self.assistantMenu?.delegate = self
            self.assistantMenu?.showMenu()
            
        }).disposed(by: rx.disposeBag)
        
        
        
        CalendarMenuView.addMenu(originView: self.view)

       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        latesMonth = 0
        refreshData()
        
        getAssistants()
        
    }
    
    override func refreshData() {

        getUserInfo()
        
        if latesMonth == calendarChangeDate.month, isBeginLoad == false, self.isWidgetLinkId == nil {
            return
        }
        
        self.dataArray.removeAll()
        
        latesMonth = calendarChangeDate.month
        
        let eventList = ScheduleService.eventList(model: requestModel)
        
        guard let sd = calendarChangeDate.beginning(of: .month),let ed = sd.end(of: .month) else {
            return
        }
       
        requestModel.start_date = sd.toString(format: DateFormat.ddMMyyyy.rawValue)
        requestModel.end_date = ed.toString(format: DateFormat.ddMMyyyy.rawValue)
        
        ToastUtil.default.show(delay: 3)
        eventList.subscribe(onNext:{ events in
            ToastUtil.default.dismiss()
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
                    let key = model.start_time.toDate(format: DateFormat.ddMMyyyyHHmm.rawValue)?.toString(format: DateFormat.ddMMyyyy.rawValue) ?? ""
                    if dict[key] != nil {
                        dict[key]?.append(model)
                    } else {
                        dict[key] = [model]
                    }
                }
                var firstSortedData:[[EventListModel]] = []
                dict.values.sorted(by: {
                    guard let start = $0.first?.start_time.toDate(format: DateFormat.ddMMyyyyHHmm.rawValue),let end = $1.first?.start_time.toDate(format: DateFormat.ddMMyyyyHHmm.rawValue) else {
                        return false
                    }
                    return start.compare(end)  ==  .orderedAscending
                }).forEach({ firstSortedData.append($0) })
                
                firstSortedData.forEach({ data in
                    let secondSortedData = data.sorted(by: {
                        guard let start = $0.start_time.toDate(format: DateFormat.ddMMyyyyHHmm.rawValue),let end = $1.start_time.toDate(format: DateFormat.ddMMyyyyHHmm.rawValue) else {
                            return false
                        }
                        return start.compare(end)  ==  .orderedAscending
                    })
                    self.dataArray.append(secondSortedData)
                })
               
            } mainTask: {
                
                let eventDatas = self.dataArray as! [[EventListModel]]
                self.headerView.eventDates = eventDatas
                
                self.endRefresh(self.dataArray.count, emptyString: "No Events")
                
                if !self.isDataLoaded {
                    self.scrollToSection(false)
                }
                self.isDataLoaded = true
                
                if self.isWidgetLinkId != nil {
                    if let widgetItem = eventDatas.flatMap({ $0 }).filter({ $0.id == self.isWidgetLinkId }).first {
                        let item = DispatchWorkItem {
                            let vc = CalendarEventDetailController(eventModel: widgetItem)
                            self.navigationController?.pushViewController(vc)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: item)
                        
                    }
                        
                    self.isWidgetLinkId = nil
                }
            }

            
        },onError: { e in
            ToastUtil.default.dismiss()
            self.endRefresh(e.asAPIError.emptyDatatype,emptyString: e.asAPIError.errorInfo().message)
            self.hideSkeleton()
        }).disposed(by: rx.disposeBag)
        
        
    }
    
    func getUserInfo(){
        UserService.getUserInfo().subscribe(onNext:{ model in
            if model.color_remark.isEmpty {
                model.color_remark = Array(repeating: "", count: 12)
            }
            UserDefaults.sk.set(object: model, for: UserInfoModel.className)
            
        }).disposed(by: rx.disposeBag)
    }
    
    
    
    func getAssistants() {
        ScheduleService.recieveAssistantList().subscribe(onNext:{ models in
            let userModel = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)
          
            let selfModel = AssistantInfo()
            selfModel.id = userModel?.id.int ?? 0
            selfModel.name = userModel?.full_name ?? ""
            selfModel.avatar = userModel?.avatar ?? ""
      
            self.assistantItems = models
            
            self.assistantItems.insert(selfModel, at: 0)
            
        },onError: { e in
            
        }).disposed(by: rx.disposeBag)
        
    }
    
    func getRooms() {
        Toast.showLoading()
        UserService.userRoomList(currentUserId: CalendarBelongUserId).subscribe(onNext:{ rooms in
            Toast.dismiss()
            if rooms.count == 0 {
                Toast.showMessage("No Room")
                return
            }
            self.roomItems = rooms
            let sections = self.roomItems.map({
                DropdownSection(sectionIdentifier: $0.label, items: $0.options.map({
                    DropdownItem(title: $0.label)
                }))
            })
            if let index = self.roomSelectIndexPath {
                self.roomMenu = DropdownMenu(navigationController: self.navigationController!, sections: sections,selectedIndexPath: index)
                self.roomMenu?.displaySelected  = true
            } else {
                self.roomMenu = DropdownMenu(navigationController: self.navigationController!, sections: sections)
                self.roomMenu?.displaySelected  = false
            }
            
            self.roomMenu?.delegate = self
            self.roomMenu?.showMenu()
        },onError: { e in
            Toast.dismiss()
            Toast.showError(e.asAPIError.errorInfo().message)
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
            self?.tableView?.frame = CGRect(x: 0, y: kNavBarHeight + totalH, width: kScreenWidth, height: kScreenHeight - kNavBarHeight - totalH)
        }
        
        tableView?.separatorStyle = .singleLine
        tableView?.separatorColor = R.color.seperatorColor()!
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom:  kTabBarHeight + 10, right: 0)
        
        tableView?.isSkeletonable = true
        tableView?.register(nibWithCellClass: CaledarItemCell.self)
        cellIdentifier = CaledarItemCell.className
    }
    
    override func listViewFrame() -> CGRect {
        return CGRect(x: 0, y: kNavBarHeight + headerHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight - headerHeight)
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
                label.textColor = R.color.textColor33()!
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
    
    func dropdownMenu(_ dropdownMenu: DropdownMenu, didSelectRowAt indexPath: IndexPath) {
        
        if dropdownMenu == self.roomMenu {
            self.roomSelectIndexPath = indexPath
            
            let item = roomItems[indexPath.section].options[indexPath.row]
            self.requestModel.room_id = item.value
        }
        
        if dropdownMenu == self.assistantMenu {
            self.assistantSelectIndex = indexPath.row
            
            let item = assistantItems[indexPath.row]
            CalendarBelongUserId = item.id
            CalendarBelongUserName = item.name
            
            self.userTitleView.update(item.name, item.avatar)
            
            self.requestModel.current_user_id = item.id
            let userId = self.UserModel?.id.int ?? 0
            if userId == item.id {
                UserDefaults.sk.set(value: [], for: "AssistantColorRemark")
            } else {
                
                if item.color_remark.isEmpty {
                    UserDefaults.sk.set(value: Array(repeating: "", count: 12), for: "AssistantColorRemark")
                } else {
                    UserDefaults.sk.set(value: item.color_remark, for: "AssistantColorRemark")
                }
                
            }
        }
       
        
        
        self.isBeginLoad = true
        self.refreshData()
   
        

    }
}


class CalendarNavBarUserView: UIView {
    let avatarImgView = UIImageView()
    let nameLabel = UILabel()
    let userModel = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(avatarImgView)
        addSubview(nameLabel)
        
        
        avatarImgView.cornerRadius = 12
        avatarImgView.contentMode = .scaleAspectFill
        
        
        nameLabel.textColor = R.color.textColor33()
        nameLabel.font = UIFont.sk.pingFangRegular(14)
       

        if let selectAssistant = UserDefaults.sk.get(of: UserInfoModel.self, for: "selectAssistant") {
            avatarImgView.kf.setImage(with: selectAssistant.avatar.url,placeholder: R.image.proile_user())
            nameLabel.text = selectAssistant.full_name
            nameLabel.width = selectAssistant.full_name.widthWithConstrainedWidth(height: 18, font: UIFont.sk.pingFangRegular(14)) + 10
            self.update(selectAssistant.full_name, selectAssistant.avatar)
        }else{
            avatarImgView.kf.setImage(with: userModel?.avatar_url,placeholder: R.image.proile_user())
            nameLabel.width = userModel?.full_name.widthWithConstrainedWidth(height: 18, font: UIFont.sk.pingFangRegular(14)) ?? 0 + 10
            nameLabel.text = userModel?.full_name
            self.update(userModel?.full_name ?? "", userModel?.avatar ?? "")
        }
       
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameLabel.height = 18
        nameLabel.center.y = self.center.y
        nameLabel.center.x = self.center.x
        
        avatarImgView.frame = CGRect(x: nameLabel.x - 30, y: 0, width: 24, height: 24)
        avatarImgView.center.y = self.center.y
       
    }
    
 
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ name:String,_ avatar:String) {
        avatarImgView.kf.setImage(with: avatar.url,placeholder: R.image.placeholder()!)
        nameLabel.text = name
        nameLabel.width = name.widthWithConstrainedWidth(height: 18, font: UIFont.sk.pingFangRegular(14)) + 10
        
        setNeedsLayout()
        layoutIfNeeded()
    }
}
