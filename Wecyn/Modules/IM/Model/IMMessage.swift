//
//  File.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/22.
//

import AVFoundation
import CoreLocation
import Foundation
import MessageKit
import UIKit
import Cache


let MessageMaxHeight = 180.cgFloat

class IMMessage:MessageType {
    
    private init(kind: MessageKind, user: IMUser, messageId: String, date: Date) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        sentDate = date
    }
    
    static func build(messageInfo:MessageInfo) -> IMMessage?{
        
        let date = Date.init(unixTimestamp: messageInfo.sendTime / 1000)
        let messageId = messageInfo.seq.string
        
        let currendUser = IMController.shared.currentSender
        var sender:IMUser!
        if messageInfo.sendID == currendUser.senderId {
            sender = currendUser
        } else {
            sender = IMUser(senderId: messageInfo.sendID, displayName: messageInfo.senderNickname ?? "",faceUrl: messageInfo.senderFaceUrl ?? "")
        }
        
        
        switch messageInfo.contentType {
        case .text:
            let text = messageInfo.textElem?.content ?? ""
            return IMMessage.init(text: text, user: sender, messageId: messageId, date: date)
        case .image:
            guard let url = messageInfo.pictureElem?.sourcePicture?.url?.url else { return nil }
            let imageSize = CGSize(width: messageInfo.pictureElem?.sourcePicture?.width ?? 180, height: messageInfo.pictureElem?.sourcePicture?.height ?? 180)
            return IMMessage.init(imageURL: url,imageSize:imageSize, user: sender, messageId: messageId, date: date)
//        case .video:
//            
//            guard let url = messageInfo.videoElem?.videoUrl?.url else { return nil}
//            let thumbnail = getVideoThumbnaiImage(url.absoluteString)
//            return IMMessage.init(videoThumbnail: thumbnail, videoUrl: url, user: sender, messageId: messageId, date: date)
            
        case .file:
            
            return IMMessage(text: "\(messageInfo.contentType)", user: sender, messageId: messageId, date: date)
        case .friendAppApproved:
            return IMMessage(text: "我通过了您的好友验证请求，现在我们可以开始聊天了".innerLocalized(), user: sender, messageId: messageId, date: date)
        default:
            return IMMessage(text: "\(messageInfo.contentType)", user: sender, messageId: messageId, date: date)
        }
    }
    
    static func getVideoThumbnaiImage(_ video:String) -> UIImage {
        if let image = MessageImageCache.shared.getImage(for: video) {
            return image
        }
        let image = video.url?.thumbnail()
        if let image = image {
            PostImageCache.shared.setImage(image: image, key: video)
        }
        return image ?? UIImage()
        
    }
    
    convenience init(custom: Any?, user: IMUser, messageId: String, date: Date) {
        self.init(kind: .custom(custom), user: user, messageId: messageId, date: date)
    }
    
    convenience init(text: String, user: IMUser, messageId: String, date: Date) {
        self.init(kind: .text(text), user: user, messageId: messageId, date: date)
    }
    
    convenience init(attributedText: NSAttributedString, user: IMUser, messageId: String, date: Date) {
        self.init(kind: .attributedText(attributedText), user: user, messageId: messageId, date: date)
    }
    
    convenience init(image: UIImage, user: IMUser, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date)
    }
    
    convenience init(imageURL: URL,imageSize: CGSize, user: IMUser, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(imageURL: imageURL,imageSize: imageSize)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date)
    }
    
    convenience init(thumbnail: UIImage, user: IMUser, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: thumbnail)
        self.init(kind: .video(mediaItem), user: user, messageId: messageId, date: date)
    }
    
    convenience init(videoThumbnail: UIImage,videoUrl:URL, user: IMUser, messageId: String, date: Date) {
        let mediaItem = VideoMediaItem(image: videoThumbnail, url: videoUrl)
        self.init(kind: .video(mediaItem), user: user, messageId: messageId, date: date)
    }
    
    convenience init(location: CLLocation, user: IMUser, messageId: String, date: Date) {
        let locationItem = CoordinateItem(location: location)
        self.init(kind: .location(locationItem), user: user, messageId: messageId, date: date)
    }
    
    convenience init(emoji: String, user: IMUser, messageId: String, date: Date) {
        self.init(kind: .emoji(emoji), user: user, messageId: messageId, date: date)
    }
    
    convenience init(audioURL: URL, user: IMUser, messageId: String, date: Date) {
        let audioItem = IMAudioItem(url: audioURL)
        self.init(kind: .audio(audioItem), user: user, messageId: messageId, date: date)
    }
    
    convenience init(contact: IMContactItem, user: IMUser, messageId: String, date: Date) {
        self.init(kind: .contact(contact), user: user, messageId: messageId, date: date)
    }
    
    convenience init(linkItem: LinkItem, user: IMUser, messageId: String, date: Date) {
        self.init(kind: .linkPreview(linkItem), user: user, messageId: messageId, date: date)
    }
    
    // MARK: Internal
    var user: IMUser
    
    var sender: any MessageKit.SenderType {
        return user
    }
    
    var messageId: String
    
    var sentDate: Date
    
    var kind: MessageKit.MessageKind
    
    var sendStatus:MessageStatus = .undefine
}



struct IMUser: SenderType, Equatable {
    var senderId: String
    var displayName: String
    var faceUrl: String
}


// MARK: - CoordinateItem

private struct CoordinateItem: LocationItem {
    var location: CLLocation
    var size: CGSize
    
    init(location: CLLocation) {
        self.location = location
        size = CGSize(width: MessageMaxHeight, height: MessageMaxHeight)
    }
}

// MARK: - ImageMediaItem

private struct ImageMediaItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage) {
        self.image = image
        let scale = image.size.width / image.size.height
        let width = image.size.width >= MessageMaxHeight ? MessageMaxHeight * scale : image.size.width
        let height = image.size.height >= MessageMaxHeight ? MessageMaxHeight : image.size.height
        size = CGSize(width: width, height: height)
        placeholderImage = UIImage()
    }
    
    init(imageURL: URL,imageSize:CGSize) {
        url = imageURL
        let scale = imageSize.width / imageSize.height
        let width = imageSize.width >= MessageMaxHeight ? MessageMaxHeight * scale : imageSize.width
        let height = imageSize.height >= MessageMaxHeight ? MessageMaxHeight : imageSize.height
        size = CGSize(width: width, height: height)
        placeholderImage = UIImage(imageLiteralResourceName: "image_message_placeholder")
    }
}

private struct VideoMediaItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage,url: URL) {
        self.image = image
        self.url = url
        let scale = image.size.width / image.size.height
        let width = image.size.width >= MessageMaxHeight ? MessageMaxHeight * scale : image.size.width
        let height = image.size.height >= MessageMaxHeight ? MessageMaxHeight : image.size.height
        size = CGSize(width: width, height: height)
        placeholderImage = UIImage()
    }
}



// MARK: - MockAudioItem

private struct IMAudioItem: AudioItem {
    var url: URL
    var size: CGSize
    var duration: Float
    
    init(url: URL) {
        self.url = url
        size = CGSize(width: 160, height: 35)
        // compute duration
        let audioAsset = AVURLAsset(url: url)
        duration = Float(CMTimeGetSeconds(audioAsset.duration))
    }
}

// MARK: - MockContactItem

struct IMContactItem: ContactItem {
    var displayName: String
    var initials: String
    var phoneNumbers: [String]
    var emails: [String]
    
    init(name: String, initials: String, phoneNumbers: [String] = [], emails: [String] = []) {
        displayName = name
        self.initials = initials
        self.phoneNumbers = phoneNumbers
        self.emails = emails
    }
}


struct MediaMessageSource: Hashable {
    
    struct Info: Hashable {
        var url: URL!
        var relativePath: String?
    }
    
    var image: UIImage?
    var source: Info
    var thumb: Info?
    var duration: Int?
    var size:Int?
}


class MessageImageCache {
    static let shared = MessageImageCache()
    var storage:Storage<String,Image>?
    init() {
        let diskConfig = DiskConfig(name: "Message",expiry: .seconds(7 * 24 * 60 * 60))
        let memoryConfig = MemoryConfig(expiry: .never, countLimit: 100, totalCostLimit: 100)
        storage = try? Storage<String, Image>(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forImage())
    }
    
    func setImage(image:Image,key:String) {
        try? storage?.setObject(image, forKey: key)
    }
    func getImage(for key:String) -> Image?{
        try? storage?.object(forKey: key)
    }
}
