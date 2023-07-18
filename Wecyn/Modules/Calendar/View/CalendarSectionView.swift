//
//  CalendarSectionView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/15.
//

import UIKit

class CalendarSectionView: UIView {
    @IBOutlet weak var eventsLabel: UILabel!
    
    @IBOutlet weak var rangeLabel: UILabel!
    
    @IBOutlet weak var leftDateContainer: UIView!
    
    @IBOutlet weak var rightDateContainer: UIView!
    
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    var startTime:String?
    var endTime:String?
    var dateRangeFilter:((_ start:String?,_ end:String?)->())?
    var dataViewTypeChanged:((DataViewType)->())?
    override func awakeFromNib() {
        super.awakeFromNib()
        leftDateContainer.addShadow(cornerRadius: 7)
        rightDateContainer.addShadow(cornerRadius: 7)
        
        leftDateContainer.isHidden = true
        rightDateContainer.isHidden = true
        
        labelSelected(eventsLabel)
        
        eventsLabel.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
            self.labelSelected(self.eventsLabel)
            self.labelDeselected(self.rangeLabel)
            
            self.leftDateContainer.isHidden = true
            self.rightDateContainer.isHidden = true
            
            self.dataViewTypeChanged?(.UpComing)
        }).disposed(by: rx.disposeBag)
        
        rangeLabel.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
            self.labelSelected(self.rangeLabel)
            self.labelDeselected(self.eventsLabel)
            
            self.leftDateContainer.isHidden = false
            self.rightDateContainer.isHidden = false
            
            self.dataViewTypeChanged?(.Timeline)
        }).disposed(by: rx.disposeBag)
        
        leftDateContainer.rx.tapGesture().when(.recognized).subscribe(onNext:{ _ in
           
            DatePickerView(title:"Start Time", mode: .date, date: Date()) { date in
                self.startTimeLabel.text = date.string(withFormat: "dd/MM/yyyy")
                self.startTime = date.string(withFormat: DateFormat.ddMMyyyy.rawValue)
                self.dateRangeFilter?(self.startTime,self.endTime)
            }.show()
            
        }).disposed(by: rx.disposeBag)
        
        rightDateContainer.rx.tapGesture().when(.recognized).subscribe(onNext:{ _ in
            
            DatePickerView(title:"End Time", mode: .date, date: Date()) { date in
                self.endTimeLabel.text = date.string(withFormat: "dd/MM/yyyy")
                self.endTime = date.string(withFormat: DateFormat.ddMMyyyy.rawValue)
                self.dateRangeFilter?(self.startTime,self.endTime)
            }.show()
            
        }).disposed(by: rx.disposeBag)
        
    }
    
    func labelSelected(_ label:UILabel) {
        label.textColor = R.color.theamColor()!
        label.sk.setSpecificTextUnderLine(label.text ?? "", color: R.color.theamColor()!)
    }
    func labelDeselected(_ label:UILabel) {
        label.textColor = R.color.textColor52()!
        label.sk.setSpecificTextUnderLine(label.text ?? "", color: .clear)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        sk.addCorner(conrners: [.topLeft,.topRight], radius: 22)
    }
}
