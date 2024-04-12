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
        let flag1 = message.sendID == dataProvider.receiverId
        if flag1 {
            guard let message = IMMessage.build(messageInfo: message) else  { return }
            insertMessage(message)
        }
        
        let topVc = UIViewController.sk.getTopVC()
        if topVc is ChatViewController || topVc is ChatListController {
            return
        }
        
//        let notificationView = NotificationView()
//        notificationView.title = message.senderNickname
//        let date = Date.init(unixTimestamp: message.sendTime / 1000)
//        notificationView.date = MessageKitDateFormatter.shared.string(from: date)
//        notificationView.body = message.getAbstruct()
//        notificationView.show()
     
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
        
        if self.messageList.contains(where: { $0.messageId == revoke.clientMsgID }) {
            return
        }
        let currendUser = IMController.shared.currentSender
        var sender:IMUser!
        let text:String
        if revoke.sourceMessageSendID == currendUser.senderId {
            sender = currendUser
            text = "你撤回了一条消息".innerLocalized()
        } else {
            sender = IMUser(senderId: revoke.sourceMessageSendID ?? "", displayName: revoke.revokerNickname ?? "",faceUrl: nil)
            text = (revoke.revokerNickname ?? "")  + "撤回了一条消息".innerLocalized()
        }
        let item = RevokeItem(title: text)
        let message = IMMessage(revokeItem: item, user: sender, messageId: revoke.clientMsgID ?? "", date: Date())
        
        guard let section = self.messageList.firstIndex(where: { $0.messageId == revoke.clientMsgID }) else { return }
        let indexPath = IndexPath(item: 0, section: section)
        insertMessage(message, at: indexPath)
        reloadCollectionView(at: indexPath)
       
        
    }
    
    
}


