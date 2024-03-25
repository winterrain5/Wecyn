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
    
    var replyuser:FriendUserInfoModel!
    var replyIMUser:IMUser!
    required init (replyuser:FriendUserInfoModel) {
        super.init(nibName: nil, bundle: nil)
        self.replyuser = replyuser
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMessageCollectionView()
        configureMessageInputBar()
        
        replyIMUser = IMUser(senderId: replyuser.id.string, displayName: replyuser.full_name)
        navigation.item.title = replyuser.full_name
        
        addObserver()
    }
    
    
    func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true // default false
        //      maintainPositionOnInputBarHeightChanged = true // default false
        showMessageTimestampOnSwipeLeft = true // default false
        
        messagesCollectionView.refreshControl = refreshControl
        
        
    }
    
    func configureMessageInputBar() {
        
        messageInputBar = iMessageInputBar()
        messageInputBar.delegate = self
        
    }
    
    @objc func loadMoreMessages() {
        self.messagesCollectionView.reloadDataAndKeepOffset()
        self.refreshControl.endRefreshing()
    }
    
    func addObserver() {
        
        IMController.shared.newMsgReceivedSubject.subscribe(onNext:{ [weak self] in
            print($0)
        }).disposed(by: rx.disposeBag)
    }
}






