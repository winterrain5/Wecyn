//
//  CalendarEventController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/20.
//

import UIKit


import UIKit
import RxSwift
import RxLocalizer
import PopMenu


enum DateFormat:String {
    case ddMMyyyyHHmm = "dd-MM-yyyy HH:mm"
    case yyyyMMddHHmmss = "yyyy-MM-dd HH:mm:ss UTC"
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
    let headerHeight = 197.cgFloat
    
    let monthLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CalendarBelongUserId = UserModel?.id ?? 0
        CalendarBelongUserName = UserModel?.full_name ?? ""
        
        requestModel.start_date = calendarChangeDate.string(format: DateFormat.ddMMyyyyHHmm.rawValue)
        requestModel.current_user_id = CalendarBelongUserId
        
        selectAssistant.id = UserModel?.id ?? 0
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
        monthLabel.text = calendarChangeDate.string(format: "MMM")
        self.navigation.item.leftBarButtonItem = UIBarButtonItem(customView: monthLabel)
        
        userTitleView.size = CGSize(width: kScreenWidth * 0.7, height: 40)
        userTitleView.selectAssistantHanlder = { [weak self] assistant in
            guard let `self` = self else { return }
            CalendarBelongUserId = assistant.id
            CalendarBelongUserName = assistant.name
            
            self.selectAssistant = assistant
            
            self.requestModel.current_user_id = assistant.id
            
            self.loadNewData()
        }
        self.navigation.item.titleView = userTitleView
        
        CalendarMenuView.addMenu(originView: self.view)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAssistants()
        loadNewData()
    }
    
    override func refreshData() {
        
        let eventList = ScheduleService.eventList(model: requestModel)
        Toast.showLoading()
        
        let sd = calendarChangeDate.startOfCurrentMonth()
        let ed = sd.endOfCurrentMonth()
        requestModel.start_date = sd.string(withFormat: DateFormat.ddMMyyyy.rawValue)
        requestModel.end_date = ed.string(withFormat: DateFormat.ddMMyyyy.rawValue)
        
        eventList.subscribe(onNext:{ events in
            
            var datas = events
      
            datas.forEach { data in
                if data.is_repeat == 1 {
                    data.isParentData = true
                    let copyed:[EventListModel] = data.rruleObject?.occurrences(rrulestr:data.rrule_str, between: sd, and: ed).map({
                        let model = data.copyed($0)
                        return model
                    }) ?? []
                    datas.append(contentsOf: copyed)
                }
            }
            datas.removeAll(where: { $0.isParentData })
            var dict:[String:[EventListModel]] = [:]
            datas.forEach { model in
                let key = model.start_time.date(withFormat: DateFormat.ddMMyyyyHHmm.rawValue)?.string(format: DateFormat.ddMMyyyy.rawValue) ?? ""
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
            self.headerView.eventDates = self.dataArray as! [[EventListModel]]
        
            self.endRefresh(.NoData, emptyString: "No Events")
            if self.isFirstLoad {
                self.scrollToSection(false)
            }
            
            self.hideSkeleton()
            Toast.dismiss()
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype)
            self.hideSkeleton()
            Toast.dismiss()
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
            self.calendarChangeDate = date
            self.scrollToSection()
        }
  
        headerView.monthChanged = { [weak self] date in
            guard let `self` = self else { return }
            self.calendarChangeDate = date
            self.monthLabel.text = date.string(format: "MMM")
            self.loadNewData()
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
                label.text = "Today " + dataDate.string(format: "dd MMM EEE")
                label.textColor = R.color.theamColor()
                view.backgroundColor = UIColor(hexString: "#d0ebe9")
                
            } else {
                label.text = dataDate.string(format: "dd MMM EEE")
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
 
        let model = (dataArray as! [[EventListModel]])[indexPath.section][indexPath.row]

        let vc = CalendarEventDetailController(eventModel:model)
        
        self.navigationController?.pushViewController(vc, animated: true)
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
        let originView = UIViewController.sk.getTopVC()?.view
        if originView?.subviews.contains(where: { $0 is  CalendarAssistantMenu }) ?? false {
            return
        }
        
        if assistants.count == 0 {
            return
        }
        self.arrow.rotate(toAngle: 180, ofType: .degrees, duration: 0.25)
        
       
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
