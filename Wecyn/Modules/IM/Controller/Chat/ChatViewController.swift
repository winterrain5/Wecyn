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
import MenuItemKit
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
    
    lazy var postMessageSizeCalculator = PostMessageLayoutSizeCalculator(layout: self.messagesCollectionView.messagesCollectionViewFlowLayout)
    
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
            vc.clearMessage = {
                self.loadHistoryMessage()
            }
            self.navigationController?.pushViewController(vc)
        }).disposed(by: rx.disposeBag)
        
        
        let leftButton = UIButton()
        leftButton.setImage(R.image.chevronBackward(), for: .normal)
        leftButton.frame = CGRect(x: 0, y: 0, width: 33, height: 40)
        leftButton.contentHorizontalAlignment = .left
        leftButton.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.markAsRead()
                self.navigationController?.popViewController()
            }).disposed(by: rx.disposeBag)
        self.navigation.item.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
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
        messagesCollectionView.register(PostMessageCell.self)
        
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
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longGestureAction(_:)))
        longGesture.minimumPressDuration = 0.5
        longGesture.numberOfTouchesRequired = 1
        longGesture.delegate = self
        messagesCollectionView.addGestureRecognizer(longGesture)
        
       
    }
    
    
    
    func configureMessageInputBar() {
        
        messageInputBar = iMessageInputBar()
        messageInputBar.delegate = self

        
    }

    
    func loadHistoryMessage() {
        DispatchQueue.global().async { [weak self] in
            guard let `self` = self else { return }
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
    
    func markAsRead(_ complete: (()->())? = nil) {
        IMController.shared.markMessageAsReaded(byConID: dataProvider.conversation.conversationID) {
            Logger.debug($0, label: IMLoggerLabel)
            complete?()
        }
    }
    
    @objc func loadMoreMessages() {
        self.dataProvider.loadPreviousMessages { [weak self] msgs in
            guard let `self` = self else { return }
            let messages = msgs.map({ IMMessage.build(messageInfo: $0) }).compactMap({  $0 })
            self.messageList.insert(contentsOf: messages, at: 0)
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
                self.refreshControl.endRefreshing()
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
        messagesCollectionView.performBatchUpdates({ [weak self] in
            guard let `self` = self else { return }
            if let index = indexPath {
                self.messagesCollectionView.insertItems(at: [index])
            } else {
                self.messagesCollectionView.insertSections([messageList.count - 1])
            }
            
        }, completion: { [weak self] _ in
            self?.messagesCollectionView.scrollToLastItem(animated: true)
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
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { [weak self] _ in
            guard let `self` = self else { return nil }
            
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
            let retweet = UIAction(title: "转发".innerLocalized()) {   _ in
                self.retweetMessage(message, indexPath)
            }
            let currendUser = IMController.shared.currentSender
            if message.user.senderId == currendUser.senderId {
                let delete = UIAction(title: "删除".innerLocalized()) { _ in
                    self.deleteMessage(message, indexPath)
                }
                
                let revoke = UIAction(title: "撤回".innerLocalized()) { _ in
                    self.revokeMessage(message, indexPath)
                }
                if message.sentDate.distance(to: Date()) > 120 {
                    return UIMenu(title: "Options", children: [copy, delete,retweet])
                } else {
                    return UIMenu(title: "Options", children: [copy, delete,retweet,revoke])
                }
                
            } else {
                return UIMenu(title: "Options", children: [copy, retweet])
            }
        })
            
    }
                                                                                      
    
    func deleteMessage(_ message:IMMessage,_ indexPath:IndexPath) {
        let alert = UIAlertController(title: "确定删除该条消息？".innerLocalized(), message: nil, preferredStyle: .alert)
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
   
    func revokeMessage(_ message:IMMessage,_ indexPath:IndexPath) {
        let alert = UIAlertController(title: "确定撤回该条消息？".innerLocalized(), message: nil, preferredStyle: .alert)
        let action1 = UIAlertAction(title: "确定".innerLocalized(), style: .destructive) { _ in
            
            if message.sentDate.distance(to: Date()) > 120 {
                return
            }
            
            IMController.shared.revokeMessage(conversationID: self.dataProvider.conversation.conversationID, clientMsgID: message.messageId) { data in
                
                let currendUser = IMController.shared.currentSender
                let text = "你撤回了一条消息".innerLocalized()
                var originText: String = ""
                if case MessageKind.text(let text) = message.kind {
                    originText = text
                }
                let item = RevokeItem(title: text,originText: originText)
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
    
    func retweetMessage(_ message:IMMessage,_ indexPath:IndexPath) {
        let vc = ChatContactsController(selectType: .select)
        let nav = BaseNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        UIViewController.sk.getTopVC()?.present(nav, animated: true)
        vc.didSelectContact = { [weak self] contact in
            guard let `self` = self else { return }
            let toID = contact.id.string
            IMController.shared.getConversation(sessionType:.c2c, sourceId:toID) { conversation in
                guard let conversation = conversation else { return }
            
                switch message.kind {
                case .text(let text):
                    
                    IMController.shared.sendTextMessage(text: text, to: toID, conversationType: .c2c) { info in
                        print(info)
                    } onComplete: { info in
                        if info.status == .sendSuccess {
                            let vc = ChatViewControllerBuilder().build(conversation)
                            self.navigationController?.pushViewController(vc)
                        }
                    }
                
                case .photo(let item):
                    let imageItem = item as! ImageMediaItem
                    
                    let url = imageItem.url?.absoluteString ?? ""
                    let w = imageItem.size.width.ceil
                    let h = imageItem.size.height.ceil
                    
                    let sourcePic = OIMPictureInfo()
                    sourcePic.url = url
                    sourcePic.width = w
                    sourcePic.height = h
                    
                    IMController.shared.sendImageMessage(byURL: url,
                                                         sourcePicture: sourcePic,
                                                         to: toID,
                                                         conversationType: .c2c) { messageInfo in
                        
                    } onComplete: { info in
                        
                        if info.status == .sendSuccess {
                            let vc = ChatViewControllerBuilder().build(conversation)
                            self.navigationController?.pushViewController(vc)
                        }
                       
                    }
                case .video(let item):
                    let videoItem = item as! VideoMediaItem
                    
                    let url = videoItem.url?.absoluteString ?? ""
                    let duration = videoItem.duration ?? 0
                    
                    IMController.shared.sendVideoMessage(byURL: url, duration: duration, size: 0, snapshotPath: "", to: toID, conversationType: .c2c) { info in
                        
                    } onComplete: { info in
                        if info.status == .sendSuccess {
                            let vc = ChatViewControllerBuilder().build(conversation)
                            self.navigationController?.pushViewController(vc)
                        }
                    }
                case .audio(let item):
                    let audioItem = item as! IMAudioItem
                    
                    let url = audioItem.url.absoluteString
                    let duration = audioItem.duration.int
                    
                    IMController.shared.sendAudioMessage(byURL: url, duration: duration, size: 0, to: toID, conversationType: .c2c) { info in
                        
                    } onComplete: { info in
                        if info.status == .sendSuccess {
                            let vc = ChatViewControllerBuilder().build(conversation)
                            self.navigationController?.pushViewController(vc)
                        }
                    }
                case .custom(let item):
                    if item is IMContactItem {
                        let contactItem = item as! IMContactItem
                        
                        let card = CardElem(userID: contactItem.id.string,
                                            nickname: contactItem.displayName,
                                            faceURL: contactItem.faceUrl,
                                            ex: contactItem.wid)
                        
                  
                        IMController.shared.sendCardMessage(card: card, to: toID, conversationType: .c2c) { info in
                            
                        } onComplete: { info in
                            
                            if info.status == .sendSuccess {
                                let vc = ChatViewControllerBuilder().build(conversation)
                                self.navigationController?.pushViewController(vc)
                            }
                            
                        }
                        
                    }
                    
                    if item is FileItem {
                        let fileItem = item as! FileItem
                        let url = fileItem.url?.absoluteString ?? ""
                        let name = fileItem.title ?? ""
                        let size = fileItem.size?.cgFloat.int  ?? 0
                        
                        IMController.shared.sendFileMessage(byURL: url, fileName: name, size: size, to: toID, conversationType: .c2c) { info in
                            
                        } onComplete: { info in
                            
                            if info.status == .sendSuccess {
                                let vc = ChatViewControllerBuilder().build(conversation)
                                self.navigationController?.pushViewController(vc)
                            }
                            
                        }

                    }
                    
                    if item is PostItem {
                        let postItem = item as! PostItem
                        let ext = postItem.content ?? ""
                        
                        IMController.shared.sendCustomMessage(data: "1",ext: ext, to:toID, conversationType: .c2c) { info in
                            
                        } onComplete: { info in
                            
                            if info.status == .sendSuccess {
                                let vc = ChatViewControllerBuilder().build(conversation)
                                self.navigationController?.pushViewController(vc)
                            }
                            
                        }
                    }
                    
                default:
                    break
                }
               
            }
        }
    }
    
    
    
    @objc func longGestureAction(_ gesture:UIGestureRecognizer) {
        
        if gesture.state == .began {
            Haptico.selection()
        }
        
        if gesture.state != .ended {
            return
        }
        
        
        let p = gesture.location(in: messagesCollectionView)
        
        if let indexPath = messagesCollectionView.indexPathForItem(at: p) {
            // get the cell at indexPath (the one you long pressed)
            
            
            guard let messagesDataSource = messagesCollectionView.messagesDataSource,
                  let cell = messagesCollectionView.cellForItem(at: indexPath)
            else {
                return
            }
            
            let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView) as! IMMessage
            let currendUser = IMController.shared.currentSender
            
            if case MessageKind.custom(let custom) = message.kind {
                if custom is RevokeItem {
                    return
                }
            }
            let controller = UIMenuController.shared
            
            let copy = UIMenuItem(title: "拷贝".innerLocalized()) { _ in
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
                
            
            
            let retweet = UIMenuItem(title: "转发".innerLocalized()) { [weak self] _ in
                self?.retweetMessage(message, indexPath)
            }
            
            
            
            if message.user.senderId == currendUser.senderId {
                let delete = UIMenuItem(title: "删除".innerLocalized()) {[weak self]  _ in
                    
                    self?.deleteMessage(message, indexPath)
                    
                }
                
                let revoke = UIMenuItem(title: "撤回".innerLocalized()) {[weak self] _ in
                   
                    self?.revokeMessage(message, indexPath)
                   
                }
                if message.sentDate.distance(to: Date()) <= 120 {
                    controller.menuItems = [copy, delete,retweet,revoke]
                } else {
                    controller.menuItems = [copy, delete,retweet]
                }
               
            } else {
                controller.menuItems = [copy]
            }
                
            if #available(iOS 13.0, *) {
                controller.showMenu(from: cell, rect: cell.bounds)
            } else {
              controller.setTargetRect(cell.bounds, in: cell)
              controller.setMenuVisible(true, animated: true)
            }
        }

    }
    
    deinit {
        print("chat view controller - deinit")
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocity(in: messagesCollectionView)
            return abs(velocity.x) > abs(velocity.y)
        }
        if let longGesture = gestureRecognizer as? UILongPressGestureRecognizer {
            return true
            
        }
        return false
    }
}

