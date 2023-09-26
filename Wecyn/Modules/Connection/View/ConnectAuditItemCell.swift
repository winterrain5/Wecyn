//
//  ConnectAuditItemCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/25.
//

import UIKit

class ConnectAuditItemCell: UITableViewCell {
    
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var shadowView: UIView!
    
    @IBOutlet weak var agreeButton: UIButton!
    
    @IBOutlet weak var avatarView: UIImageView!
    
    var auditHandler: (()->())!
    
    var model: FriendRecieveModel? {
        didSet {
            guard let model = model else { return }
            nameLabel.text = String.fullName(first: model.first_name, last: model.last_name)
            avatarView.kf.setImage(with: model.avatar.url,placeholder: R.image.proile_user()!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shadowView.addShadow(cornerRadius: 8)
        agreeButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Toast.showLoading()
            NetworkService.auditFriend(from_user_id: self.model?.from_user_id ?? 0, audit_status: 1).subscribe(onNext:{ status in
                Toast.dismiss()
                if status.success == 1 {
                    Toast.showSuccess(withStatus: "Successful operation")
                    self.auditHandler()
                } else {
                    Toast.showError(withStatus: status.message)
                }
                
            },onError: { e in
                Toast.showError(withStatus: e.asAPIError.errorInfo().message)
            }).disposed(by: self.rx.disposeBag)
            
        }).disposed(by: rx.disposeBag)
        
        rejectButton.rx.tap.subscribe(onNext:{  [weak self] in
            guard let `self` = self else { return }
            
            Toast.showLoading()
            NetworkService.auditFriend(from_user_id: self.model?.from_user_id ?? 0, audit_status: 2).subscribe(onNext:{ status in
                Toast.dismiss()
                if status.success == 1 {
                    Toast.showSuccess(withStatus: "Successful operation")
                    self.auditHandler()
                } else {
                    Toast.showError(withStatus: status.message)
                }
                
            },onError: { e in
                Toast.showError(withStatus: e.asAPIError.errorInfo().message)
            }).disposed(by: self.rx.disposeBag)
            
        }).disposed(by: rx.disposeBag)
        
    }
    
    
}
