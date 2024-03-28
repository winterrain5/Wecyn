//
//  ChatViewControllerBuilder.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/26.
//

import Foundation

public struct ChatViewControllerBuilder {

    // anchorMessageID 搜索消息，跳转到聊天记录，使用。
    public func build(_ conversation: ConversationInfo, anchorID: String? = nil) -> UIViewController {
        let dataProvider = DefaultDataProvider(conversation: conversation, anchorID: anchorID)
       
        let messageViewController = ChatViewController(dataProvider: dataProvider)
        
        return messageViewController
    }
    
    public init() {}
}
