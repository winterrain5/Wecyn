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
       return nil
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
    
    func customCell(for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell {
        if case MessageKind.custom(let custom) = message.kind {
            if custom is FileItem {
                let cell = messagesCollectionView.dequeueReusableCell(
                  FileMessageCell.self,
                  for: indexPath)
                cell.configure(
                  with: message,
                  at: indexPath,
                  in: messagesCollectionView,
                  dataSource: self,
                  and: fileMessageSizeCalculator)
                cell.delegate = self
                return cell
            }
            if custom is IMContactItem {
                let cell = messagesCollectionView.dequeueReusableCell(
                  CustomContactMessageCell.self,
                  for: indexPath)
                cell.configure(
                  with: message,
                  at: indexPath,
                  in: messagesCollectionView,
                  dataSource: self,
                  and: contactMessageSizeCalculator)
                cell.delegate = self
                return cell
            }
            if custom is RevokeItem {
                let cell = messagesCollectionView.dequeueReusableCell(
                  RevokeMessageCell.self,
                  for: indexPath)
                cell.configure(
                  with: message,
                  at: indexPath,
                  in: messagesCollectionView,
                  dataSource: self,
                  and: revokeMessageSizeCalculator)
                cell.delegate = self
                return cell
            }
            if custom is PostItem {
                let cell = messagesCollectionView.dequeueReusableCell(
                  PostMessageCell.self,
                  for: indexPath)
                cell.configure(
                  with: message,
                  at: indexPath,
                  in: messagesCollectionView,
                  dataSource: self,
                  and: postMessageSizeCalculator)
                cell.delegate = self
                return cell
            }
        }
       return UICollectionViewCell()
    }
    
    
}
