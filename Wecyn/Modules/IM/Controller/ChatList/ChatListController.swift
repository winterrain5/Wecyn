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
        
        let action1 = UIAction(title: "Scan",image: .init(nameInBundle: "chat_menu_scan_icon")) { [weak self] _ in
            guard let `self` = self else { return }
        }
        
        let action2 = UIAction(title: "Add Friend",image: .init(nameInBundle: "chat_menu_add_friend_icon")){ [weak self] _ in
            let vc = ConnectionUsersController()
            self?.navigationController?.pushViewController(vc)
        }
        
        let action3 = UIAction(title: "Group Chat",image: .init(nameInBundle: "chat_menu_add_group_icon")) { [weak self] _ in
            guard let `self` = self else { return }
            
        }
        let items = [action1,action2,action3]
        button.menu = UIMenu(children: items)
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    func bindData() {
        IMController.shared.connectionRelay.subscribe(onNext:{ [weak self] status in
            if status == .syncComplete {
                let count = self?._viewModel.conversationsRelay.value.count ?? 0
                self?.navigation.item.title =  count > 0 ? "Wecyn(\(count))" : "Wecyn"
            } else {
                self?.navigation.item.title = status.title
            }
            
        }).disposed(by: rx.disposeBag)
        
        _viewModel.conversationsRelay.asObservable().subscribe(onNext:{ [weak self] in
            
            self?.conversations = $0
            self?.endRefresh($0.count, emptyString: "No Conversations")
            
            self?.navigation.item.title = $0.count > 0 ? "Wecyn(\($0.count))" : "Wecyn"
            
        },onError: { e in
            self.endRefresh(.NoData, emptyString: "No Conversations")
        }).disposed(by: rx.disposeBag)
        
        
        let status = IMController.shared.getLoginStatus()
        switch status {
        case .logged:
            Logger.debug("im logged",label: IMLoggerLabel)
        case .logging:
            Logger.debug("im logging",label: IMLoggerLabel)
        case .logout:
            Logger.debug("im logout",label: IMLoggerLabel)
        @unknown default:
            fatalError()
        }
        
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
        let vc = ChatViewControllerBuilder().build(conversation)
        self.navigationController?.pushViewController(vc)
    }
    
    public func tableView(_: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = _viewModel.conversationsRelay.value[indexPath.row]
        
        
        let markReadTitle = "标为已读".innerLocalized()
        let markReadAction = UIContextualAction(style: .normal, title: markReadTitle) { [weak self] _, _, completion in
            self?._viewModel.markReaded(id: item.conversationID, onSuccess: { _ in
                completion(true)
            })
        }
        markReadAction.backgroundColor = UIColor.c8E9AB0
        
        let deleteAction = UIContextualAction(style: .destructive, title: "删除".innerLocalized()) { [weak self] _, _, completion in
            self?._viewModel.deleteConversation(conversationID: item.conversationID, completion: { _ in
                completion(true)
            })
        }
        
        deleteAction.backgroundColor = UIColor.cFF381F
        let configure = UISwipeActionsConfiguration(actions: [deleteAction, markReadAction])
        return configure
    }
    
}

