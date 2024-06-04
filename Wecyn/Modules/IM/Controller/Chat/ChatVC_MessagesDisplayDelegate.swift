//
//  ChatVC_MessagesDisplayDelegate.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/22.
//

import Foundation
import MessageKit
import MapKit
import Kingfisher
// MARK: MessagesDisplayDelegate
extension ChatViewController:MessagesDisplayDelegate {
    func textColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and _: MessageType, at _: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
        default: return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> [DetectorType] {
        [.url, .address, .transitInformation, .mention, .hashtag]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
        if case MessageKind.photo(_) = message.kind {
            return R.color.backgroundColor()!
        }
        return isFromCurrentSender(message: message) ? R.color.theamColor()! : UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .topRight : .topLeft
        return .bubbleTail(tail, .pointedEdge)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at index: IndexPath, in _: MessagesCollectionView) {
        if messageList.count > 0 {
         
//            let avatar = Avatar(image: )
//            avatarView.set(avatar: avatar)
            let url = messageList[index.section].user.faceUrl?.url
            let placeholderImage = UIImage(nameInBundle: "ic_avatar_01")
            KF.url(url)
              .placeholder(placeholderImage)
              .loadDiskFileSynchronously()
              .cacheMemoryOnly()
              .fade(duration: 0.25)
              .set(to: avatarView)
        }
       
    }
    
    func configureMediaMessageImageView(
        _ imageView: UIImageView,
        for message: MessageType,
        at _: IndexPath,
        in _: MessagesCollectionView)
    {
        if case MessageKind.photo(let media) = message.kind, let imageURL = media.url {
            imageView.kf.setImage(with: imageURL)
        } else if case MessageKind.video(let media) = message.kind,let videoURL = media.url {
            getVideoThumbnaiImage(videoURL) { image in
                imageView.image = image
                (media as! VideoMediaItem).image = image
            }
        } else {
            imageView.kf.cancelDownloadTask()
        }
    }
    
    // MARK: - Location Messages
    
    func annotationViewForLocation(message _: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = R.image.pin()!
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    func animationBlockForLocation(
        message _: MessageType,
        at _: IndexPath,
        in _: MessagesCollectionView) -> ((UIImageView) -> Void)?
    {
        { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            UIView.animate(
                withDuration: 0.6,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 0,
                options: [],
                animations: {
                    view.layer.transform = CATransform3DIdentity
                },
                completion: nil)
        }
    }
    
    func snapshotOptionsForLocation(
        message _: MessageType,
        at _: IndexPath,
        in _: MessagesCollectionView)
    -> LocationMessageSnapshotOptions
    {
        LocationMessageSnapshotOptions(
            showsBuildings: true,
            showsPointsOfInterest: true,
            span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
    }
    
    // MARK: - Audio Messages
    
    func audioTintColor(for message: MessageType, at _: IndexPath, in _: MessagesCollectionView) -> UIColor {
        isFromCurrentSender(message: message) ? .white : UIColor(red: 15 / 255, green: 135 / 255, blue: 255 / 255, alpha: 1.0)
    }
    
    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        audioController
            .configureAudioCell(
                cell,
                message: message) // this is needed especially when the cell is reconfigure while is playing sound
    }
    
    func configureAccessoryView(_ accessoryView: UIView, for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        accessoryView.subviews.forEach { $0.removeFromSuperview() }
        
        guard messageList.count > 0 else { return }
        let message = messageList[indexPath.section]
 
        if message.sendStatus == .sending{
            let indictor = UIActivityIndicatorView(style: .medium)
            indictor.tintColor = .lightGray
            accessoryView.addSubview(indictor)
            indictor.frame = accessoryView.bounds
            indictor.startAnimating()
        } else  if message.sendStatus  == .sendFailure {
            let image = UIImageView(image: UIImage.init(systemName: "exclamationmark.circle.fill")?.tintImage(.red))
            accessoryView.addSubview(image)
            image.frame = accessoryView.bounds
        }  else {
            accessoryView.subviews.forEach { $0.removeFromSuperview() }
        }

    }
    
 
    
    func getVideoThumbnaiImage(_ video:URL,complete:@escaping (UIImage?)->()) {
        if let image = MessageImageCache.shared.getImage(for: video.absoluteString)  {
            complete(image)
            return
        }
        var image:UIImage?
        Asyncs.async(task: {
            image = video.thumbnail()?.rotateImageByOrientation()
        }, mainTask: {
            if let image = image {
                MessageImageCache.shared.setImage(image: image, key: video.absoluteString)
            }
            complete(image)
        })
    }
}
