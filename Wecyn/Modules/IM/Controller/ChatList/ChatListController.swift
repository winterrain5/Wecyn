//
//  ContactController.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/25.
//

import UIKit

class ChatListController: BaseTableController {
    
    private let _viewModel = ChatListViewModel()
    private var conversations:[ConversationInfo] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindData()
        addMenu()
        addObserver()
    }
    
    func addMenu() {
        let button = UIButton()
        button.imageForNormal = R.image.plusCircle()?.tintImage(.darkGray)
        button.showsMenuAsPrimaryAction = true
        
        let action0 = UIAction(title: "Chat",image: .init(nameInBundle: "chat_menu_create_group_icon")) { [weak self] _ in
            guard let `self` = self else { return }
            let vc = ChatContactsController(selectType: .chat)
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
        
        let action1 = UIAction(title: "Scan",image: .init(nameInBundle: "chat_menu_scan_icon")) { [weak self] _ in
            guard let `self` = self else { return }
            Toast.showWarning("功能开发中")
        }
        
        let action2 = UIAction(title: "Add Friend",image: .init(nameInBundle: "chat_menu_add_friend_icon")){ [weak self] _ in
            let vc = ConnectionUsersController()
            self?.navigationController?.pushViewController(vc)
        }
        
        let action3 = UIAction(title: "Group Chat",image: .init(nameInBundle: "chat_menu_add_group_icon")) { [weak self] _ in
            guard let `self` = self else { return }
            Toast.showWarning("功能开发中")
        }
        let items = [action0,action1,action2,action3]
        button.menu = UIMenu(children: items)
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    func bindData() {
        IMController.shared.connectionRelay.subscribe(onNext:{ [weak self] status in
            if status == .syncComplete {
                var conversation = self?._viewModel.conversationsRelay.value
                conversation?.removeAll(where: { $0.conversationType == .notification })
                let count = conversation?.count ?? 0
                self?.navigation.item.title =  count > 0 ? "Wecyn(\(count))" : "Wecyn"
            } else {
                self?.navigation.item.title = status.title
            }
            
        }).disposed(by: rx.disposeBag)
        
        
        
        
        _viewModel.conversationsRelay.asObservable().subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.conversations = $0
            self.conversations.removeFirst(where: { $0.conversationType == .notification })
            
            if conversations.filter({ $0.userID == IMController.shared.currentSender.senderId }).count == 0 {
                let fileTrans = ConversationInfo(conversationID: "")
                fileTrans.userID = IMController.shared.currentSender.senderId
                conversations.insert(fileTrans, at: 0)
            }
            
            let count = self.conversations.count
            self.endRefresh(count, emptyString: "No Conversations")
            self.navigation.item.title = count > 0 ? "Wecyn(\(count))" : "Wecyn"
            
        },onError: { e in
            self.endRefresh(.NoData, emptyString: "No Conversations")
        }).disposed(by: rx.disposeBag)
        

    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UpdateConversation, object: self, queue: OperationQueue.main) {  [weak self] noti in
            
            guard let `self` = self else { return }
            self._viewModel.getAllConversations()
        }
    }
    
    override func refreshData() {
        _viewModel.getAllConversations()
    }
    
    override func createListView() {
        super.createListView()
        
        tableView?.register(nibWithCellClass: ChatListCell.self)
        tableView?.rowHeight = 70
        addSingleSeparator()
        registRefreshHeader()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: ChatListCell.self)
        if conversations.count > 0 {
            cell.model = conversations[indexPath.row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let conversation = conversations[indexPath.row]
        
        if conversation.conversationID.isEmpty {
            createConversation(conversation:  nil)
        } else {
            createConversation(conversation: conversation)
        }
        
    }
    
    func createConversation(conversation:ConversationInfo?) {
        if let conversation = conversation {
            
            let vc = ChatViewControllerBuilder().build(conversation)
            self.navigationController?.pushViewController(vc)
            
        } else {
            let sourceId = IMController.shared.currentSender.senderId
            let name = IMController.shared.currentSender.displayName
            let faceUrl = IMController.shared.currentSender.faceUrl
            IMController.shared.getConversation(sourceId:sourceId) { conversation in
                guard let conversation = conversation else { return }
                conversation.userID = sourceId
                conversation.showName = name
                conversation.faceURL = faceUrl
                conversation.conversationType = .c2c
                let vc = ChatViewControllerBuilder().build(conversation)
                self.navigationController?.pushViewController(vc)
            }
           
        }
       
    }
    
    public func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = conversations[indexPath.row]
        
        let markReadTitle = "标为已读".innerLocalized()
        let markReadAction = UIContextualAction(style: .normal, title: markReadTitle) { [weak self] _, _, completion in
            self?._viewModel.markReaded(id: item.conversationID, onSuccess: { _ in
                completion(true)
            })
        }
        markReadAction.backgroundColor = UIColor.c8E9AB0
        
        let deleteAction = UIContextualAction(style: .destructive, title: "删除".innerLocalized()) { [weak self] _, _, completion in
            self?._viewModel.deleteConversation(conversationID: item.conversationID, completion: { _ in
                self?.conversations.remove(at: indexPath.row)
                self?.tableView?.deleteRows(at: [indexPath], with: .automatic)
                completion(true)
            })
        }
        
        deleteAction.backgroundColor = UIColor.cFF381F
        let configure = UISwipeActionsConfiguration(actions: [deleteAction, markReadAction])
        return configure
    }
    
}

