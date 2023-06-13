//
//  NameCardContentView.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/12.
//

import UIKit

class NameCardContentView: UIView {

    @IBOutlet weak var nameCardEditButton: UIButton!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var companyLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var mobileNoLabel: UILabel!
    
    @IBOutlet weak var officeNoLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var websiteLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        editButton.rx.tap.subscribe(onNext:{
            NotificationCenter.default.post(name: NSNotification.Name.init("Profile_Change_NameCard_To_Edit"), object: nil)
        }).disposed(by: rx.disposeBag)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        cornerRadius = 8
    }

}
