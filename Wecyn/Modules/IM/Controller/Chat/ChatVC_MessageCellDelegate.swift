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
import SwiftyJSON
// MARK: MessageCellDelegate
extension ChatViewController: MessageCellDelegate {
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
        guard
            let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView)
        else {
            print("Failed to identify message when audio cell receive tap gesture")
            return
        }
        guard let sender = message.sender as? IMUser else { return }
        let vc = ChatFriendDetailController(id: sender.senderId.int ?? 0)
        self.navigationController?.pushViewController(vc)
        
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
        if case MessageKind.custom(let custom) = messageList[indexPath.section].kind,let contact = custom as? IMContactItem {
            let vc = ChatFriendDetailController(id: contact.id)
            self.navigationController?.pushViewController(vc)
        }
        
        if case MessageKind.custom(let custom) = messageList[indexPath.section].kind,let content = (custom as? PostItem)?.content {
            guard let model = PostListModel.deserialize(from: JSON.init(parseJSON: content).dictionaryObject) else {
                return
            }
            let vc = PostDetailViewController(postId: model.id)
            self.navigationController?.pushViewController(vc)
        }
        
        //https://www.google.com/maps/search/?api=1&query=47.5951518%2C-122.3316393&query_place_id=ChIJKxjxuaNqkFQR3CK6O1HNNqY
        // "{\"name\":\"泰鑫商务中心停车场\",\"place_id\":\"ChIJ-5D9bDm3yjURocnDun6cZYY\"}"
        if case MessageKind.location(let item) = messageList[indexPath.section].kind {
            let locationItem = item as! CoordinateItem
            let json = JSON.init(parseJSON: locationItem.desc)
            let name = json["name"].string ?? ""
            let placeId = json["place_id"].string ?? ""
            guard let url = URL(string: "https://www.google.com/maps/search/?api=1&query=\(name.urlEncoded)&query_place_id=\(placeId)") else { return }
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
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
        guard
            let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView)
        else {
            print("Failed to identify message when audio cell receive tap gesture")
            return
        }
        if (message as! IMMessage).sendStatus == .sendFailure {
            let alert = UIAlertController(title: "重发该消息".innerLocalized(), message: nil, preferredStyle: .actionSheet)
            alert.addAction(title: "重发".innerLocalized(),style: .default) { _ in
                if case MessageKind.text(let text) =  message.kind {
                    self.sendText(text)
                }
                if case MessageKind.photo(let item) =  message.kind {
                    let imageMedia = item as! ImageMediaItem
                   
                }
                
                if case MessageKind.video(let item) =  message.kind {
                    
                }
                
                if case MessageKind.audio(let item) =  message.kind {
                    
                }
                
                if case MessageKind.contact(let item) =  message.kind {
                    
                }
            }
            alert.addAction(title: "取消".innerLocalized(),style: .cancel)
            
            alert.show()
            
        }
       
    }
    
    func didTapBackground(in cell: MessageCollectionViewCell) {
        self.view.endEditing(true)
    }
    
}
