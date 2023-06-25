//
//  CalendarAddEventView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/19.
//

import UIKit
import AlertsAndPickers
class CalendarAddEventView: UIView {
    @IBOutlet weak var dateContainer: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleTf: UITextField!

    @IBOutlet weak var meetupTypeContainer: UIView!
    @IBOutlet weak var meetupLabel: UILabel!
    
    @IBOutlet weak var durationContainer: UIView!
    @IBOutlet weak var durationLabel: UILabel!
    
    
    @IBOutlet weak var timeContainer: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    @IBOutlet weak var recurringContainer: UIView!
    
    @IBOutlet weak var recurringLabel: UILabel!
    
    @IBOutlet weak var saveButton: LoadingButton!
    
    @IBOutlet weak var nameCardLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        subviews.forEach { v in
            if v is UILabel { return }
            v.addShadow(cornerRadius: 7)
        }
        
        dateContainer.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
            let alert = UIAlertController.init(style: .actionSheet, title: "Event Date")
            alert.addDatePicker(mode: .dateAndTime, date: Date(), minimumDate: Date(), maximumDate: nil) { date in
                self.dateLabel.text = date.string(withFormat: "dd/MM/yyyy")
            }
            alert.addAction(title: "Done", style: .cancel)
            alert.show()
        }).disposed(by: rx.disposeBag)
        
        meetupTypeContainer.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
            let alert = UIAlertController(style: .actionSheet, title: "Type of Meetup")
            
            let titles = ["In-Person Meeting\nSet an address or place", "Zoom\nWeb Conference", "Teams\nWeb Conference"]
            let pickerViewValues: [[String]] = [titles]
            let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: 0)

            alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
                self.meetupLabel.text = titles[index.row]
            }
            alert.addAction(title: "Done", style: .cancel)
            alert.show()
        }).disposed(by: rx.disposeBag)
        
        durationContainer.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
                guard let `self` = self else { return }
                let alert = UIAlertController(style: .actionSheet, title: "Type of Meetup")
                
                let durations = [5,10,15,20]
            let pickerViewValues: [[String]] = [durations.map({ $0.string })]
                let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: 0)

                alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
                    self.durationLabel.text = durations[index.row].string
                }
                alert.addAction(title: "Done", style: .cancel)
                alert.show()
        }).disposed(by: rx.disposeBag)
        
        timeContainer.rx.tapGesture().when(.recognized).subscribe(onNext:{ _ in
            
        }).disposed(by: rx.disposeBag)
        
        recurringContainer.rx.tapGesture().when(.recognized).subscribe(onNext:{ _ in
            
        }).disposed(by: rx.disposeBag)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    
}
