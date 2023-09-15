//
//  FriendDetailController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/10.
//

import UIKit
class FriendDetailController: BaseTableController {
    
    var id:Int = 0
    var model:FriendUserInfoModel?
    var deleteUserComplete:((Int)->())?
    init(id:Int) {
        super.init(nibName: nil, bundle: nil)
        self.id = id
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showSkeleton()
        FriendService.friendUserInfo(id).subscribe(onNext:{
            self.model = $0
            self.reloadData()
            self.hideSkeleton()
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype)
            self.hideSkeleton()
        }).disposed(by: rx.disposeBag)
        
        let more = UIButton()
        more.imageForNormal = R.image.ellipsis()
        more.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            let alert = UIAlertController(style: .actionSheet,title: "Are you sure you want to delete this friend?")
            alert.addAction(title: "Confirm",style: .destructive) { _ in
                Toast.showLoading()
                FriendService.deleteFriend(friend_id: self.model?.id ?? 0).subscribe(onNext:{ status in
                    Toast.dismiss()
                    if status.success == 1 {
                        Toast.showSuccess(withStatus: "Delete Success")
                        self.deleteUserComplete?(self.model?.id ?? 0)
                    } else {
                        Toast.showError(withStatus: status.message)
                    }
                    
                },onError: { e in
                    Toast.showError(withStatus: e.asAPIError.errorInfo().message)
                }).disposed(by: self.rx.disposeBag)
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.show()
        }).disposed(by: rx.disposeBag)
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: more)
    }
    
    override func createListView() {
        super.createListView()
        numberOfSkeletonCell = 1
        cellIdentifier  = FriendDetailHeadCell.className
        tableView?.isSkeletonable = true
        tableView?.register(cellWithClass: FriendDetailSendMessageCell.self)
        tableView?.register(cellWithClass: FriendDetailHeadCell.self)
        tableView?.backgroundColor = R.color.backgroundColor()!
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0  {
            return 108
        }
        return 44
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withClass: FriendDetailHeadCell.self)
            if let model = self.model {
                cell.model = model
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withClass: FriendDetailSendMessageCell.self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView().backgroundColor(R.color.backgroundColor()!)
        return view
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
}

class FriendDetailHeadCell: UITableViewCell {
    var imgView = UIImageView()
    var nameLabel = UILabel()
    var widLabel = UILabel()
    var emailLabel = UILabel()
    var model: FriendUserInfoModel? {
        didSet {
            guard let model = model else { return }
            imgView.kf.setImage(with: model.avatar.url,placeholder: R.image.proile_user())
            nameLabel.text = model.full_name
            widLabel.text = "WID: \(model.wid)"
//            emailLabel.text = "Email: \(model.email)"
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(imgView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(widLabel)
        contentView.addSubview(emailLabel)
        
        contentView.backgroundColor = .white
        
        imgView.cornerRadius = 26
        imgView.contentMode = .scaleAspectFill
        imgView.isSkeletonable = true
        
        nameLabel.textColor = R.color.textColor52()
        nameLabel.font = UIFont.sk.pingFangSemibold(16)
        nameLabel.isSkeletonable = true
        
        widLabel.textColor = R.color.textColor74()
        widLabel.font = UIFont.sk.pingFangRegular(15)
        widLabel.isSkeletonable = true
        
        emailLabel.textColor = R.color.textColor74()
        emailLabel.font = UIFont.sk.pingFangRegular(15)
        emailLabel.isSkeletonable = true
        
        isSkeletonable = true
        contentView.isSkeletonable = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imgView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(16)
            make.height.width.equalTo(52)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalTo(imgView.snp.right).offset(8)
        }
        widLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.left.equalTo(imgView.snp.right).offset(8)
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(widLabel.snp.bottom).offset(4)
            make.left.equalTo(imgView.snp.right).offset(8)
        }
    }
}

class FriendDetailNomalCell: UITableViewCell {
    
    var label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.textAlignment = .center
        label.font = UIFont.sk.pingFangRegular(16)
        
        contentView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
    }
}

class FriendDetailSendMessageCell: UITableViewCell {
    var btn = UIButton()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        contentView.addSubview(btn)
        btn.titleForNormal = " Send Message"
        btn.titleColorForNormal = R.color.textColor162C46()
        btn.titleLabel?.font = UIFont.sk.pingFangSemibold(15)
        btn.imageForNormal = R.image.message()
        
        contentView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        btn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
    }
}
