//
//  ChatListViewModel.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/26.
//

import UIKit
class ChatListViewModel {
    var conversationsRelay: BehaviorRelay<[ConversationInfo]> = .init(value: [])
    let loginUserPublish: PublishSubject<UserInfo?> = .init()
    private func getSelfInfo(onSuccess: @escaping CallBack.UserInfoOptionalReturnVoid) {
        IMController.shared.getSelfInfo(onSuccess: onSuccess)
    }

    func getSelfInfo() {
        IMController.shared.getSelfInfo { [weak self] (userInfo: UserInfo?) in
            self?.loginUserPublish.onNext(userInfo)
        }
    }

    func getAllConversations() {
        IMController.shared.getAllConversationList { [weak self] (conversations: [ConversationInfo]) in
            guard let sself = self else { return }
            sself.sortConversations(conversations)
        }
    }

    func setConversation(id: String, status: ReceiveMessageOpt) {
        IMController.shared.setConversationRecvMessageOpt(conversationID: id, status: status, completion: nil)
    }

    func pinConversation(id: String, isPinned: Bool, onSuccess: @escaping CallBack.StringOptionalReturnVoid) {
        IMController.shared.pinConversation(id: id, isPinned: isPinned) { [weak self] (resp: String?) in
            self?.getAllConversations()
            onSuccess(resp)
        }
    }
    
    func clearC2CHistoryMessage(id: String, onSuccess: @escaping CallBack.StringOptionalReturnVoid) {
        IMController.shared.clearC2CHistoryMessages(conversationID: id, onSuccess: onSuccess)
    }
    
    
    func markReaded(id: String, onSuccess: @escaping CallBack.StringOptionalReturnVoid) {
        IMController.shared.markMessageAsReaded(byConID: id) { [weak self] msg in
            self?.getAllConversations()
            onSuccess(msg)
        }
    }

    func deleteConversation(conversationID: String, completion: ((String?) -> Void)?) {

        IMController.shared.imManager.deleteConversationAndDeleteAllMsg(conversationID) { text in
            completion?(text)
        } onFailure: { code, msg in
            Toast.showError("Delete Conversation Failed")
            print("清除指定会话失败:\(code) - \(msg ?? "")")
        }

    }

    init() {
        IMController.shared.newConversationSubject.subscribe(onNext: { [weak self] (conversations: [ConversationInfo]) in
            guard let sself = self else { return }
            var origin = sself.conversationsRelay.value
                
            for item in conversations {
                if !origin.contains(where: { info in
                    return info.conversationID == item.conversationID
                }) {
                    origin.append(item)
                }
            }
            
            self?.sortConversations(origin)
        }).disposed(by: _disposeBag)

        IMController.shared.conversationChangedSubject.subscribe(onNext: { [weak self] (conversations: [ConversationInfo]) in
            guard let sself = self else { return }
            let changedIds: [String] = conversations.compactMap { $0.conversationID }
            let origin = sself.conversationsRelay.value
            var ret = origin.filter { (chat: ConversationInfo) -> Bool in
                !changedIds.contains(chat.conversationID)
            }
            ret.append(contentsOf: conversations)
            self?.sortConversations(ret)
        }).disposed(by: _disposeBag)

        self.getAllConversations()
        self.getSelfInfo(onSuccess: { [weak self] (userInfo: UserInfo?) in
            self?.loginUserPublish.onNext(userInfo)
        })
    }
    
    private func removeConversation(_ conversationID: String) {
        var origin = conversationsRelay.value
        
        var changed = false
        for (index, item) in conversationsRelay.value.enumerated() {
            if item.conversationID == conversationID {
                origin.remove(at: index)
                changed = true
            }
        }
        
        if changed {
            conversationsRelay.accept(origin)
        }
    }

    private func sortConversations(_ conversations: [ConversationInfo]) {
        let sorted = conversations.sorted { (lhs: ConversationInfo, rhs: ConversationInfo) in
            lhs.latestMsgSendTime > rhs.latestMsgSendTime
        }
        var pinned: [ConversationInfo] = []
        var normal: [ConversationInfo] = []
        for conversation in sorted {
            if conversation.isPinned {
                pinned.append(conversation)
            } else {
                normal.append(conversation)
            }
        }
        pinned.append(contentsOf: normal)
        conversationsRelay.accept(pinned)
    }

    private let _disposeBag = DisposeBag()
}
