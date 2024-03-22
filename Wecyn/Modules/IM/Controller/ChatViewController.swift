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
    
    var user:FriendUserInfoModel!
    var replyUser:IMUser!
    required init (user:FriendUserInfoModel) {
        super.init(nibName: nil, bundle: nil)
        self.user = user
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMessageCollectionView()
        configureMessageInputBar()
        
        replyUser = IMUser(senderId: user.id.string, displayName: user.full_name)
        navigation.item.title = user.full_name
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
}






