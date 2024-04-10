//
//  FriendDetailController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/10.
//

import UIKit
class ChatFriendDetailController: BaseTableController {
    
    var id:Int = 0
    var model:FriendUserInfoModel?
    var conversation:ConversationInfo?
    var deleteUserComplete:((Int)->())?
    
    init(id:Int,conversation:ConversationInfo? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.id = id
        self.conversation = conversation
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isSkeletonable = true
        self.showSkeleton()
        NetworkService.friendUserInfo(id).subscribe(onNext:{
            self.model = $0
            self.reloadData()
            self.hideSkeleton()
            
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype)
            self.hideSkeleton()
        }).disposed(by: rx.disposeBag)
        
       
    }
    
   
    
    override func createListView() {
        super.createListView()
        numberOfSkeletonCell = 1
        cellIdentifier  = FriendDetailHeadCell.className
        tableView?.separatorStyle = .singleLine
        tableView?.separatorColor = R.color.seperatorColor()!
        tableView?.separatorInset = .zero
        tableView?.isSkeletonable = true
        tableView?.register(cellWithClass: FriendDetailSendMessageCell.self)
        tableView?.register(cellWithClass: FriendDetailHeadCell.self)
        tableView?.register(cellWithClass: FriendDetailNomalCell.self)
        tableView?.register(cellWithClass: FriendDetailDeleteCell.self)
        tableView?.backgroundColor = R.color.backgroundColor()!
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0  {
            return indexPath.row == 0 ? 104 : 44
        }
        return 44
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            if model?.friend_status == 1 {
                return 1
            } else if model?.friend_status == 3  {
              return 0
            } else {
                return 2
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withClass: FriendDetailHeadCell.self)
                cell.accessoryType = .disclosureIndicator
                if let model = self.model {
                    cell.model = model
                }
                return cell
            }
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withClass: FriendDetailNomalCell.self)
                cell.label.text = "设置备注".innerLocalized()
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .none
                return cell
            }
          
        }
        if indexPath.section == 1 {
            if model?.friend_status == 1 { // 不是好友
                let cell = tableView.dequeueReusableCell(withClass: FriendDetailNomalCell.self)
                cell.label.text = "添加到通讯录".innerLocalized()
                cell.textLabel?.textAlignment = .center
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .none
                return cell
            } else {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCell(withClass: FriendDetailSendMessageCell.self)
                    return cell
                }
                if indexPath.row == 1 {
                    let cell = tableView.dequeueReusableCell(withClass: FriendDetailDeleteCell.self)
                    return cell
                }
            }
            
        }
      return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && model?.friend_status == 3 {
            return 40
        }
        return 20
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView().backgroundColor(R.color.backgroundColor()!)
        if section == 0 && model?.friend_status == 3 {
            let label = UILabel()
            label.text = "等待对方验证好友申请".innerLocalized()
            label.textColor  = .gray
            label.font = .systemFont(ofSize: 16)
            label.frame = CGRect(x: 16, y: 0, width: kScreenWidth - 32, height: 40)
            view.addSubview(label)
        }
        return view
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let model = model else { return }
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let vc = NFCNameCardController(id: model.id)
                self.navigationController?.pushViewController(vc)
            }
            if indexPath.row == 1 {
               
                let vc = FriendAddRemarkController(model: model)
                let nav = BaseNavigationController(rootViewController: vc)
                self.present(nav, animated: true)
                vc.updateRemarkComplete = { [weak self] in
                    self?.tableView?.reloadData()
                }
            }
        }
        
        if indexPath.section == 1 {
            if model.friend_status == 1 {
                let vc = ChatSendAddFriendRequestController(model: model)
                let nav = BaseNavigationController(rootViewController: vc)
                self.present(nav, animated: true)
            } else {
                if indexPath.row == 0 {
                    createConversation(model.id,model.full_name)
                }
                if indexPath.row == 1 {
                    deleteUser()
                }
            }
           
        }
        
    }
    
    
    func createConversation(_ id:Int,_ name:String) {
        if let conversation = conversation {
            
            let vc = ChatViewControllerBuilder().build(conversation)
            self.navigationController?.pushViewController(vc)
            
        } else {
            
            IMController.shared.getConversation(sourceId:id.string) { conversation in
                guard let conversation = conversation else { return }
                conversation.userID = id.string
                conversation.showName = name
                conversation.faceURL = self.model?.avatar
                conversation.conversationType = .c2c
                let dataProvider = DefaultDataProvider(conversation: conversation)
                let vc = ChatViewController(dataProvider: dataProvider)
                self.navigationController?.pushViewController(vc)
            }
           
        }
       
    }
    
    func deleteUser() {
        let alert = UIAlertController(style: .actionSheet,title: "Are you sure you want to delete this friend?")
        alert.addAction(title: "Confirm",style: .destructive) { _ in
            Toast.showLoading()
            NetworkService.deleteFriend(friend_id: self.model?.id ?? 0).subscribe(onNext:{ status in
                Toast.dismiss()
                if status.success == 1 {
                    Toast.showSuccess( "Delete Success")
                    self.deleteUserComplete?(self.model?.id ?? 0)
                    self.navigationController?.popViewController()
                } else {
                    Toast.showError(status.message)
                }
                
            },onError: { e in
                Toast.showError(e.asAPIError.errorInfo().message)
            }).disposed(by: self.rx.disposeBag)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.show()
    }
}

class FriendDetailHeadCell: UITableViewCell {
    let imgView = UIImageView()
    let nameLabel = UILabel()
    let widLabel = UILabel()
    let remarkLabel = UILabel()
    let arrowButton = UIButton()
    var model: FriendUserInfoModel? {
        didSet {
            guard let model = model else { return }
            imgView.kf.setImage(with: model.avatar.url,placeholder: R.image.proile_user())
            nameLabel.text = model.full_name
            widLabel.text = "WID: \(model.wid)"
            remarkLabel.text = model.remark
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(imgView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(widLabel)
        contentView.addSubview(remarkLabel)
        
        contentView.backgroundColor = .white
        
        imgView.cornerRadius = 34
        imgView.contentMode = .scaleAspectFill
        imgView.isSkeletonable = true
        
        nameLabel.textColor = R.color.textColor33()
        nameLabel.font = UIFont.sk.pingFangSemibold(16)
        nameLabel.isSkeletonable = true
        
        widLabel.textColor = R.color.textColor77()
        widLabel.font = UIFont.sk.pingFangRegular(15)
        widLabel.isSkeletonable = true
        
        remarkLabel.textColor = R.color.textColor77()
        remarkLabel.font = UIFont.sk.pingFangRegular(15)
        remarkLabel.isSkeletonable = true
        
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
            make.height.width.equalTo(68)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalTo(imgView.snp.right).offset(8)
            make.height.equalTo(23)
        }
        widLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.left.equalTo(imgView.snp.right).offset(8)
            make.height.equalTo(21)
        }
        
        remarkLabel.snp.makeConstraints { make in
            make.top.equalTo(widLabel.snp.bottom).offset(4)
            make.left.equalTo(imgView.snp.right).offset(8)
            make.height.equalTo(21)
        }
    }
}

class FriendDetailNomalCell: UITableViewCell {
    
    var label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.textAlignment = .left
        label.font = UIFont.sk.pingFangRegular(15)
        
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

class FriendDetailDeleteCell: UITableViewCell {
    
    var label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        label.textAlignment = .center
        label.font = UIFont.sk.pingFangSemibold(15)
        label.textColor = .red
        label.text = "Delete Connection"
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
        btn.titleColorForNormal = R.color.textColor22()
        btn.titleLabel?.font = UIFont.sk.pingFangSemibold(15)
        btn.imageForNormal = R.image.message()
        btn.isUserInteractionEnabled = false
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