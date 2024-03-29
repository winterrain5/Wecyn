//
//  ChatViewController.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/21.
//

import UIKit
import InputBarAccessoryView
import MessageKit
import Kingfisher
import MapKit
import OpenIMSDK

class ChatViewController: MessagesViewController {
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
        
        configureMessageCollectionView()
        configureMessageInputBar()
        configTitle()
        configBarButtonItem()
        markAsRead()
        
        dataProvider.delegate = self
        
        DispatchQueue.global().async {
            self.dataProvider.loadInitialMessages { mgs in
                let messages = mgs.map({ IMMessage.build(messageInfo: $0) })
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
        self.navigation.item.title = name
    }
    
    
    func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
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
            self.messageList.removeAll()
            self.messagesCollectionView.reloadData()
           
        }
    }
    
    func markAsRead() {
        IMController.shared.markMessageAsReaded(byConID: dataProvider.conversation.conversationID, msgIDList: []) {
            Logger.debug($0, label: IMLoggerLabel)
        }
    }
    
    @objc func loadMoreMessages() {
        self.messagesCollectionView.reloadDataAndKeepOffset()
        self.refreshControl.endRefreshing()
    }
    
    func insertMessage(_ message: IMMessage) {
        messageList.append(message)
        messageInputBar.sendButton.stopAnimating()
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        })
    }
    
    func isLastSectionVisible() -> Bool {
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    deinit {
        print("chat view controller - deinit")
    }
}


