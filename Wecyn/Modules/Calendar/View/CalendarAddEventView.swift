//
//  CalendarAddEventView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/19.
//

import UIKit
import AlertsAndPickers
class CalendarAddEventView: UIView {
    @IBOutlet weak var titleTf: UITextField!
    
    @IBOutlet weak var attendeesTf: UITextField!
    @IBOutlet weak var endContainer: UIView!
    @IBOutlet weak var endTime: UILabel!
    
    @IBOutlet weak var startContainer: UIView!
    @IBOutlet weak var startTime: UILabel!
    
    
    @IBOutlet weak var descTf: UITextField!
    
    @IBOutlet weak var eventTypeSwitch: UISwitch!
    
    @IBOutlet weak var eventTypeLabel: UILabel!
    @IBOutlet weak var remarkTv: UITextView!
    
    @IBOutlet weak var addressOrUrlTf: UITextField!
    
    @IBOutlet weak var publicStateSegment: UISegmentedControl!
    @IBOutlet weak var saveButton: LoadingButton!
    
    @IBOutlet weak var attendeesOrLimitLabel: UILabel!
    
    @IBOutlet weak var attendeesClv: UICollectionView!
    @IBOutlet weak var attendeesClvHCons: NSLayoutConstraint!
    @IBOutlet weak var remarkTopCons: NSLayoutConstraint!
    @IBOutlet weak var atteneesContainer: UIView!
    @IBOutlet weak var addAttendanceLabel: UILabel!
    var requestModel = AddEventRequestModel()
    var attendees:[FriendListModel] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        
        attendeesClv.register(cellWithClass: CalendarHasAddedAttendanceCell.self)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        layout.scrollDirection = .horizontal
        attendeesClv.collectionViewLayout = layout
        
        attendeesClv.showsHorizontalScrollIndicator = false
        attendeesClv.delegate = self
        attendeesClv.dataSource = self
        
        subviews.forEach { v in
            if v is UILabel { return }
            if v is UISwitch { return }
            if v is UICollectionView { return }
            v.addShadow(cornerRadius: 7)
        }
        
        titleTf.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.requestModel.title = $0
        }).disposed(by: rx.disposeBag)
        
        startContainer.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
            let alert = UIAlertController.init(style: .actionSheet, title: "Start Time")
            let maxmumDate = (self.requestModel.end_time?.date(withFormat: "yyyy-MM-dd HH:mm:ss"))?.adding(.minute, value: -5)
            alert.addDatePicker(mode: .dateAndTime, date: Date(), minimumDate: Date(), maximumDate: maxmumDate) { date in
                
                self.startTime.text = date.string(withFormat: "dd/MM/yyyy HH:mm")
                let dateStr = date.string(withFormat: "yyyy-MM-dd HH:mm:ss")
                self.requestModel.start_time = dateStr
            }
            alert.addAction(title: "Done", style: .cancel)
            alert.show()
        }).disposed(by: rx.disposeBag)
        
        endContainer.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
            let alert = UIAlertController.init(style: .actionSheet, title: "End Time")
            let minimunDate = (self.requestModel.start_time?.date(withFormat: "yyyy-MM-dd HH:mm:ss") ?? Date()).adding(.minute, value: 5)
            alert.addDatePicker(mode: .dateAndTime, date: Date(), minimumDate: minimunDate, maximumDate: nil) { date in
                self.endTime.text = date.string(withFormat: "dd/MM/yyyy HH:mm")
                
                let dateStr = date.string(withFormat: "yyyy-MM-dd HH:mm:ss")
                self.requestModel.end_time = dateStr
            }
            alert.addAction(title: "Done", style: .cancel)
            alert.show()
        }).disposed(by: rx.disposeBag)
        
        descTf.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            self?.requestModel.desc = $0
        }).disposed(by: rx.disposeBag)
        
        eventTypeSwitch.rx.isOn.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            
            self.eventTypeLabel.text = $0 ? "Online Event" : "Offline Event"
            self.requestModel.is_online = $0.int
            self.addressOrUrlTf.placeholder = $0 ? "Link" : "Location"
            
        }).disposed(by: rx.disposeBag)
        
        publicStateSegment.rx.selectedSegmentIndex.subscribe(onNext:{ [weak self] idx in
            guard let `self` = self else { return }
            self.requestModel.is_public = idx
            self.attendeesTf.isHidden = idx == 0
            self.addAttendanceLabel.isHidden = idx != 0
            self.attendeesClv.isHidden = true
            self.remarkTopCons.constant = 16
            self.layoutIfNeeded()
            if idx == 0 {//  private
                self.attendeesOrLimitLabel.text = "Attendees"
                self.attendeesTf.keyboardType = .default
                self.requestModel.attendance_limit = nil
            } else {
                self.attendeesOrLimitLabel.text = "Attendance Limit"
                self.attendeesTf.placeholder = "Include the creator,must be a positive integer"
                self.attendeesTf.keyboardType = .numberPad
                self.requestModel.attendees = nil
                self.attendees.removeAll()
            }
            
        }).disposed(by: rx.disposeBag)
    
        
        atteneesContainer.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
            if self.requestModel.is_public == 1 { return }
            let vc = CalendarAddAttendanceController(selecteds: self.attendees)
            let nav = BaseNavigationController(rootViewController: vc)
            vc.selectUsers.subscribe(onNext:{ models in
                self.attendees = models
                // status，是否接受邀请。默认传0。0 未知，1 同意，2 拒绝
                var results:[Attendance] = []
                results = models.map({
                    let model = Attendance()
                    model.id = $0.id
                    model.status = 0
                    return model
                })
                self.requestModel.attendees = results
                self.layoutWithAnimation()
            }).disposed(by: self.rx.disposeBag)
            UIViewController.sk.getTopVC()?.present(nav, animated: true)
        }).disposed(by: rx.disposeBag)
        
        attendeesTf.rx.text.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            if self.requestModel.is_public == 1 {
                self.requestModel.attendance_limit = $0?.int ?? 1
            }
        }).disposed(by: rx.disposeBag)
        
        addressOrUrlTf.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            
            if self.requestModel.is_online == 0 {
                self.requestModel.location = $0
            } else {
                self.requestModel.url = $0
            }
            
        }).disposed(by: rx.disposeBag)
        
        
        
        remarkTv.rx.text.orEmpty.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.requestModel.remarks = $0
        }).disposed(by: rx.disposeBag)
        

        saveButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.saveButton.startAnimation()
            ScheduleService.addEvent(self.requestModel).subscribe(onNext:{
                if $0.success == 1 {
                    Toast.showMessage("Event Add Success", after: 1) {
                        UIViewController.sk.getTopVC()?.navigationController?.popViewController()
                    }
                } else {
                    Toast.showMessage($0.message)
                }
                self.saveButton.stopAnimation()
                
            },onError: { e in
                self.saveButton.stopAnimation()
                Toast.showMessage(e.asAPIError.errorInfo().message)
            }).disposed(by: self.rx.disposeBag)
        }).disposed(by: rx.disposeBag)
        
    }
    
    
    func layoutWithAnimation() {
        
        if attendees.count > 0 {
            self.attendeesClv.isHidden = false
            self.remarkTopCons.constant = 54
        } else {
            self.attendeesClv.isHidden = true
            self.remarkTopCons.constant = 16
        }
        self.layoutIfNeeded()
        attendeesClv.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
}

extension CalendarAddEventView: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.attendees.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: CalendarHasAddedAttendanceCell.self, for: indexPath)
        if self.attendees.count > 0 {
            cell.model = attendees[indexPath.row]
            cell.deleteItemHandler = { item in
                self.attendees.removeFirst(where: { $0.id == item.id })
                self.layoutWithAnimation()
            }
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.attendees.count > 0 {
            let model = attendees[indexPath.row]
            let width = String.fullName(first: model.fn, last: model.ln).widthWithConstrainedWidth(height: 24, font: UIFont.sk.pingFangRegular(12)) + 30
            return CGSize(width: width, height: 30)
        }
        return .zero
    }
}

class CalendarHasAddedAttendanceCell: UICollectionViewCell {
    var btn = UIButton()
    var model: FriendListModel =  FriendListModel() {
        didSet {
            btn.titleForNormal = String.fullName(first: model.fn, last: model.ln) + " "
        }
    }
    var deleteItemHandler:((FriendListModel)->())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(btn)
        contentView.backgroundColor = R.color.disableColor()
        btn.titleLabel?.font = UIFont.sk.pingFangRegular(12)
        btn.titleColorForNormal = R.color.textColor52()
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
