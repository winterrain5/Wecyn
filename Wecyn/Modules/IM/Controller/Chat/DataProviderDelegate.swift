//
//  DataProviderDelegate.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/26.
//

import Foundation
protocol DataProviderDelegate: AnyObject {

    func received(message: MessageInfo)
    
    func typingStateChanged(to state: TypingState)

    func lastReadIdsChanged(to ids: [String], readUserID: String?)

    func lastReceivedIdChanged(to id: String)
    
    func isInGroup(with isIn: Bool)
    
    func isRevokeMessage(revoke: MessageRevoked)
}
enum TypingState {

    case idle

    case typing

}
