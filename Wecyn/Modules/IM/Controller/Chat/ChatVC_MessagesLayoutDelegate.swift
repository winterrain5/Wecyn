//
//  ChatVC_MessagesLayoutDelegate.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/22.
//

import Foundation
import MessageKit
// MARK: MessagesLayoutDelegate
extension ChatViewController:MessagesLayoutDelegate {
    
    func customCellSizeCalculator(for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CellSizeCalculator {
        if case MessageKind.custom(let custom) = message.kind {
            if custom is FileItem {
                 return fileMessageSizeCalculator
            }
            if custom is IMContactItem {
                return contactMessageSizeCalculator
            }
            if custom is RevokeItem {
                return revokeMessageSizeCalculator
            }
            if custom is PostItem {
                return postMessageSizeCalculator
            }
        }
        return CellSizeCalculator()
    }

    func textCellSizeCalculator(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CellSizeCalculator? {
      nil
    }
    func cellTopLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
      20
    }

    func cellBottomLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
      0
    }

    func messageTopLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
      0
    }

    func messageBottomLabelHeight(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> CGFloat {
      8
    }
    
   
}
