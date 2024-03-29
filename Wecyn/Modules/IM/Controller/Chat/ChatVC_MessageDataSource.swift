//
//  ChatVC_MessageDataSource.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/22.
//

import Foundation
import MessageKit
// MARK: MessagesDataSource
extension ChatViewController:  MessagesDataSource {
 
    
    func currentSender() -> any SenderType {
        IMController.shared.currentSender
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in _: MessagesCollectionView) -> MessageType {
        messageList[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section >= 1 && messageList.count >= 2{
            
            var attr:NSAttributedString?
            let last = messageList[indexPath.section]
            
            let pre = messageList[indexPath.section-1]
            
            let distance = pre.sentDate.distance(to: last.sentDate)
            if distance > 60 * 30  {
                attr = NSAttributedString(
                    string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                    attributes: [
                        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                        NSAttributedString.Key.foregroundColor: UIColor.lightGray,
                    ])
            }
            return attr
            
        }
        return nil
    }
    
    func cellBottomLabelAttributedText(for _: MessageType, at _: IndexPath) -> NSAttributedString? {
        NSAttributedString(
            string: "Read",
            attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                NSAttributedString.Key.foregroundColor: UIColor.darkGray,
            ])
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(
            string: name,
            attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at _: IndexPath) -> NSAttributedString? {
//        let dateString = self.formatter.string(from: message.sentDate)
//        return NSAttributedString(
//            string: dateString,
//            attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
        return nil
    }
    
    func textCell(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UICollectionViewCell? {
        nil
    }
    
    
}