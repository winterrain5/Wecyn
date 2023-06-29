//
//  DatePickerView.swift
//  CCTIOS
//
//  Created by Derrick on 2022/3/11.
//

import UIKit
import EntryKit
class DatePickerView: UIView {

    typealias Action = (Date) -> Void
    
    var action: Action?
    
    var datePicker = UIDatePicker()
    var contentView = UIView()
    var confirmButton = UIButton()
    var titlelabel = UILabel()
    
    required init(title:String, mode: UIDatePicker.Mode, date: Date? = nil, minimumDate: Date? = nil, maximumDate: Date? = nil, action: Action?) {
        super.init(frame: .zero)
        datePicker.datePickerMode = mode
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.date = date ?? Date()
        datePicker.locale = Locale(identifier: "en")
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = maximumDate
        self.action = action
        
//        corner(byRoundingCorners: [.topLeft,.topRight], radii: 20)
        
        
        addSubview(confirmButton)
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.setTitleColor(.black, for: .normal)
        confirmButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        confirmButton.cornerRadius = 16
        confirmButton.backgroundColor = .white
        confirmButton.rx.tap.subscribe(onNext:{
            self.action?(self.datePicker.date)
            EntryKit.dismiss()
        }).disposed(by: rx.disposeBag)
        
        addSubview(contentView)
        contentView.cornerRadius = 20
        contentView.backgroundColor = .white
        
        contentView.addSubview(datePicker)
       
        contentView.addSubview(titlelabel)
        titlelabel.textAlignment = .center
        titlelabel.font = UIFont.systemFont(ofSize: 15)
        titlelabel.textColor = .darkGray
        titlelabel.text = title
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        confirmButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(kBottomsafeAreaMargin + 20)
            make.height.equalTo(60)
        }

        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.bottom.equalTo(confirmButton.snp.top).offset(-16)
            make.height.equalTo(294)
        }
        
        titlelabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(22)
        }
        
        datePicker.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(16)
            make.height.equalTo(240)
        }
    }
    
    func show() {
        let height = 380 + kBottomsafeAreaMargin
        EntryKit.display(view: self, size: CGSize(width: kScreenWidth, height: height), style: .sheet, touchDismiss: true)
    }
 
}
