//
//  ChatViewController.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/21.
//

import IQKeyboardManagerSwift
import UIKit
import InputBarAccessoryView
import MessageKit
import Kingfisher
import MapKit
import OpenIMSDK
import RxKeyboard

class ChatViewController: MessagesViewController {
    override var canBecomeFirstResponder: Bool { true }
    private(set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        return control
    }()
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    lazy var fileMessageSizeCalculator = FileMessageLayoutSizeCalculator(layout: self.messagesCollectionView.messagesCollectionViewFlowLayout)
    
    lazy var contactMessageSizeCalculator = CustomContactMessageLayoutSizeCalculator(layout: self.messagesCollectionView.messagesCollectionViewFlowLayout)
    
    lazy var revokeMessageSizeCalculator = RevokeMessageLayoutSizeCalculator(layout: self.messagesCollectionView.messagesCollectionViewFlowLayout)
    
    lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    var messageList:[IMMessage] = []
    
    
    private(set) var dataProvider:DefaultDataProvider
    
    init(dataProvider:DefaultDataProvider) {
        self.dataProvider = dataProvider
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IMController.shared.chatingConversationID = dataProvider.conversation.conversationID
        
        configureMessageInputBar()
        configureMessageCollectionView()
        configTitle()
        configBarButtonItem()
        markAsRead()
        addOBserver()
        
        dataProvider.delegate = self
        
        loadHistoryMessage()
        
    }
    
    func configBarButtonItem() {
        let button = UIButton()
        button.imageForNormal = .init(nameInBundle: "common_more_btn_icon")
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        button.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            let vc = ChatUserSettingController(conversation: self.dataProvider.conversation)
            self.navigationController?.pushViewController(vc)
        }).disposed(by: rx.disposeBag)
    }
    
    func configTitle() {
        let name = dataProvider.conversation.showName
        if dataProvider.conversation.userID == IMController.shared.currentSender.senderId {
            self.navigation.item.title = "文件传输助手".innerLocalized()
        } else {
            self.navigation.item.title = name
        }
        
    }
    
    
    func configureMessageCollectionView() {
        
        messagesCollectionView.register(FileMessageCell.self)
        messagesCollectionView.register(CustomContactMessageCell.self)
        messagesCollectionView.register(RevokeMessageCell.self)
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.setMessageIncomingAccessoryViewSize(CGSize(width: 20, height: 20))
        layout?.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 8, right: 0))
        layout?.setMessageIncomingAccessoryViewPosition(.messageCenter)
        layout?.setMessageOutgoingAccessoryViewSize(CGSize(width: 20, height: 20))
        layout?.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))
        layout?.setMessageIncomingAvatarPosition(AvatarPosition(vertical: .messageTop))
        layout?.setMessageOutgoingAvatarPosition(AvatarPosition(vertical: .messageTop))

        
        additionalBottomInset = 10
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        scrollsToLastItemOnKeyboardBeginsEditing = true
//              maintainPositionOnInputBarHeightChanged = true // default false
        showMessageTimestampOnSwipeLeft = true // default false
        
        messagesCollectionView.refreshControl = refreshControl
       
    }
    
 
    
    func configureMessageInputBar() {
        
        messageInputBar = iMessageInputBar()
        messageInputBar.delegate = self

        
    }
    
    func addOBserver() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.ClearC2CHistory, object: self, queue: OperationQueue.main) {  [weak self] noti in
            guard let `self` = self else { return }
            self.loadHistoryMessage()
        }
        
    }
    
    func loadHistoryMessage() {
        DispatchQueue.global().async {
            self.dataProvider.loadInitialMessages { mgs in
                let messages = mgs.map({ IMMessage.build(messageInfo: $0) }).compactMap({  $0 })
                self.messageList = messages
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0) {
                        self.messagesCollectionView.reloadData()
                    } completion: { flat in
                        self.messagesCollectionView.scrollToLastItem(animated: false)
                    }
                }
            }
        }
    }
    
    func markAsRead() {
        IMController.shared.markMessageAsReaded(byConID: dataProvider.conversation.conversationID, msgIDList: []) {
            Logger.debug($0, label: IMLoggerLabel)
        }
    }
    
    @objc func loadMoreMessages() {
        self.dataProvider.loadPreviousMessages { msgs in
            let messages = msgs.map({ IMMessage.build(messageInfo: $0) }).compactMap({  $0 })
            self.messageList = messages
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0) {
                    self.messagesCollectionView.reloadData()
                } completion: { flat in
                    self.messagesCollectionView.scrollToLastItem(animated: false)
                }
            }
        }
    }
    
   
    
    func isLastSectionVisible() -> Bool {
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    
    func revokeMessage(index:IndexPath? = nil) {
        if messageList.count > 0 {
            if let index = index {
                messageList.remove(at: index.section)
                messagesCollectionView.deleteSections(IndexSet(integer: index.section))
            } else {
                messageList.removeLast()
                messagesCollectionView.deleteSections(IndexSet(integer: messageList.count - 1))
            }
            
        }
    }
    
    func insertMessage(_ message: IMMessage,at indexPath:IndexPath? = nil) {
        
        if let indexPath = indexPath {
            messageList.insert(message, at: indexPath.section)
        } else {
            messageList.append(message)
        }
        
        
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            if let index = indexPath {
                messagesCollectionView.insertItems(at: [index])
            } else {
                messagesCollectionView.insertSections([messageList.count - 1])
            }
            
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        })
    }
    
    func reloadCollectionView(at indexPath:IndexPath? = nil) {
        if self.messageList.count >= 1 {
            if let indexPath = indexPath {
                self.messagesCollectionView.reloadItems(at: [indexPath])
            } else {
                self.messagesCollectionView.reloadSections([self.messageList.count - 1])
                if self.isLastSectionVisible() == true {
                    self.messagesCollectionView.scrollToLastItem(animated: true)
                }
            }
           
        }
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
      
        return false
    }

  
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource,let indexPath = indexPaths.first else {
            return nil
        }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView) as! IMMessage
        if case MessageKind.custom(let custom) = message.kind {
            if custom is RevokeItem {
                return nil
            }
        }
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
            
            let copy = UIAction(title: "拷贝".innerLocalized()) { _ in
                let pasteBoard = UIPasteboard.general
                switch message.kind {
                case .text(let text), .emoji(let text):
                    pasteBoard.string = text
                case .attributedText(let attributedText):
                    pasteBoard.string = attributedText.string
                default:
                    break
                }
            }
            let retweet = UIAction(title: "转发".innerLocalized()) { _ in
                
            }
            let currendUser = IMController.shared.currentSender
            if message.user.senderId == currendUser.senderId {
                let delete = UIAction(title: "删除".innerLocalized()) { _ in
                    
                    let alert = UIAlertController(title: "确定删除该条消息？".innerLocalized(), message: nil, preferredStyle: .actionSheet)
                    let action1 = UIAlertAction(title: "确定".innerLocalized(), style: .destructive) { _ in
                        if message.sendStatus == .sendFailure {
                            self.revokeMessage(index: indexPath)
                        } else {
                            IMController.shared.deleteMessage(conversation: self.dataProvider.conversation.conversationID, clientMsgID: message.messageId) { data in
                                self.revokeMessage(index: indexPath)
                            } onFailure: { errCode, errMsg in
                                print(errMsg)
                            }
                        }
                       
                    }
                    let action2 = UIAlertAction(title: "取消".innerLocalized(), style: .cancel) { _ in
                        
                    }
                    
                    alert.addAction(action1)
                    alert.addAction(action2)
                    
                    alert.show()
                   

                    
                }
                
                let revoke = UIAction(title: "撤回".innerLocalized()) { _ in
                    let alert = UIAlertController(title: "确定撤回该条消息？".innerLocalized(), message: nil, preferredStyle: .actionSheet)
                    let action1 = UIAlertAction(title: "确定".innerLocalized(), style: .destructive) { _ in
                        IMController.shared.revokeMessage(conversationID: self.dataProvider.conversation.conversationID, clientMsgID: message.messageId) { data in
                            
                            let currendUser = IMController.shared.currentSender
                            let text = "你撤回了一条消息".innerLocalized()
                            let item = RevokeItem(title: text)
                            let message = IMMessage(revokeItem: item, user: currendUser, messageId: UUID().uuidString, date: Date())
                            
                            self.messageList[indexPath.section] = message
                            
                            self.reloadCollectionView(at: indexPath)
                            
                        }
                    }
                    let action2 = UIAlertAction(title: "取消".innerLocalized(), style: .cancel) { _ in
                        
                    }
                    
                    alert.addAction(action1)
                    alert.addAction(action2)
                    
                    alert.show()
                   
                }
               return UIMenu(title: "Options", children: [copy, delete,retweet,revoke])
            } else {
               return UIMenu(title: "Options", children: [copy])
            }
                
            
        })
    }
   
    
    deinit {
        print("chat view controller - deinit")
    }
}

