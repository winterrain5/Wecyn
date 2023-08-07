//
//  CalendarEventDetailController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/17.
//

import UIKit
import PopMenu
import SafariServices
enum CalendarEventDetailCellType {
    case Watch
    case Title
    case Creator
    case Location
    case Link
    case People
    case PeopleLimit
    case Description
    case Remark
    case Delete
}

class CalendarEventDetailModel {
    var cellType:CalendarEventDetailCellType
    var model:EventInfoModel
    var cellHeight:CGFloat {
        return model.recurrenceDescription.heightWithConstrainedWidth(width: kScreenWidth - 100, font: UIFont.sk.pingFangRegular(15)) + 58
    }
    var descHeight: CGFloat{
        var  descH:CGFloat = 0
        if cellType == .Description {
            descH = model.desc.filterHTML().heightWithConstrainedWidth(width: kScreenWidth - 100, font: UIFont.sk.pingFangRegular(15))
        }
        if cellType == .Remark {
            descH = model.remarks.filterHTML().heightWithConstrainedWidth(width: kScreenWidth - 100, font: UIFont.sk.pingFangRegular(15))
        }
       
        
        return descH >= 52 ? descH : 52
    }
    init(cellType: CalendarEventDetailCellType, model:EventInfoModel) {
        self.cellType = cellType
        self.model = model
    }
}

class CalendarEventDetailController: BaseTableController {
    
    var models:[[CalendarEventDetailModel]] = []
    var eventInfoModel:EventInfoModel?
    var eventModel:EventListModel
    init(eventModel:EventListModel) {
        self.eventModel = eventModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addLeftBarButtonItem()
        self.leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }
        self.navigation.item.title = "Event Detail"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    override func refreshData() {
        self.models.removeAll()
        Toast.showLoading()
        ScheduleService.eventInfo(eventModel.id).subscribe(onNext:{ model in
            Toast.dismiss()
            
            if self.eventModel.is_repeat == 1 {
                model.repeat_start_time = self.eventModel.start_time
            }
            model.isCrossDay = self.eventModel.isCrossDay
            model.isBySearch = self.eventModel.isBySearch
            model.creator_name = self.eventModel.creator_name
            self.eventInfoModel = model
           
            
            if CalendarBelongUserId !=  UserDefaults.userModel?.id.int {
                let watch = CalendarEventDetailModel(cellType: .Watch, model: model)
                self.models.append([watch])
            }
            
            let title = CalendarEventDetailModel(cellType: .Title, model: model)
            self.models.append([title])
            
            var section2:[CalendarEventDetailModel] = []
            let creator = CalendarEventDetailModel(cellType: .Creator, model: model)
            section2.append(creator)
            if !model.desc.isEmpty {
                let desc = CalendarEventDetailModel(cellType: .Description, model: model)
                section2.append(desc)
            }
            if !model.remarks.isEmpty, model.isCreator {
                let remark = CalendarEventDetailModel(cellType: .Remark, model: model)
                section2.append(remark)
            }
            self.models.append(section2)
            
            let loc = CalendarEventDetailModel(cellType: .Location, model: model)
            let link = CalendarEventDetailModel(cellType: .Link, model: model)
            
            var section3:[CalendarEventDetailModel] = []
            if model.is_online  == 1 {
                if !model.url.isEmpty { section3.append(link) }
            } else {
                if !model.location.isEmpty { section3.append(loc)  }
                
            }
            
            let peolple = CalendarEventDetailModel(cellType: .People, model: model)
            let peopleLimit = CalendarEventDetailModel(cellType: .PeopleLimit, model: model)
            
            if model.is_public == 1 {
                if model.attendance_limit > 0 {
                    section3.append(peopleLimit)
                }
                
            } else {
                if model.attendees.count > 0 {
                    section3.append(peolple)
                }
                
            }
            self.models.append(section3)
            
            
            self.models.removeAll(where: { $0.count == 0 })
            if CalendarBelongUserId == model.creator_id{
                self.addEditButton()
                let delete = CalendarEventDetailModel(cellType: .Delete, model: model)
                self.models.append([delete])
            } else {
                self.addStatusButton()
            }
            
            self.reloadData()
            
        },onError: { e in
            Toast.dismiss()
            self.endRefresh(e.asAPIError.emptyDatatype)
        }).disposed(by: rx.disposeBag)
    }
    
    func addEditButton() {
        let editButton = UIButton()
        editButton.imageForNormal = R.image.pencilLine()
        editButton.size = CGSize(width: 30, height: 30)
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: editButton)
        
        editButton.rx.tap.subscribe(onNext:{[weak self] in
            let vc = CalendarAddNewEventController(editEventModel: self?.eventInfoModel)
            self?.navigationController?.pushViewController(vc)
        }).disposed(by: rx.disposeBag)
    }
    
    func addStatusButton() {
        let editButton = UIButton()
        if eventModel.status == 0 {
            editButton.imageForNormal = R.image.personFillQuestionmark()
        }
        if eventModel.status == 1 {
            editButton.imageForNormal = R.image.personFillCheckmark()
        }
        if eventModel.status == 2 {
            editButton.imageForNormal = R.image.personFillXmark()
        }
        editButton.size = CGSize(width: 36, height: 36)
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: editButton)
        
        editButton.rx.tap.subscribe(onNext:{[weak self] in
            guard let `self` = self else { return }
           
            let appearance = PopMenuAppearance()
            appearance.popMenuBackgroundStyle = .dimmed(color: .black, opacity: 0.4)
            appearance.popMenuPresentationStyle = .near(.right,offset: CGPoint(x: 40, y: 60))
            appearance.popMenuActionHeight = 52
            
            let manager = PopMenuManager(appearance: appearance)
            manager.popMenuShouldDismissOnSelection = true
            let action1 = PopMenuDefaultAction(title: "Accept",image: R.image.personFillCheckmark(),didSelect: { _ in
                self.updateStatus(status: 1)
            })
            let action2 = PopMenuDefaultAction(title: "Unknown",image: R.image.personFillQuestionmark(),didSelect: { _ in
                self.updateStatus(status: 0)
            })
            let action3 = PopMenuDefaultAction(title: "Reject",image: R.image.personFillXmark(),didSelect: { _ in
                self.updateStatus(status: 2)
            })
            
            let actions = [action1,action2,action3]
            manager.actions = actions
            
            actions.forEach({
                $0.imageRenderingMode = .alwaysOriginal
                $0.iconWidthHeight = 22
            })
         
            manager.present(sourceView: editButton)
            
        }).disposed(by: rx.disposeBag)
    }
    
    func updateStatus(status:Int) {
        Toast.showLoading()
        ScheduleService.auditPrivateEvent(id: eventModel.id, status: status,currentUserId: CalendarBelongUserId).subscribe(onNext:{
            if $0.success == 1 {
                Toast.dismiss()
                self.eventModel.status = status
                self.addStatusButton()
            } else {
                Toast.showMessage($0.message)
            }
        },onError: { e in
            Toast.showMessage(e.asAPIError.errorInfo().message)
        }).disposed(by: self.rx.disposeBag)
    }
    
    
    override func createListView() {
        configTableview(.insetGrouped)
        
        
        tableView?.register(cellWithClass: CalendarEventDetailTitleCell.self)
        tableView?.register(cellWithClass: CalendarEventDetailDeleteCell.self)
        tableView?.register(cellWithClass: CalendarEventDetailInfoCell.self)
        
        
        tableView?.backgroundColor = R.color.backgroundColor()
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorStyle = .singleLine
        tableView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: kBottomsafeAreaMargin + 20, right: 0)
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = models[indexPath.section][indexPath.row]
        if model.cellType == .Title {
            return model.cellHeight
        }
        if model.cellType == .Description || model.cellType == .Remark {
            return model.descHeight
        }
        return 52
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section][indexPath.row]
        switch model.cellType {
        case .Title:
            let cell = tableView.dequeueReusableCell(withClass: CalendarEventDetailTitleCell.self)
            cell.model = model.model
            return cell
        case .Delete,.Watch:
            
            let cell = tableView.dequeueReusableCell(withClass: CalendarEventDetailDeleteCell.self)
            cell.model = model
            return cell
            
        case .Link,.Location,.Creator,.PeopleLimit,.People,.Description,.Remark:
            let cell = tableView.dequeueReusableCell(withClass: CalendarEventDetailInfoCell.self)
            cell.model = model
            return cell
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = models[indexPath.section][indexPath.row]
        if model.cellType == .Location {
            Haptico.selection()
            let vc = MapViewController(location: model.model.location)
            self.navigationController?.pushViewController(vc)
        }
        if model.cellType == .Link {
            Haptico.selection()
            if model.model.url.isValidHttpUrl || model.model.url.isValidHttpsUrl {
                if let url = URL(string: model.model.url) {
                    let vc = SFSafariViewController(url: url)
                    vc.delegate = self
                    self.present(vc, animated: true)
                }
            } else {
                if let url = URL(string: "http://" + model.model.url) {
                    let vc = SFSafariViewController(url: url)
                    self.present(vc, animated: true)
                }
            }
           
        }
        if model.cellType == .Delete  {
            Haptico.selection()
            if model.model.is_repeat == 1 {
                let message = CalendarBelongUserId == self.eventModel.creator_id ? nil : "Are you sure you want to delete \(self.eventModel.creator_name)'s event?"
                let alert = UIAlertController(title: "this is a recurrence event", message: message, preferredStyle: .actionSheet)
                alert.addAction(title: "delete only this event", style: .destructive) { _ in
                    let exdate = String(model.model.repeat_start_time?.split(separator: " ").first ?? "")
                    self.deleteEvent(type: 1,exdate: exdate)
                }
                alert.addAction(title: "delete this and all following events", style: .destructive) { _ in
                    self.deleteEvent(type: 2,exdate: String(model.model.repeat_start_time?.split(separator: " ").first ?? ""))
                }
                alert.addAction(title: "delete all events in the sequence", style: .destructive) { _ in
                    self.deleteEvent()
                }
                
                alert.addAction(title: "cancel", style: .cancel)
                alert.show()
                
            } else {
                let message = CalendarBelongUserId == self.eventModel.creator_id ? nil : "Are you sure you want to delete \(self.eventModel.creator_name)'s event?"
                let alert = UIAlertController(title:"Danger Operation",message: message, preferredStyle: .actionSheet)
                alert.addAction(title: "delete this event", style: .destructive) { _ in
                    self.deleteEvent()
                }
                
                alert.addAction(title: "cancel", style: .cancel)
                
                alert.show()
            }
        }
        
    }
    
    // 1: this event 2:此事件及后续 3:所有事件
    func deleteEvent(type:Int? = nil,exdate:String? = nil) {
        Toast.showLoading()
        
        ScheduleService.deleteEvent(self.eventModel.id,
                                    currentUserId: CalendarBelongUserId,
                                    type: type,
                                    exdate: exdate).subscribe(onNext:{

            if $0.success == 1 {
                Toast.showSuccess(withStatus: "Successful operation",after: 1, {
                    self.returnBack()
                })
            } else {
                Toast.showMessage($0.message)
            }

        },onError: { e in
            Toast.dismiss()
        }).disposed(by: self.rx.disposeBag)
    }
    
}

extension CalendarEventDetailController:SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true)
      }
}

class CalendarEventDetailTitleCell: UITableViewCell {
    var imgView = UIImageView()
    var titleLabel = UILabel()
    var detailLabel = UILabel()
    var model: EventInfoModel! {
        didSet  {
            
            let color = UIColor(hexString: EventColor.allColor[model.color]) ?? UIColor(hexString: EventColor.defaultColor)!
            imgView.image = R.image.circleFill()?.withTintColor(color)
            
            titleLabel.text = model.title
            
            detailLabel.text = model.recurrenceDescription
            
            
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(imgView)
        contentView.addSubview(detailLabel)
        
        titleLabel.textColor = R.color.textColor52()
        titleLabel.font = UIFont.sk.pingFangRegular(16)
        
        detailLabel.textColor = R.color.textColor74()
        detailLabel.font = UIFont.sk.pingFangRegular(15)
        detailLabel.textAlignment = .left
        detailLabel.numberOfLines = 0
        
        imgView.contentMode = .center
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imgView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.width.height.equalTo(20)
            make.top.equalToSuperview().offset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.right.equalToSuperview().inset(16)
            make.height.equalTo(18)
            make.centerY.equalTo(imgView.snp.centerY)
        }
        
        detailLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.left)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.greaterThanOrEqualToSuperview().inset(16)
        }
        
        
    }
}

class CalendarEventDetailDeleteCell: UITableViewCell {
    var label = UILabel()
    var model:CalendarEventDetailModel! {
        didSet {
            if model.cellType == .Watch {
                label.text = "You are viewing \(CalendarBelongUserName)’s calendar"
                label.textColor = R.color.theamColor()
            } else {
                label.textColor = .red
                label.text = "Delete Event"
            }
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(label)
       
        label.font = UIFont.sk.pingFangRegular(16)
        label.textAlignment = .center
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview().inset(8)
        }
    }
}

class CalendarEventDetailInfoCell: UITableViewCell {
    var imgView = UIImageView()
    var titleLabel = UILabel()
    var attendeesClv:UICollectionView!
    var model:CalendarEventDetailModel! {
        didSet{
            
            if model.cellType == .Link  {
                titleLabel.text = model.model.url
                imgView.image = R.image.link()
                accessoryType = .disclosureIndicator
                titleLabel.numberOfLines = 1
            }
            
            if model.cellType == .Location  {
                titleLabel.text = model.model.location
                imgView.image = R.image.location()
                accessoryType = .disclosureIndicator
                titleLabel.numberOfLines = 1
            }
            
            if model.cellType == .Creator  {
                titleLabel.text = model.model.creator_name
                imgView.image = R.image.personFill()
            }
            
            if model.cellType == .PeopleLimit  {
                titleLabel.text = model.model.attendance_limit.string
                imgView.image = R.image.person2()
            }
            
            if model.cellType == .People  {
                titleLabel.text = ""
                imgView.image = R.image.person2()
            }
            
            if model.cellType == .Description {
                titleLabel.text = model.model.desc.htmlToString
                imgView.image = R.image.textQuote()
                titleLabel.numberOfLines = 0
            }
            
            if model.cellType == .Remark {
                titleLabel.text = model.model.remarks.htmlToString
                imgView.image = R.image.line3Horizontal()
                titleLabel.numberOfLines = 0
            }
            
            if model.cellType == .People {
                attendeesClv.isHidden = false
            } else {
                attendeesClv.isHidden = true
            }
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(imgView)
        
        titleLabel.textColor = R.color.textColor52()
        titleLabel.font = UIFont.sk.pingFangRegular(16)
        titleLabel.isCopyingEnabled = true
        
        imgView.contentMode = .center
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        layout.scrollDirection = .horizontal
        
        attendeesClv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        attendeesClv.register(cellWithClass: EventDetaiAttendeesCell.self)
        attendeesClv.backgroundColor = .white
        contentView.addSubview(attendeesClv)
        attendeesClv.isHidden = true
        attendeesClv.showsHorizontalScrollIndicator = false
        attendeesClv.delegate = self
        attendeesClv.dataSource = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imgView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.width.height.equalTo(20)
            make.top.equalToSuperview().offset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.right.equalToSuperview().inset(16)
            make.top.equalTo(imgView.snp.top)
        }
        attendeesClv.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.bottom.equalToSuperview()
        }
        
    }
}
extension CalendarEventDetailInfoCell: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: EventDetaiAttendeesCell.self, for: indexPath)
        if self.model.model.attendees.count > 0 {
            cell.model = model.model.attendees[indexPath.row]
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.model.model.attendees.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.model.model.attendees.count > 0 {
            let model = model.model.attendees[indexPath.row]
            let width = model.name.widthWithConstrainedWidth(height: 2, font: UIFont.sk.pingFangRegular(12)) + 8
            return CGSize(width: width, height: 26)
        }
        return .zero
    }
}
class EventDetaiAttendeesCell: UICollectionViewCell {
    var label = UILabel()
    var model: Attendees =  Attendees() {
        didSet {
            switch model.status {
            case 0: // 未知
                label.text = "\(model.name)"
                contentView.backgroundColor = R.color.unknownColor()
            case 1: // 同意
                label.text = "\(model.name)"
                contentView.backgroundColor = R.color.agreeColor()
            case 2: // 拒绝
                label.text = "\(model.name)"
                contentView.backgroundColor = R.color.rejectColor()
            default:
                label.text = "\(model.name)"
            }
        }
    }
    var deleteItemHandler:((FriendListModel)->())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        
        label.font = UIFont.sk.pingFangRegular(12)
        label.textColor = .white
        label.textAlignment = .center
        contentView.layer.cornerRadius = 3
        contentView.layer.masksToBounds = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


