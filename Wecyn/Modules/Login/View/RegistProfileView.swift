//
//  RegistProfileView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/9.
//

import UIKit

class RegistProfileView: UIView {

    @IBOutlet weak var jobTitleTf: UITextField!
    
    @IBOutlet weak var emType: UITextField!
    
    @IBOutlet weak var companyTf: UITextField!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var studentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        nextButton.addShadow(cornerRadius: 20)
        self.subviews.filter({ $0 is UITextField }).forEach({ $0.addShadow(cornerRadius: 11) })
        
        studentLabel.sk.setSpecificTextUnderLine("I'm a student", color: R.color.textColor52()!)
        studentLabel.rx.tapGesture().when(.recognized).subscribe(onNext:{ _ in
            let main = MainController()
            UIApplication.shared.keyWindow?.rootViewController =  main
        }).disposed(by: rx.disposeBag)
        
        nextButton.rx.tap.subscribe(onNext:{
            UIViewController.sk.getTopVC()?.navigationController?.pushViewController(RegistAddAvatarController())
        }).disposed(by: rx.disposeBag)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}
