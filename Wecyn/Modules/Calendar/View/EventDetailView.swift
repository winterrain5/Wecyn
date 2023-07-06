//
//  EventDetailView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/27.
//

import UIKit
import SafariServices
import DKLogger
import SwiftAlertView
class EventDetailView: UIView {
    
    @IBOutlet weak var calendarBelongLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var attendeesHeadLabel: UILabel!
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var createUserLabel: UILabel!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var locOrUrlLabel: UILabel!
    @IBOutlet weak var locOrUrlImgView: UIImageView!
    @IBOutlet weak var clv: UICollectionView!
    var eventModel:EventListModel!
    var operateCompleteHandler:(()->())!
    var model:EventInfoModel? {
        didSet {
            
            self.hideSkeleton()
            guard let model = model else { return }
            
            calendarBelongLabel.text = "you are viewing \(eventModel.calendar_belong_name)'s calendar"
            
            titleLabel.text = model.title
            let start = model.start_time.date(withFormat: "yyyy-MM-dd HH:mm:ss")?.string(withFormat: "dd/MM/yyyy HH:mm") ?? ""
            let end = model.end_time.date(withFormat: "yyyy-MM-dd HH:mm:ss")?.string(withFormat: "dd/MM/yyyy HH:mm") ?? ""
            dateLabel.text = start + " - " + end
            
            if model.is_online == 1{
                locOrUrlImgView.image = R.image.event_link()
                locOrUrlLabel.text = model.url
                locOrUrlLabel.textColor = .blue
            } else {
                locOrUrlImgView.image = R.image.event_location()
                locOrUrlLabel.text = model.location
            }
            
            ///
            if model.creator_id == CalendarBelongUserId {
                segment.isHidden = true
            } else {
                segment.selectedSegmentIndex = eventModel.status
                editButton.isHidden = true
                deleteButton.isHidden = true
            }
            
            createUserLabel.text = "create by: \(eventModel.creator_name)"
            
            attendeesHeadLabel.isHidden = model.is_public == 1
            descLabel.text = model.desc.isEmpty ? "Description" : "Description \n\n \(model.desc)"
            remarkLabel.text = model.remarks.isEmpty ? "Remark" : "Remark \n\n \(model.remarks)"
            
            clv.reloadData()
            
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSkeletonable = true
        self.showSkeleton()
        
        locOrUrlLabel.isCopyingEnabled = true
        locOrUrlLabel.isUserInteractionEnabled = true
        
        clv.delegate = self
        clv.dataSource = self
        clv.register(cellWithClass: EventDetaiAttendeesCell.self)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        layout.scrollDirection = .vertical
        clv.collectionViewLayout = layout
        
        clv.showsVerticalScrollIndicator = false
        
        closeBtn.rx.tap.subscribe(onNext:{
            UIViewController.sk.getTopVC()?.dismiss(animated: true)
        }).disposed(by: rx.disposeBag)
        
        segment.selectedSegmentTintColor = .white
        segment.addTarget(self, action: #selector(segmentDidSelected), for: .valueChanged)
        
        editButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            UIViewController.sk.getTopVC()?.dismiss(animated: true,completion: {
                self.model?.calendar_belong_name = self.eventModel.calendar_belong_name
                self.model?.calendar_belong_id = self.eventModel.calendar_belong_id
                let vc = CalendarAddEventController(editEventMode: self.model)
                UIViewController.sk.getTopVC()?.navigationController?.pushViewController(vc)
                
            })
        }).disposed(by: rx.disposeBag)
        
      
        deleteButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            SwiftAlertView.show(title:"Danger Operation",message: "Are you sure you want to delete \(self.eventModel.calendar_belong_name)'s calendar?", buttonTitles: ["Cancel","Confirm"]).onActionButtonClicked { alertView, buttonIndex in
                if buttonIndex == 1 {
                    ScheduleService.deleteEvent(self.model?.id ?? 0,currentUserId: CalendarBelongUserId).subscribe(onNext:{

                        if $0.success == 1 {
                            Toast.showMessage("Successful operation")
                        } else {
                            Toast.showMessage($0.message)
                        }
                        UIViewController.sk.getTopVC()?.dismiss(animated: true,completion: {
                            self.operateCompleteHandler?()
                        })

                    }).disposed(by: self.rx.disposeBag)
                }
            }
            
            
        }).disposed(by: rx.disposeBag)
    }
    
    @objc func segmentDidSelected(_ seg:UISegmentedControl) {
        Toast.showLoading()
        ScheduleService.auditPrivateEvent(id: eventModel.id, status: seg.selectedSegmentIndex,currentUserId: CalendarBelongUserId).subscribe(onNext:{
            if $0.success == 1 {
                Toast.showSuccess(withStatus: "Successful operation",after: 2, {
                    UIViewController.sk.getTopVC()?.dismiss(animated: true)
                })
            } else {
                Toast.showMessage($0.message)
            }
            self.operateCompleteHandler()
        },onError: { e in
            Toast.showMessage(e.asAPIError.errorInfo().message)
        }).disposed(by: self.rx.disposeBag)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
}
extension EventDetailView: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.model?.attendees.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: EventDetaiAttendeesCell.self, for: indexPath)
        if self.model?.attendees.count ?? 0 > 0 {
            cell.model = model!.attendees[indexPath.row]
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.model?.attendees.count ?? 0 > 0 {
            let item = model?.attendees[indexPath.row]
            let width = (item?.name.widthWithConstrainedWidth(height: 24, font: UIFont.sk.pingFangRegular(12)) ?? 0) + 8
            return CGSize(width: width, height: 30)
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
                contentView.backgroundColor = UIColor(hexString: "#ed8c00")
            case 1: // 同意
                label.text = "\(model.name)"
                contentView.backgroundColor = UIColor(hexString: "#21a93c")
            case 2: // 拒绝
                label.text = "\(model.name)"
                contentView.backgroundColor = UIColor(hexString: "#d82739")
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


