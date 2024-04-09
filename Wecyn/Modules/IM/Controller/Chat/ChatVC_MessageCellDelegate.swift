//
//  ChatVC_MessageCellDelegate.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/22.
//

import Foundation
import MessageKit
import SKPhotoBrowser
import AVFAudio
import AVKit
import SafariServices
// MARK: MessageCellDelegate
extension ChatViewController: MessageCellDelegate {
    func didTapAvatar(in _: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
        guard
            let indexPath = messagesCollectionView.indexPath(for: cell)
        else {
            print("Failed to identify message when audio cell receive tap gesture")
            return
        }
        
        if case MessageKind.custom(let custom) = messageList[indexPath.section].kind,let fileItem = custom as? FileItem,let url = fileItem.url {
            if url.isFileURL {
                
                return
            }
            let vc  = SFSafariViewController(url: url)
            self.present(vc, animated: true)
        }
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        print("Image tapped")
        
        
        guard
            let indexPath = messagesCollectionView.indexPath(for: cell)
        else {
            print("Failed to identify message when audio cell receive tap gesture")
            return
        }
        if case MessageKind.photo(let media) = messageList[indexPath.section].kind,let imageUrl = media.url?.absoluteString {
            var photos:[SKPhoto] = []
            messageList.forEach { message in
                if case MessageKind.photo(let media) = message.kind, let imageURL = media.url?.absoluteString {
                    photos.append(SKPhoto.photoWithImageURL(imageURL))
                }
            }
            let initialPageIndex = photos.firstIndex(where: { imageUrl == $0.photoURL }) ?? 0
            let browser = SKPhotoBrowser(photos: photos, initialPageIndex: initialPageIndex)
            UIViewController.sk.getTopVC()?.present(browser, animated: true, completion: {})
        }
        
        if case MessageKind.video(let media) = messageList[indexPath.section].kind,let url = media.url {
            try? AVAudioSession.sharedInstance().setCategory(.playback)
            let controller = AVPlayerViewController()
            let player = AVPlayer(url: url)
            player.playImmediately(atRate: 1)
            controller.player = player
            UIViewController.sk.getTopVC()?.present(controller, animated: true)
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
        
        self.showAlert(title: "重发该消息".innerLocalized(), message: nil,buttonTitles: ["取消".innerLocalized(),"重发".innerLocalized()],highlightedButtonIndex: 1) { idx in
            if idx == 1 {
                
            }
        }
    }
}
