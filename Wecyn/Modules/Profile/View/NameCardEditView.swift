//
//  NameCardEditView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/12.
//

import UIKit

class NameCardEditView: UIView {

    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var companyTf: UITextField!
 
    @IBOutlet weak var emailTf: UITextField!
    
    
    @IBOutlet weak var mobileNoTf: UITextField!
    
    
    @IBOutlet weak var officeNoTf: UITextField!
    
    @IBOutlet weak var locationTf: UITextField!
    
    @IBOutlet weak var levelTf: UITextField!
    
    @IBOutlet weak var websiteTf: UITextField!
    
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var closeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        subviews.forEach({
            if $0 is UITextField {
                $0.addShadow(cornerRadius: 10)
            }
        })
        
        updateButton.addShadow(cornerRadius: 6)
        closeLabel.sk.setSpecificTextUnderLine("Close", color: R.color.textColor52()!)
        
        closeLabel.rx.tapGesture().when(.recognized).subscribe(onNext:{ _ in
            NameCardView.dismissNameCard()
        }).disposed(by: rx.disposeBag)
        
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sk.addCorner(conrners: [.topLeft,.topRight], radius: 20)
    }
}
