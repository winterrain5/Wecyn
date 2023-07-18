//
//  CalendarAddNewEventController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/11.
//

import UIKit
import IQKeyboardManagerSwift
import SwiftAlertView
/*
 #149bd0

 #1463d0

 #21a93c

 #ed8c00

 #d82739
 */
enum EventColor:String,CaseIterable {
    case DarkBlue = "149bd0"
    case LightBlue = "1463d0"
    case Green = "21a93c"
    case Yellow = "ed8c00"
    case Red = "d82739"
    static var allColor:[String] {
        return ["149bd0","1463d0","21a93c","ed8c00","d82739"]
    }
}

enum AddEventType {
    case Title
    case People
    case Start
    case End
    case Description
    case IsOnline
    case Location
    case Link
    case IsPublic
    case Remark
    case Color
    case Repeat
    case PeopleLimit
    case Alarm
}

class AddEventModel {
    var img: UIImage?
    var placeholder: String
    var type: AddEventType
    
    var location: String?
    var url: String?
    
    
    var attendees: [Attendees] = []
    
    var color = ""
    var duplicate = ""
    var remind = ""
    
    var start_time = ""
    var end_time: String?
    var is_online: Int = 0
    var is_public: Int = 0
    var current_user_id: Int?
    var remarks: String?
    var title: String?
    
    var attendance_limit: Int?
    var desc: String?
    // update event
    var id: Int?
    
    init(img: UIImage?, placeholder:String, type: AddEventType) {
        self.img = img
        self.placeholder = placeholder
        self.type = type
    }
}



class CalendarAddNewEventController: BaseTableController {
    
    var models:[[AddEventModel]] = []
    let Title = AddEventModel(img: R.image.circleFill()?.withTintColor(UIColor(hexString: EventColor.Red.rawValue)!), placeholder: "Title",type: .Title)
    
    let IsPublic = AddEventModel(img: R.image.switch2(), placeholder: "Private Event", type: .IsPublic)
    let People = AddEventModel(img: R.image.person2(), placeholder: "Attendees", type: .People)
    //
    let PeopleLimit = AddEventModel(img: R.image.person2(), placeholder: "Attendance Limit", type: .PeopleLimit)
    
    let Start = AddEventModel(img: R.image.clock(), placeholder: "Start Time", type: .Start)
    let End = AddEventModel(img: R.image.clockArrowCirclepath(), placeholder: "End Time", type: .End)
    let Duplicate = AddEventModel(img: R.image.repeat(), placeholder: "Repeat", type: .Repeat)
    let Alarm = AddEventModel(img: R.image.alarm(), placeholder: "Remind me", type: .Alarm)
    
    let Desc = AddEventModel(img: R.image.textQuote(), placeholder: "Description", type: .Description)
    let Remark = AddEventModel(img: R.image.line3Horizontal(), placeholder: "Remark", type: .Remark)
    
    let IsOnline = AddEventModel(img: R.image.switch2(), placeholder: "Offline", type: .IsOnline)
    let Location = AddEventModel(img: R.image.location(), placeholder: "Location", type: .Location)
    let Link = AddEventModel(img: R.image.link(), placeholder: "Link", type: .Link)
    
    
    let Color = AddEventModel(img: R.image.tag(), placeholder: "Color", type: .Color)
    
    
    var requestModel = AddEventRequestModel()
    var attendees:[FriendListModel] = []
    
    var rrule:RecurrenceRule?
    
    var editEventModel: EventInfoModel?
    var isEdit = false
    init(editEventModel: EventInfoModel? = nil) {
        self.editEventModel = editEventModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let saveButton = UIButton()
        saveButton.imageForNormal = R.image.checkmark()
        saveButton.size = CGSize(width: 30, height: 30)
        saveButton.contentMode = .right
        saveButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            if self.isEdit {
                self.editEvent()
            } else {
                self.addEvent()
            }
            
        }).disposed(by: rx.disposeBag)
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        
        self.addLeftBarButtonItem(image: R.image.xmark()!)
        self.leftButtonDidClick = { [weak self] in
            if self?.requestModel.title?.isEmpty == false {
                let alert = UIAlertController(title:nil ,message: nil, preferredStyle: .actionSheet)
                alert.addAction(title: "abandon event?", style: .destructive) { _ in
                    self?.returnBack()
                }
                
                alert.addAction(title: "cancel", style: .cancel)
                
                alert.show()
               
            } else {
                self?.returnBack()
            }
          
        }
        
        createAddEventModels()
        updateEditEventData()
        
        if self.isEdit {
            self.navigation.item.title = "New Event"
        } else {
            self.navigation.item.title = "Edit Event"
        }
    }
    func updateEditEventData() {
        guard let event = editEventModel else { return }

        
        attendees = event.attendees.map({
            let attance = FriendListModel()
            attance.id = $0.id
            attance.first_name = String($0.name.split(separator: " ").first ?? "")
            attance.last_name = String($0.name.split(separator: " ").last ?? "")
            attance.status = $0.status
            return attance
        })
        
        requestModel.title = event.title
        requestModel.is_public = event.is_public
        requestModel.attendees = event.attendees
        requestModel.attendance_limit = event.attendance_limit
        requestModel.start_time = event.start_time
        requestModel.end_time = event.end_time
        requestModel.is_repeat = event.is_repeat
        requestModel.rrule = event.rrule
        requestModel.desc = event.desc
        requestModel.remarks = event.remarks
        requestModel.is_online = event.is_online
        requestModel.url = event.url
        requestModel.location = event.location
        requestModel.color = event.color
        requestModel.id = event.id
        
        Title.title = event.title
        if event.color < EventColor.allColor.count   {
            if let color = UIColor(hexString: EventColor.allColor[event.color]), let titleImage = R.image.circleFill()?.withTintColor(color) {
                Title.img = titleImage
            }
        }
        IsPublic.is_public =  event.is_public
        People.attendees = event.attendees
        PeopleLimit.attendance_limit = event.attendance_limit
        Start.start_time = event.start_time
        End.end_time = event.end_time
        Duplicate.duplicate = event.recurrenceType
        Desc.desc = event.desc.htmlToString
        Remark.remarks = event.remarks
        IsOnline.is_online = event.is_online
        Location.location = event.location
        Link.url = event.url
        Color.color = EventColor.allColor[event.color]
        
        isEdit = true
        rrule = event.rruleObject

        reloadData()
    }
    
    func createAddEventModels() {
        let titleSection = [Title]
        models.append(titleSection)
        
        var peopelSection:[AddEventModel] = []
        if editEventModel ==  nil {
            peopelSection = [IsPublic,People]
        } else {
            if (editEventModel?.is_public ?? 0) == 1 {
                IsPublic.is_public = 1
                IsPublic.placeholder = "Public Event"
                peopelSection = [IsPublic,PeopleLimit]
            } else {
                IsPublic.is_public = 0
                IsPublic.placeholder = "Private Event"
                peopelSection = [IsPublic,People]
            }
        }
        models.append(peopelSection)
        
    
        Duplicate.duplicate = "none"
        let timeSection = [Start,End,Duplicate]
        models.append(timeSection)
        
        
        let descSection = [Desc,Remark]
        models.append(descSection)
        
        var isOnlineSection:[AddEventModel] = []
        if editEventModel ==  nil {
            isOnlineSection = [IsOnline,Location]
        } else {
            if (editEventModel?.is_online ?? 0) == 1 {
                IsOnline.is_online = 1
                IsOnline.placeholder = "Online"
                isOnlineSection = [IsOnline,Link]
            } else {
                IsOnline.is_online = 0
                IsOnline.placeholder = "Offline"
                isOnlineSection = [IsOnline,Location]
            }
        }
        models.append(isOnlineSection)
        
        Color.color = EventColor.Red.rawValue
        let tagSection = [Color]
        models.append(tagSection)
        
        if editEventModel == nil  {
            requestModel.color = EventColor.allColor.firstIndex(of: EventColor.Red.rawValue)
        }
        
    }
    
    func addEvent() {
        Toast.showLoading()
        if let _ = self.rrule {
            //20230717T020531Z
            self.rrule?.startDate = self.requestModel.start_time?.date(withFormat:  "yyyyMMdd'T'HHmmss'Z'") ?? Date()
            self.requestModel.rrule = self.rrule?.toString()
        }
        ScheduleService.addEvent(self.requestModel).subscribe(onNext:{
            
            if $0.success == 1 {
                Toast.showMessage("Event Add Success", after: 1) {
                    self.navigationController?.popViewController()
                }
            } else {
                Toast.showMessage($0.message)
            }
            
        },onError: { e in
            Toast.showMessage(e.asAPIError.errorInfo().message)
        }).disposed(by: self.rx.disposeBag)
    }
    
    func editEvent() {
        Toast.showLoading()
        if let _ = self.rrule {
            //20230717T020531Z
            self.rrule?.startDate = self.requestModel.start_time?.date(withFormat:  "yyyyMMdd'T'HHmmss'Z'") ?? Date()
            self.requestModel.rrule = self.rrule?.toRRuleString()
        }
        ScheduleService.updateEvent(self.requestModel).subscribe(onNext:{
            if $0.success == 1 {
                Toast.showMessage("Event Update Success", after: 1) {
                    self.navigationController?.popViewController()
                }
            } else {
                Toast.showMessage($0.message)
            }
            
        },onError: { e in
            Toast.showMessage(e.asAPIError.errorInfo().message)
        }).disposed(by: self.rx.disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = false
    }
    
    
    override func createListView() {
        configTableview(.insetGrouped)
        
        tableView?.backgroundColor = R.color.backgroundColor()
        
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorStyle = .singleLine
        
        tableView?.register(cellWithClass: AddEventInputCell.self)
        tableView?.register(cellWithClass: AddEventArrowCell.self)
        tableView?.register(cellWithClass: AddEventSwitchCell.self)
        tableView?.register(cellWithClass: AddEventColorCell.self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        48
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section][indexPath.row]
        
        switch model.type {
        case .Title, .PeopleLimit, .Location, .Link:
            let cell = AddEventInputCell()
            cell.model = model
            cell.inputDidComplete = { [weak self] in
                guard let `self` = self else { return }
                
                if $0.type == .Title {
                    self.requestModel.title = $1
                    $0.title = $1
                }
                if $0.type == .PeopleLimit {
                    self.requestModel.attendance_limit = $1.int
                    $0.attendance_limit = $1.int
                }
                if $0.type == .Location {
                    self.requestModel.location = $1
                    $0.location = $1
                }
                
                if $0.type == .Link {
                    self.requestModel.url = $1
                    $0.url = $1
                }
                self.reloadData()
            }
            return cell
        case .IsOnline,.IsPublic:
            let cell = AddEventSwitchCell()
            cell.model = model
            cell.switchChangeHandler = {  [weak self] in
                guard let `self` = self else { return }
                if $0.type == .IsOnline {
                    self.IsOnline.is_online = $1.int
                    self.IsOnline.placeholder = $1 ? "Online" : "Offline"
                    self.requestModel.is_online = $1.int
                    
                    if $1 {
                        self.models[4].remove(at: 1)
                        self.models[4].append(self.Link)
                    } else {
                        self.models[4].remove(at: 1)
                        self.models[4].append(self.Location)
                    }
                    
                    self.reloadData()
                }
                if $0.type == .IsPublic {
                    self.IsPublic.is_public = $1.int
                    self.IsPublic.placeholder = $1 ? "Public Event" : "Private Event"
                    self.requestModel.is_public = $1.int
                    
                    if $1 {
                        self.models[1].remove(at: 1)
                        self.models[1].append(self.PeopleLimit)
                    } else {
                        self.models[1].remove(at: 1)
                        self.models[1].append(self.People)
                    }
                    
                    self.reloadData()
                }
                
                
            }
            return cell
        case .Color:
            let cell = tableView.dequeueReusableCell(withClass: AddEventColorCell.self)
            cell.model = model
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withClass: AddEventArrowCell.self)
            cell.model = model
            cell.removeAttandance = { item in
                
                self.attendees.removeAll(where: { $0.id == item.id })
                self.requestModel.attendees?.removeAll(where: { $0.id == item.id })
                self.People.attendees.removeAll(where: { $0.id == item.id })
                self.reloadData()
                
            }
            
            return cell
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = models[indexPath.section][indexPath.row]
        
        if model.type == .People {
            let vc = CalendarAddAttendanceController(selecteds: self.attendees)
            let nav = BaseNavigationController(rootViewController: vc)
            vc.selectUsers.subscribe(onNext:{ models in
                self.attendees = models
                // status，是否接受邀请。默认传0。0 未知，1 同意，2 拒绝
                var results:[Attendees] = []
                results = models.map({
                    let model = Attendees()
                    model.id = $0.id
                    model.status = 0
                    model.name = $0.full_name
                    return model
                })
                self.requestModel.attendees = results
                self.People.attendees = results
                self.reloadData()
            }).disposed(by: self.rx.disposeBag)
            UIViewController.sk.getTopVC()?.present(nav, animated: true)
        }
        
        if model.type == .Start {
            let maxmumDate = (self.requestModel.end_time?.date(withFormat: DateFormat.ddMMyyyyHHmm.rawValue))?.adding(.minute, value: -5)
            DatePickerView(title:"Start Time",
                           mode: .dateAndTime,
                           date: Date(),
                           minimumDate: Date(),
                           maximumDate: maxmumDate) { date in
                
                let dateStr = date.string(format: DateFormat.ddMMyyyyHHmm.rawValue)
                self.requestModel.start_time = dateStr
                
                self.models[2][0].start_time = dateStr
                self.reloadData()
                
            }.show()
        }
        
        if model.type == .End {
            let minimunDate = (self.requestModel.start_time?.date(withFormat: DateFormat.ddMMyyyyHHmm.rawValue) ?? Date()).adding(.minute, value: 5)
            DatePickerView(title:"End Time",
                           mode: .dateAndTime,
                           date: Date(),
                           minimumDate: minimunDate,
                           maximumDate: nil) { date in
                
                
                let dateStr = date.string(format: DateFormat.ddMMyyyyHHmm.rawValue)
                self.requestModel.end_time = dateStr
                
                self.models[2][1].end_time = dateStr
                self.reloadData()
                
            }.show()
        }
        
        if model.type == .Description || model.type == .Remark {
            let vc = EditorDemoController(withSampleHTML: self.requestModel.desc, wordPressMode: false)
            vc.editComplete = { [weak self] text,html in
                Logger.debug(html)
               
                if model.type == .Description {
                    self?.requestModel.desc = html
                    self?.models[3][0].desc = text
                } else {
                    self?.requestModel.remarks = html
                    self?.models[3][1].remarks = text
                }
                
                self?.reloadData()
            }
            self.navigationController?.pushViewController(vc)
            
        }
        
        if model.type == .Color {
            let select = EventColor.allColor[self.requestModel.color ?? 0]
            ColorPickerView(selectColor: select) { [weak self] color in
                guard let color = color else { return }
                self?.requestModel.color = EventColor.allColor.firstIndex(of: color)
                
                self?.models.last?.first?.color = color
                self?.models.first?.first?.img = R.image.circleFill()?.withTintColor(UIColor(hexString: color)!)
                self?.reloadData()
                
            }.show()
        }
        
        if model.type == .Repeat {
            let vc = CalendarEventRepeatController(rrule: self.rrule)
            vc.repeatSelectComplete = { [weak self] rrule in
                guard let `self` = self else { return }
                
                self.rrule = rrule
                guard let rrule = rrule else {
                    self.requestModel.is_repeat = 0
                    self.requestModel.rrule = nil
                    return
                }
                self.requestModel.is_repeat = 1
                self.requestModel.rrule = rrule.toRRuleString()
                self.models[2][2].duplicate = "repeat " + rrule.frequency.toString().lowercased()
                self.reloadData()
            }
            let nav = BaseNavigationController(rootViewController: vc)
            self.present(nav, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 1, models[1][0].is_public == 1{
            let sectionView = CalendarEventSectionView()
            sectionView.label.text = "Include the creator,must be a positive integer"
            return sectionView
        }
        
        if section == 2, self.rrule != nil {
            let sectionView = CalendarEventSectionView()
            sectionView.label.text = self.rrule?.toText()
            return sectionView
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1, models[1][0].is_public == 1 {
            return 40
        }
        if section == 2, self.rrule != nil {
            return 40
        }
        return 20
    }
    
}

class AddEventInputCell: UITableViewCell,UITextFieldDelegate {
    var input = UITextField()
    var tagImageView = UIImageView()
    var model: AddEventModel! {
        didSet  {
            input.placeholder = model.placeholder
            input.text = model.title
            tagImageView.image = model.img
            
            switch model.type {
            case .Title:
                tagImageView.contentMode = .center
                input.text = model.title
                input.keyboardType = .default
            case .PeopleLimit:
                tagImageView.contentMode = .scaleAspectFit
                input.text = model.attendance_limit?.string
                input.keyboardType = .numberPad
            case .Link:
                tagImageView.contentMode = .scaleAspectFit
                input.text = model.url
                input.keyboardType = .URL
            case .Location:
                tagImageView.contentMode = .scaleAspectFit
                input.text = model.location
                input.keyboardType = .default
            default:
                input.text = ""
            }
            
           
        }
    }
    var inputDidComplete:((AddEventModel,String)->())?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(input)
        contentView.addSubview(tagImageView)
        
        input.borderStyle = .none
        input.textColor = R.color.textColor52()
        input.font = UIFont.sk.pingFangRegular(16)
        input.setPlaceHolderTextColor(R.color.textColor52()!)
        input.returnKeyType = .done
        input.enablesReturnKeyAutomatically = true
        input.delegate = self
        input.rx.controlEvent(.editingDidEnd).subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.inputDidComplete?(self.model,self.input.text ?? "")
        }).disposed(by: rx.disposeBag)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tagImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        input.snp.makeConstraints { make in
            make.left.equalTo(tagImageView.snp.right).offset(16)
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().inset(16)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return true
    }
    
}

class AddEventArrowCell: UITableViewCell {
    var imgView = UIImageView()
    var titleLabel = UILabel()
    var detailLabel = UILabel()
    var attendeesClv:UICollectionView!
    var model: AddEventModel! {
        didSet  {
            
            imgView.image = model.img
            
            if model.type == .People  {
                attendeesClv.isHidden = model.attendees.count == 0
                attendeesClv.reloadData()
            } else {
                attendeesClv.isHidden = true
            }
            
            titleLabel.text = model.placeholder
            
            switch model.type {
            case .Start:
                detailLabel.text = model.start_time
            case .End:
                detailLabel.text = model.end_time
            case .Repeat:
                detailLabel.text = model.duplicate
            case .Alarm:
                detailLabel.text = model.remind
            case .Description:
                detailLabel.text = model.desc
            case .Remark:
                detailLabel.text = model.remarks
            default:
                detailLabel.text = ""
            }
        }
    }
    var removeAttandance:((Attendees)->())?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(imgView)
        contentView.addSubview(detailLabel)
        
        titleLabel.textColor = R.color.textColor52()
        titleLabel.font = UIFont.sk.pingFangRegular(16)
        
        detailLabel.textColor = R.color.textColor74()
        detailLabel.font = UIFont.sk.pingFangRegular(16)
        detailLabel.lineBreakMode = .byTruncatingTail
        detailLabel.textAlignment = .right
        
        imgView.contentMode = .scaleAspectFit
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        layout.scrollDirection = .horizontal
        
        attendeesClv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        attendeesClv.register(cellWithClass: CalendarHasAddedAttendanceCell.self)
        attendeesClv.backgroundColor = .white
        contentView.addSubview(attendeesClv)
        attendeesClv.isHidden = true
        attendeesClv.showsHorizontalScrollIndicator = false
        attendeesClv.delegate = self
        attendeesClv.dataSource = self
        
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imgView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(88)
        }
        
        detailLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(6)
            make.right.equalToSuperview().offset(-6)
            make.top.bottom.equalToSuperview()
        }
        
        attendeesClv.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.bottom.equalToSuperview()
        }
    }
}

extension AddEventArrowCell: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: CalendarHasAddedAttendanceCell.self, for: indexPath)
        if self.model.attendees.count > 0 {
            cell.model = model.attendees[indexPath.row]
            cell.deleteItemHandler = { item in
                self.removeAttandance?(item)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.model.attendees.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.model.attendees.count > 0 {
            let model = model.attendees[indexPath.row]
            let width = model.name.widthWithConstrainedWidth(height: 2, font: UIFont.sk.pingFangRegular(12)) + 30
            return CGSize(width: width, height: 24)
        }
        return .zero
    }
}



class AddEventSwitchCell: UITableViewCell {
    var switchView = UISwitch()
    var imgView = UIImageView()
    var titleLabel = UILabel()
    var model: AddEventModel! {
        didSet  {
            titleLabel.text = model.placeholder
            imgView.image = model.img
            
            if model.type == .IsPublic {
                switchView.isOn = model.is_public == 1
            }
            if model.type == .IsOnline {
                switchView.isOn = model.is_online == 1
            }
        }
    }
    var switchChangeHandler:((AddEventModel,Bool)->())?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(switchView)
        contentView.addSubview(imgView)
        contentView.addSubview(titleLabel)
        
        titleLabel.textColor = R.color.textColor74()
        titleLabel.font = UIFont.sk.pingFangRegular(16)
        
        imgView.contentMode = .scaleAspectFit
        
        switchView.onTintColor = R.color.theamColor()
        switchView.rx.controlEvent(.valueChanged).subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.switchChangeHandler?(self.model,self.switchView.isOn)
        }).disposed(by: rx.disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imgView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        switchView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.top.bottom.equalToSuperview()
        }
    }
}

class AddEventColorCell: UITableViewCell {
    var colorView = UIView()
    var imgView = UIImageView()
    var titleLabel = UILabel()
    var model: AddEventModel! {
        didSet  {
            titleLabel.text = model.placeholder
            imgView.image = model.img
            colorView.backgroundColor = UIColor(hexString: model.color)
        }
    }
    var switchChangeHandler:((AddEventModel,Bool)->())?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(colorView)
        contentView.addSubview(imgView)
        contentView.addSubview(titleLabel)
        
        titleLabel.textColor = R.color.textColor74()
        titleLabel.font = UIFont.sk.pingFangRegular(16)
        
        imgView.contentMode = .scaleAspectFit
        
        colorView.cornerRadius = 6
        
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imgView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(16)
            make.top.bottom.equalToSuperview()
        }
        
        colorView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        
       
    }
}


class CalendarHasAddedAttendanceCell: UICollectionViewCell {
    var btn = UIButton()
    var model: Attendees =  Attendees() {
        didSet {
            btn.titleForNormal = model.name
            
            switch model.status {
            case 0: // 未知
                contentView.backgroundColor = R.color.unknownColor()
            case 1: // 同意
                contentView.backgroundColor = R.color.agreeColor()
            case 2: // 拒绝
                contentView.backgroundColor = R.color.rejectColor()
            default:
                contentView.backgroundColor = R.color.unknownColor()
            }
            
        }
    }
    var deleteItemHandler:((Attendees)->())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(btn)
        
        btn.titleLabel?.font = UIFont.sk.pingFangRegular(12)
        btn.titleColorForNormal = .white
        btn.imageForNormal = R.image.attendace_delete()
        btn.sk.setImageTitleLayout(.imgRight)
        contentView.layer.cornerRadius = 3
        contentView.layer.masksToBounds = true
        
        btn.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.deleteItemHandler?(self.model)
            
        }).disposed(by: rx.disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        btn.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
