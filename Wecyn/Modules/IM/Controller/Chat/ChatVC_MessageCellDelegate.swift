//
//  ChatVC_MessageCellDelegate.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/22.
//

import Foundation
import MessageKit
import SKPhotoBrowser
// MARK: MessageCellDelegate
extension ChatViewController: MessageCellDelegate {
    func didTapAvatar(in _: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in _: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        print("Image tapped")
        guard
            let indexPath = messagesCollectionView.indexPath(for: cell),
            let mediaCell = messagesCollectionView.cellForItem(at: indexPath) as? MediaMessageCell
        else {
            print("Failed to identify message when audio cell receive tap gesture")
            return
        }
        var photos:[SKPhoto] = []
        messageList.forEach { message in
            if case MessageKind.photo(let media) = message.kind, let imageURL = media.url?.absoluteString {
                photos.append(SKPhoto.photoWithImageURL(imageURL))
            }
        }
        if case MessageKind.photo(let media) = messageList[indexPath.section].kind,let imageUrl = media.url?.absoluteString {
            let initialPageIndex = photos.firstIndex(where: { imageUrl == $0.photoURL }) ?? 0
            let browser = SKPhotoBrowser(photos: photos, initialPageIndex: initialPageIndex)
            UIViewController.sk.getTopVC()?.present(browser, animated: true, completion: {})
        }
        
        
        
    }
    
    func didTapCellTopLabel(in _: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapCellBottomLabel(in _: MessageCollectionViewCell) {
        print("Bottom cell label tapped")
    }
    
    func didTapMessageTopLabel(in _: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in _: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard
            let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView)
        else {
            print("Failed to identify message when audio cell receive tap gesture")
            return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }
    
    func didStartAudio(in _: AudioMessageCell) {
        print("Did start playing audio sound")
    }
    
    func didPauseAudio(in _: AudioMessageCell) {
        print("Did pause audio sound")
    }
    
    func didStopAudio(in _: AudioMessageCell) {
        print("Did stop audio sound")
    }
    
    func didTapAccessoryView(in _: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }
}
