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
var CalendarBelongUserId:Int? = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)?.id
class CalendarController: BaseTableController {
    let currentDate = Date().string(withFormat: "yyyy-MM-dd")
    let headerView = CalendarHeaderView()
    let sectionView = CalendarSectionView.loadViewFromNib()
    let requestModel = EventListRequestModel()
    var friendList:[FriendListModel] = []
    var dataViewType: DataViewType = .UpComing
    var isSelectCalendar = false
    let userTitleView = CalendarNavBarUserView()
    var selectAssistant = AssistantInfo()
    var assistants: [AssistantInfo] = []
    let UserModel = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)
    var calendarChangeDate:Date?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestModel.start_date = currentDate
        requestModel.current_user_id = CalendarBelongUserId
        
        selectAssistant.id = UserModel?.id ?? 0
        selectAssistant.name = UserModel?.full_name ?? ""
        selectAssistant.avatar = UserModel?.avatar ?? ""
        
        let searchView = UIButton()
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
        let friendList = FriendService.friendList(id: CalendarBelongUserId)
        if isFirstLoad { showSkeleton() }
        Observable.zip(eventList,friendList).subscribe(onNext:{ events,friends in
            events.forEach({ event in
                if event.creator_id == self.UserModel?.id {
                    event.creator_name = self.UserModel?.full_name ?? ""
                    event.creator_avatar = self.UserModel?.avatar ?? ""
                } else if event.creator_id == CalendarBelongUserId {
                    event.creator_name = self.selectAssistant.name
                    event.creator_avatar = self.selectAssistant.avatar
                } else {
                    let friend = friends.first(where: { $0.id == event.creator_id })
                    event.creator_name = friend?.full_name ?? ""
                    event.creator_avatar = friend?.avatar ?? ""
                }
               
            })
            var datas = events
            
            if self.isSelectCalendar {
                // 删除开始时间不是当天的事件
                datas.removeAll(where: {
                    !($0.start_time.date(withFormat: "yyyy-MM-dd HH:mm:ss")?.isWithin(0, .day, of: self.requestModel.start_date?.date(withFormat: "yyyy-MM-dd") ?? Date()) ?? false)
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
            self.hideSkeleton()
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype)
            self.hideSkeleton()
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
        requsetModel.start_date = sd.string(withFormat: "yyyy-MM-dd")
        requsetModel.end_date = ed.string(withFormat: "yyyy-MM-dd")
        requsetModel.current_user_id = CalendarBelongUserId
        ScheduleService.eventList(model: requsetModel).subscribe(onNext:{ models in
            let eventDates = models.map({ ($0.start_time.date(withFormat: "yyyy-MM-dd HH:mm:ss") ??  Date()).string(withFormat: "yyyy-MM-dd") })
            self.headerView.calendarView.eventDates = eventDates
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
            self.requestModel.start_date = date.string(withFormat: "yyyy-MM-dd")
            self.requestModel.end_date = date.string(withFormat: "yyyy-MM-dd")
            self.loadNewData()
        }
        
        headerView.calendarView.addButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            let vc:CalendarAddEventController!
            if self.selectAssistant.id == self.UserModel?.id {
                vc = CalendarAddEventController(calendarBelongName: nil)
            } else {
                vc = CalendarAddEventController(calendarBelongName: self.selectAssistant.name)
            }
            
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
        model.calendar_belong_id = self.selectAssistant.id
        model.calendar_belong_name = self.selectAssistant.name
        let vc = EventDetailController(eventModel:model)
        let nav = BaseNavigationController(rootViewController: vc)
        vc.container.operateCompleteHandler = { [weak self] in
            guard let `self` = self else { return }
            self.loadNewData()
        }
        self.present(nav, animated: true)
    }
    
    deinit {
        CalendarBelongUserId = nil
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
            
            arrow.isHidden = assistants.count == 0
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
