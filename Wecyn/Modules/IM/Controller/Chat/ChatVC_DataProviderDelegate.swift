//
//  ChatVC_DataProviderDelegate.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/27.
//

import Foundation
import MessageKit
extension ChatViewController:DataProviderDelegate  {
    
    func received(message: MessageInfo) {
        // message.sendID receiverId 一致
        let flag1 = (message.sendID == dataProvider.receiverId || message.sendID == IMController.shared.currentSender.senderId)
        if flag1 {
            
            guard let msg = IMMessage.build(messageInfo: message) else  { return }
            if let idx = self.messageList.firstIndex(where: { $0.messageId == message.clientMsgID }) {
                let indexPath = IndexPath(item: 0, section: idx)
                self.messageList[idx] = msg
                self.reloadCollectionView(at: indexPath)
            } else {
                insertMessage(msg)
            }
            
            
        }
        
       
        
    }
    
    func typingStateChanged(to state: TypingState) {
        
    }
    
    func lastReadIdsChanged(to ids: [String], readUserID: String?) {
        
    }
    
    func lastReceivedIdChanged(to id: String) {
        
    }
    
    func isInGroup(with isIn: Bool) {
        
    }
    
    func isRevokeMessage(revoke: MessageRevoked) {
        
        if revoke.revokerIsSelf {
           return
        }
        
        guard let index = self.messageList.firstIndex(where: { $0.messageId == revoke.clientMsgID }) else { return }
        let text = (revoke.revokerNickname ?? "") + "撤回了一条消息".innerLocalized()
        let item = RevokeItem(title: text)
        let user = IMUser(senderId: revoke.revokerID ?? "", displayName: revoke.revokerNickname ?? "", faceUrl: nil)
        let message = IMMessage(revokeItem: item, user: user, messageId: revoke.clientMsgID  ?? "", date: Date())
        
        let indexPath = IndexPath(item: 0, section: index)
        self.messageList[indexPath.section] = message
        
        self.reloadCollectionView(at: indexPath)
        
    }
    
    
}


