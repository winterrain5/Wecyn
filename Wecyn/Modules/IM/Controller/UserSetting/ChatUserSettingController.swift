//
//  ChatUserSettingController.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/27.
//

import UIKit

class ChatUserSettingController: BaseTableController {
    var models:[[ChatSettingModel]] = []
    var conversation:ConversationInfo!
    var clearMessage: (()->())?
    init(conversation:ConversationInfo) {
        super.init(nibName: nil, bundle: nil)
        self.conversation = conversation
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let chatSticky = conversation.isPinned
        let chatMute = (conversation.recvMsgOpt == .notReceive || conversation.recvMsgOpt == .notNotify)
        models = [
            [ChatSettingModel(title:"查找聊天内容".innerLocalized(),type:.search, hasArrow: true)],
            [ChatSettingModel(title:"消息免打扰".innerLocalized(),type:.mute,isOn: chatMute,hasSwitch: true),
             ChatSettingModel(title:"置顶聊天".innerLocalized(),type: .pin,isOn:chatSticky, hasSwitch:true)],
            [ChatSettingModel(title: "清空聊天记录".innerLocalized(),type: .clear)]
        ]
        configBarButtonItem()
    }
    
    func configBarButtonItem() {
        let button = UIButton()
        button.imageForNormal = .init(nameInBundle: "common_more_btn_icon")
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        button.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            let vc = ChatFriendDetailController(id: conversation.userID?.int ?? 0,conversation: conversation)
            self.navigationController?.pushViewController(vc)
        }).disposed(by: rx.disposeBag)
    }
    
    override func createListView() {
        super.createListView()
        
        tableView?.register(cellWithClass: ChatSettingCell.self)
        tableView?.rowHeight = 50
        
        tableView?.estimatedSectionHeaderHeight = 16
        addSingleSeparator()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        models.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ChatSettingCell.self)
        cell.model = models[indexPath.section][indexPath.row]
        cell.statusChanged = { [weak self] in
            guard let `self` = self else { return }
            if $0.type == .mute {
                var status:ReceiveMessageOpt!
                if $0.isOn {
                    status = .notNotify
                } else {
                    status = .receive
                }
                IMController.shared.setConversationRecvMessageOpt(conversationID: self.conversation.conversationID, status: status) { msg in
                    self.tableView?.reloadData()
                    NotificationCenter.default.post(name: NSNotification.Name.UpdateConversation,object: nil)
                    print("set mute success")
                }
            }
            
            if $0.type == .pin {
                IMController.shared.pinConversation(id: self.conversation.conversationID, isPinned: !$0.isOn) { msg in
                    self.tableView?.reloadData()
                    NotificationCenter.default.post(name: NSNotification.Name.UpdateConversation,object: nil)
                    print("set pin success")
                }
            }
        }
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = models[indexPath.section][indexPath.row]
        if model.type == .search {
            let vc = ChatMessageSearchController(conversation: conversation)
            self.navigationController?.pushViewController(vc)
        }
        if model.type == .clear {
            let alert = UIAlertController(style: .actionSheet)
            alert.addAction(title: "清空聊天记录",style: .destructive) {[weak self] _ in
                guard let `self` = self else { return }
                IMController.shared.clearC2CHistoryMessages(conversationID: self.conversation.conversationID) { _ in
                    self.clearMessage?()
                    print("clear history success")
                    Toast.showSuccess("聊天记录已清除".innerLocalized())
                }
               
            }
            alert.addAction(title: "取消",style: .cancel) { _ in
                
            }
            
            alert.show()
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView().backgroundColor(R.color.backgroundColor()!)
        view.size = CGSize(width: kScreenWidth, height: 16)
        return view
        
    }
    
}
