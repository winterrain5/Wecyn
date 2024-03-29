//
//  ChatVC_DataProviderDelegate.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/27.
//

import Foundation
extension ChatViewController:DataProviderDelegate  {
    
    func received(message: MessageInfo) {
        // message.sendID receiverId 一致
        let flag1 = message.sendID == dataProvider.receiverId
        if flag1 {
            let message = IMMessage.build(messageInfo: message)
            insertMessage(message)
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
    
    
}


