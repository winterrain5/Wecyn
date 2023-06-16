//
//  CalendarSectionView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/15.
//

import UIKit

class CalendarSectionView: UIView {
    @IBOutlet weak var searchContainer: UIView!
    
    @IBOutlet weak var eventsLabel: UILabel!
    
    @IBOutlet weak var rangeLabel: UILabel!
    
    @IBOutlet weak var leftDateContainer: UIView!
    
    @IBOutlet weak var rightDateContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        searchContainer.addShadow(cornerRadius: 9)
        leftDateContainer.addShadow(cornerRadius: 7)
        rightDateContainer.addShadow(cornerRadius: 7)
        
        labelSelected(eventsLabel)
        
        eventsLabel.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
            self.labelSelected(self.eventsLabel)
            self.labelDeselected(self.rangeLabel)
        }).disposed(by: rx.disposeBag)
        
        rangeLabel.rx.tapGesture().when(.recognized).subscribe(onNext:{ [weak self] _ in
            guard let `self` = self else { return }
            self.labelSelected(self.rangeLabel)
            self.labelDeselected(self.eventsLabel)
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
