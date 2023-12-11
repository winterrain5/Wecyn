//
//  CalendarAddNewEventController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/11.
//
import WidgetKit
import UIKit
import IQKeyboardManagerSwift
import NotificationCenter
import EventKit
/*
 1st colour (primary): #13A5D6
 2nd colour: #136ED6
 3rd colour: #0943B2
 4th colour: #5451E1
 5th colour: #692BB7
 6th colour: #C33A7C
 7th colour: #EA6A6A
 8th colour: #2F9A94
 9th colour: #6FC23C
 10th colour:  #F2AF02
 11th colour: #C27502
 12th colour (gray): #888888
 */
struct EventColor {
    static var allColor:[String] {
        return ["13A5D6","136ED6","0943B2","5451E1","692BB7","C33A7C","EA6A6A","2F9A94","6FC23C","F2AF02","C27502","888888"]
    }
    static var defaultColor: String = "13A5D6"
}

enum AddEventType {
    case Title
    case People
    case Start
    case End
    case Description
    case Location
    case EmailCc
    case MeetingRoom
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
    var emails:[String] = []
    var attendees: [Attendees] = []
    
    var color = ""
    var duplicate = ""
    var alarm = ""
    var room = ""
    
    var start_time = ""
    var end_time: String?
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
    let Title = AddEventModel(img: R.image.circleFill()?.withTintColor(UIColor(hexString: EventColor.defaultColor)!), placeholder: "Title",type: .Title)
    
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
    
    let Location = AddEventModel(img: R.image.location(), placeholder: "Location", type: .Location)
    let Link = AddEventModel(img: R.image.link(), placeholder: "Link", type: .Link)
    let EmailCc = AddEventModel(img: R.image.mailStack(), placeholder: "Email Cc", type: .EmailCc)
    let MeetingRoom = AddEventModel(img: R.image.house(), placeholder: "Room", type: .MeetingRoom)
    
    let Color = AddEventModel(img: R.image.tagFill(), placeholder: "Color", type: .Color)
    
    
    var requestModel = AddEventRequestModel()
    var attendees:[FriendListModel] = []
    
    var rrule:RecurrenceRule?
    
    var editEventModel: EventInfoModel?
    var isEdit = false
    
    var alarmSelectIndex:Int = 1
    var selectRoom:MeetingRoom?
    var addedEmails:[String] = []
    
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
        updateColorPlaceholder()
        
        if self.isEdit {
            self.navigation.item.title = "Edit Event"
        } else {
            self.navigation.item.title = "New Event"
        }
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
        
        let urlLocationSection = [Link,Location,EmailCc,MeetingRoom]
        models.append(urlLocationSection)
        
        Alarm.alarm = "5 mins before"
        
        Color.color = EventColor.defaultColor
        
        let tagSection = [Alarm,Color]
        models.append(tagSection)
        
        
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
        
        addedEmails = event.emails
        selectRoom = event.roomModel
        
        requestModel.title = event.title
        requestModel.is_public = event.is_public
        requestModel.attendees = event.attendees
        requestModel.attendance_limit = event.attendance_limit
        requestModel.start_time = event.start_time
        requestModel.end_time = event.end_time
        requestModel.is_repeat = event.is_repeat
        requestModel.rrule_str = event.rrule_str
        requestModel.desc = event.desc
        requestModel.remarks = event.remarks
        requestModel.url = event.url
        requestModel.location = event.location
        requestModel.color = event.color
        requestModel.id = event.id
        requestModel.emails = event.emails
        requestModel.current_user_id = CalendarBelongUserId
        requestModel.room_id = event.room_id
        
        Title.title = event.title
        if event.color < EventColor.allColor.count   {
            if let color = UIColor(hexString: EventColor.allColor[event.color]), let titleImage = R.image.circleFill()?.withTintColor(color) {
                Title.img = titleImage
            }
        }
        IsPublic.is_public =  event.is_public
        People.attendees = event.attendees
        PeopleLimit.attendance_limit = event.attendance_limit
        if event.is_repeat == 1 {
            Start.start_time = event.repeat_start_time ?? ""
            End.end_time = event.repeat_end_time ?? ""
        } else {
            Start.start_time = event.start_time
            End.end_time = event.end_time
        }
       
        Duplicate.duplicate = event.recurrenceType
        Desc.desc = event.desc.htmlToString
        Remark.remarks = event.remarks
        Location.location = event.location
        Link.url = event.url
        EmailCc.emails = event.emails
        Color.color = EventColor.allColor[event.color]
        MeetingRoom.room = event.room_name
        
       
        isEdit = !event.isCreateByiCS
        rrule = event.rruleObject
        
      
    }
    
    func updateColorPlaceholder() {

        
        var colorRemark:[String] = []
        if let assistantColorRemark = UserDefaults.sk.value(for: "AssistantColorRemark") as?  [String],!assistantColorRemark.isEmpty{
            colorRemark = assistantColorRemark
        } else  {
            colorRemark = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)?.color_remark ?? []
        }
        
        if let event = self.editEventModel {
            let remark = colorRemark[event.color]
            self.Color.placeholder = remark.isEmpty ? "Color" : remark
        } else {
            self.Color.placeholder = colorRemark.first ?? "Color"
        }
        
        self.reloadData()
        
       
        
    }
    
    func addEvent() {
        func addEventRequest() {
            
            guard let startDate = self.requestModel.start_time?.toDate(format: DateFormat.ddMMyyyyHHmm.rawValue) else {
                Toast.showError("start time is required")
                return
            }
            
            if let _ = self.rrule {
                self.rrule?.startDate = startDate
                let rrulestr = self.rrule?.toString()
                self.requestModel.rrule_str = rrulestr
            }
            self.requestModel.current_user_id = CalendarBelongUserId
            Toast.showLoading()
            ScheduleService.addEvent(self.requestModel).subscribe(onNext:{
                Toast.dismiss()
                if $0.success == 1 {
                    self.addNotification {
                        Toast.showSuccess( "Event Add Success")
                        self.navigationController?.popViewController()
                    }
                   
                    WidgetCenter.shared.reloadAllTimelines()
                } else {
                    Toast.showMessage($0.message)
                }
                
            },onError: { e in
                Toast.showMessage(e.asAPIError.errorInfo().message)
            }).disposed(by: self.rx.disposeBag)
        }
        
        
        addEventRequest()
        
    }
    
    func addNotification(_ complete:@escaping ()->()) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { status, e in
            if !status {
                Toast.dismiss()
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                let alertViewController = UIAlertController(title: "", message: "Please allow Wecyn to send you notifications", preferredStyle: .alert)
                let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                })
                let actinSure = UIAlertAction(title: "Settting", style: .default, handler: { (action) in
                    UIApplication.shared.open(url)
                })
                alertViewController.addAction(actionCancel)
                alertViewController.addAction(actinSure)
                self.present(alertViewController, animated: true, completion: nil)
                
                return
            }
            
            let mins = AlarmData.map({ String($0.split(separator: " ").first ?? "") }).compactMap({ $0.int })
            var min:Int = 0
            if 0 < self.alarmSelectIndex &&  self.alarmSelectIndex < 3 {
                min = mins[self.alarmSelectIndex - 1] * 60
            } else
            if 3 < self.alarmSelectIndex && self.alarmSelectIndex < 6 {
                min = mins[self.alarmSelectIndex - 1] * 60 * 60
            }
            if self.alarmSelectIndex ==  6 {
                min = mins[self.alarmSelectIndex - 1] * 60 * 24 * 60
            }
            if self.rrule != nil {
                let dates = self.rrule?.allOccurrences()
                
                dates?.enumerated().forEach({ idx,date in
                    let content = UNMutableNotificationContent()
                    content.title = self.Title.title ?? ""
                    content.body = self.Desc.desc ?? ""
                    content.badge = 1
                    content.sound = .defaultCriticalSound(withAudioVolume: 0.6)
                    let alarmDate = date.addingTimeInterval(-min.double).addingTimeInterval(-8*60*60)
                    let dateComponents = DateComponents(year:alarmDate.year,month: alarmDate.month,day: alarmDate.day,hour: alarmDate.hour,minute: alarmDate.minute)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request) { err in
                        DispatchQueue.main.async {
                            if (idx == (dates?.count ?? 0) - 1) { complete() }
                        }
                        err != nil ? print("添加本地通知错误", err!.localizedDescription) : print("添加本地通知成功")
                    }
                })
            } else {
                guard let date = self.requestModel.start_time?.toDate(format: DateFormat.ddMMyyyyHHmm.rawValue, isZero: false) else { return }
                let content = UNMutableNotificationContent()
                content.title = self.Title.title ?? ""
                content.body = self.Desc.desc ?? ""
                content.badge = 1
                content.sound = .defaultCriticalSound(withAudioVolume: 0.6)
                let alarmDate = date.addingTimeInterval(-min.double)
                
                let dateComponents = DateComponents(year:alarmDate.year,month: alarmDate.month,day: alarmDate.day,hour: alarmDate.hour,minute: alarmDate.minute)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { err in
                    DispatchQueue.main.async {
                        complete()
                    }
                    
                    err != nil ? print("添加本地通知错误", err!.localizedDescription) : print("添加本地通知成功")
                }
            }
        }
    }
  
    
    
    func editEvent() {
        
        func editEventRequest(){
            Toast.showLoading()
            guard let startDate = self.requestModel.start_time?.date(withFormat: DateFormat.ddMMyyyyHHmm.rawValue) else {
                Toast.showError("start time is required")
                return
            }
            if let _ = self.rrule {
                //20230717T020531Z
                self.rrule?.startDate = startDate
                self.requestModel.rrule_str = self.rrule?.toString()
            }
            ScheduleService.updateEvent(self.requestModel).subscribe(onNext:{
                if $0.success == 1 {
                    self.addNotification {
                        Toast.showSuccess( "Event Update Success")
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                   
                } else {
                    Toast.showMessage($0.message)
                }
                
            },onError: { e in
                Toast.showMessage(e.asAPIError.errorInfo().message)
            }).disposed(by: self.rx.disposeBag)
        }
        guard let editEventModel = editEventModel else { return }
        
        if editEventModel.is_repeat == 1 {
            
            let alert = UIAlertController(title: "this is a recurrence event", message: nil, preferredStyle: .actionSheet)
            alert.addAction(title: "edit only this event", style: .destructive) { _ in
                
                self.requestModel.is_repeat = 0
                self.requestModel.exdate_str = String(editEventModel.repeat_start_time?.split(separator: " ").first ?? "")
                editEventRequest()
            }
            alert.addAction(title: "edit this and all following events", style: .destructive) { _ in
                self.requestModel.is_repeat = 1
                self.requestModel.exdate_str = String(editEventModel.repeat_start_time?.split(separator: " ").first ?? "")
                editEventRequest()
            }
            alert.addAction(title: "edit all events in the sequence", style: .destructive) { _ in
                editEventRequest()
            }
            
            alert.addAction(title: "cancel", style: .cancel)
            alert.show()
            
        } else {
            editEventRequest()
        }
       
        
        
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
        case .Title, .PeopleLimit, .Link:
            let cell = AddEventInputCell()
            cell.model = model
            cell.inputDidComplete = { [weak self] in
                self?.reloadData()
            }
            cell.inputDidChange = { [weak self] in
                guard let `self` = self else { return }
                
                if $0.type == .Title {
                    self.requestModel.title = $1
                    $0.title = $1
                }
                if $0.type == .PeopleLimit {
                    self.requestModel.attendance_limit = $1.int
                    $0.attendance_limit = $1.int
                }

                if $0.type == .Link {
                    self.requestModel.url = $1
                    $0.url = $1
                }
                
            }
            return cell
        case .IsPublic:
            let cell = AddEventSwitchCell()
            cell.model = model
            cell.switchChangeHandler = {  [weak self] in
                guard let `self` = self else { return }
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
            let cell = AddEventArrowCell()
            cell.model = model
            cell.removeAttandance = { item in
                
                self.attendees.removeAll(where: { $0.id == item.id })
                self.requestModel.attendees?.removeAll(where: { $0.id == item.id })
                self.People.attendees.removeAll(where: { $0.id == item.id })
                self.reloadData()
                
            }
            
            cell.removeEmail = { item in
                self.addedEmails.removeAll(where: { $0 == item })
                self.requestModel.emails?.removeAll(where: { $0 == item })
                self.EmailCc.emails.removeAll(where: { $0 == item })
                self.reloadData()
            }
            
            return cell
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        Haptico.selection()
        let model = models[indexPath.section][indexPath.row]
        
        if model.type == .People {
            let vc = CalendarAddAttendanceController(selecteds: self.attendees)
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
            self.navigationController?.pushViewController(vc)
        }
        
        if model.type == .Start {
            let date = self.isEdit ? (self.editEventModel?.is_repeat == 1 ? self.editEventModel?.repeat_start_date : self.editEventModel?.start_date) : Date().adding(.minute, value: 10)
            DatePickerView(title:"Start Time",
                           mode: .dateAndTime,
                           date: date,
                           minimumDate: nil,
                           maximumDate: nil) { date in
                
                let dateStr = date.toString(isZero: false)
                self.requestModel.start_time = dateStr
                
                self.Start.start_time = dateStr
                self.reloadData()
                
            }.show()
        }
        
        if model.type == .End {
            let date = self.isEdit ? (self.editEventModel?.is_repeat == 1 ? self.editEventModel?.repeat_end_Date : self.editEventModel?.end_date) : (self.requestModel.start_time?.date(withFormat: DateFormat.ddMMyyyyHHmm.rawValue)?.adding(.hour, value: 1))
            DatePickerView(title:"End Time",
                           mode: .dateAndTime,
                           date: date,
                           minimumDate: nil,
                           maximumDate: nil) { date in
                
                
                let dateStr = date.toString(isZero: false)
                self.requestModel.end_time = dateStr
                
                self.End.end_time = dateStr
                self.reloadData()
                
            }.show()
        }
        
        if model.type == .Description {
            let vc = EditorDemoController(withSampleHTML: self.requestModel.desc, wordPressMode: true)
            vc.editComplete = { [weak self] text,html in
                Logger.debug(html)
               
                self?.requestModel.desc = html
                self?.Desc.desc = text
                
                self?.reloadData()
            }
            self.navigationController?.pushViewController(vc)
            
        }
        
        if model.type == .Remark {
            let vc = EditorDemoController(withSampleHTML: self.requestModel.remarks, wordPressMode: false)
            vc.editComplete = { [weak self] text,html in
                Logger.debug(html)
               
                self?.requestModel.remarks = html
                self?.Remark.remarks = text
                
                self?.reloadData()
            }
            self.navigationController?.pushViewController(vc)
            
        }
        
        if model.type == .Color {
            let select = EventColor.allColor[self.requestModel.color ?? 0]
            let vc = ColorPickerController(selectColor: select) { color,remark in
                guard let color = color else { return }
                self.requestModel.color = EventColor.allColor.firstIndex(of: color)
                
                self.Color.color = color
                self.Color.placeholder = remark ?? "color"
                self.Title.img = R.image.circleFill()?.withTintColor(UIColor(hexString: color)!)
                self.reloadData()
                
            }
            if let sheet = vc.sheetPresentationController{
                sheet.detents = [.medium(), .large()]
            }
            present(vc, animated: true)

        }
        
        if model.type == .Alarm {
            let vc = CalendarEventSingelChooseController(type: .Alarm, selectIndexs: [self.alarmSelectIndex])
            if let sheet = vc.sheetPresentationController{
                sheet.detents = [.medium(), .large()]
            }
            self.present(vc, animated: true)
            vc.selectComplete = { [weak self] ids in
                guard let `self` = self else { return }
                self.alarmSelectIndex = ids.first ?? 1
                self.Alarm.alarm = AlarmData[self.alarmSelectIndex]
                self.reloadData()
            }
        }
        
        if model.type == .Repeat {
            let vc = CalendarEventRepeatController(rrule: self.rrule)
            vc.repeatSelectComplete = { [weak self] rrule in
                guard let `self` = self else { return }
              
                self.rrule = rrule
                guard let rrule = rrule else {
                    self.requestModel.is_repeat = 0
                    self.requestModel.rrule_str = nil
                    self.Duplicate.duplicate = "none"
                    self.reloadData()
                    return
                }
                self.requestModel.is_repeat = 1
                self.requestModel.rrule_str = rrule.toRRuleString()
                self.Duplicate.duplicate = "repeat " + rrule.frequency.toString().lowercased()
                self.reloadData()
            }
            self.navigationController?.pushViewController(vc)
        }
        
        if model.type == .Location {
            let vc = LocationSearchController()
            self.navigationController?.pushViewController(vc)
            
            vc.selectLocationComplete = { [weak self] location in
                self?.requestModel.location = location
                self?.Location.location = location
                self?.tableView?.reloadData()
            }
        }
        if model.type == .MeetingRoom {
            let vc = RoomPickerController(selectRoom: self.selectRoom, action: { room in
                guard let room = room else { return }
                self.selectRoom = room
                self.MeetingRoom.room = room.name
                self.requestModel.room_id = room.id
                self.reloadData()
            })
            
            if let sheet = vc.sheetPresentationController{
                sheet.detents = [.medium(), .large()]
            }
            self.present(vc, animated: true)
        }
        if model.type == .EmailCc {
            let vc = EmailCcAddController(emails: self.addedEmails)
            vc.selectComplete = { [weak self] in
                guard let `self` = self else { return }
                self.addedEmails = $0
                self.requestModel.emails = $0
                self.EmailCc.emails = $0
                self.reloadData()
            }
            self.navigationController?.pushViewController(vc)
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
            default:
                input.text = ""
            }
            
           
        }
    }
    var inputDidComplete:(()->())?
    var inputDidChange:((AddEventModel,String)->())?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(input)
        contentView.addSubview(tagImageView)
        
        input.borderStyle = .none
        input.textColor = R.color.textColor33()
        input.font = UIFont.sk.pingFangRegular(16)
        input.setPlaceHolderTextColor(R.color.textColor33()!)
        input.returnKeyType = .done
        input.enablesReturnKeyAutomatically = true
        input.delegate = self
        input.rx.controlEvent(.editingDidEnd).subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.inputDidComplete?()
        }).disposed(by: rx.disposeBag)
        input.rx.controlEvent(.editingChanged).subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.inputDidChange?(self.model,self.input.text ?? "")
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
                detailLabel.text = ""
                titleLabel.isHidden = model.attendees.count != 0
                attendeesClv.isHidden = model.attendees.count == 0
                attendeesClv.reloadData()
            } else if model.type == .EmailCc {
                detailLabel.text = ""
                titleLabel.isHidden = model.emails.count != 0
                attendeesClv.isHidden = model.emails.count == 0
                attendeesClv.reloadData()
            } else {
                titleLabel.isHidden = false
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
                detailLabel.text = model.alarm
            case .Description:
                detailLabel.text = model.desc
            case .Remark:
                detailLabel.text = model.remarks
            case .Location:
                detailLabel.text = model.location
            case .MeetingRoom:
                detailLabel.text = model.room
            default:
                detailLabel.text = ""
            }
        }
    }
    var removeAttandance:((Attendees)->())?
    var removeEmail:((String)->())?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(imgView)
        contentView.addSubview(detailLabel)
        
        titleLabel.textColor = R.color.textColor33()
        titleLabel.font = UIFont.sk.pingFangRegular(16)
        
        detailLabel.textColor = R.color.textColor77()
        detailLabel.font = UIFont.sk.pingFangRegular(16)
        detailLabel.lineBreakMode = .byTruncatingTail
        detailLabel.textAlignment = .right
        
        imgView.contentMode = .scaleAspectFit
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 4
        layout.scrollDirection = .horizontal
        
        attendeesClv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        attendeesClv.register(cellWithClass: CalendarHasAddedAttendanceCell.self)
        attendeesClv.backgroundColor = .clear
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
            make.centerY.equalToSuperview()
            make.height.equalTo(28)
        }
    }
}

extension AddEventArrowCell: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: CalendarHasAddedAttendanceCell.self, for: indexPath)
        if self.model.attendees.count > 0 {
            cell.model = model.attendees[indexPath.row]
            cell.deleteItemHandler = { [weak self] item in
                self?.removeAttandance?(item)
            }
        }
        
        if self.model.emails.count > 0 {
            cell.email = model.emails[indexPath.row]
            cell.deleteEmailHandler = {  [weak self] email in
                self?.removeEmail?(email)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.model.attendees.count > 0 ? self.model.attendees.count : self.model.emails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.model.attendees.count > 0 {
            let model = model.attendees[indexPath.row]
            let width = model.name.widthWithConstrainedWidth(height: 2, font: UIFont.sk.pingFangRegular(12)) + 30
            return CGSize(width: width, height: 22)
        }
        if self.model.emails.count > 0 {
            let email = model.emails[indexPath.row]
            let width = email.widthWithConstrainedWidth(height: 2, font: UIFont.sk.pingFangRegular(12)) + 30
            return CGSize(width: width, height: 22)
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
        }
    }
    var switchChangeHandler:((AddEventModel,Bool)->())?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(switchView)
        contentView.addSubview(imgView)
        contentView.addSubview(titleLabel)
        
        titleLabel.textColor = R.color.textColor33()
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
            if let color = UIColor(hexString: model.color) {
                imgView.image = model.img?.withTintColor(color)
                colorView.backgroundColor = color
            }
            accessoryType = .disclosureIndicator
        }
    }
    var detailModel: CalendarEventDetailModel! {
        didSet  {
            titleLabel.text = detailModel.model.color_remark
            if let color = UIColor(hexString: EventColor.allColor[detailModel.model.color]) {
                imgView.image = R.image.tagFill()?.tintImage(color)
                colorView.isHidden = true
            }
            accessoryType = .none
        }
    }
    var switchChangeHandler:((AddEventModel,Bool)->())?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(colorView)
        contentView.addSubview(imgView)
        contentView.addSubview(titleLabel)
        
        titleLabel.textColor = R.color.textColor77()
        titleLabel.font = UIFont.sk.pingFangRegular(16)
        
        imgView.contentMode = .scaleAspectFit
        
        colorView.cornerRadius = 6
        
        
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
    var model: Attendees? {
        didSet {
            guard let model = model else {
                return
            }
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
    var email: String = "" {
        didSet {
            btn.titleForNormal = email
            contentView.backgroundColor = R.color.theamColor()
        }
    }
    var deleteItemHandler:((Attendees)->())?
    var deleteEmailHandler:((String)->())?
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
            if let model = self.model {
                self.deleteItemHandler?(model)
            }
            if self.email.isEmpty == false {
                self.deleteEmailHandler?(self.email)
            }
            
        }).disposed(by: rx.disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        btn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class EventCalendar: NSObject {
    //单例
    static let eventStore = EKEventStore()
    
    ///用户是否授权使用日历
    func isEventStatus() -> Bool {
        let eventStatus = EKEventStore.authorizationStatus(for: EKEntityType.event)
        if eventStatus == .denied || eventStatus == .restricted {
            return false
        }
        return true
    }
}
