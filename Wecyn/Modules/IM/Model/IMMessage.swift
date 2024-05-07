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
    
    init(kind: MessageKind, user: IMUser, messageId: String, date: Date) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        sentDate = date
    }
    
    static func build(messageInfo:MessageInfo) -> IMMessage?{
        
        let date = Date.init(unixTimestamp: messageInfo.sendTime / 1000)
        
        
        let currendUser = IMController.shared.currentSender
        var sender:IMUser!
        if messageInfo.sendID == currendUser.senderId {
            sender = currendUser
        } else {
            sender = IMUser(senderId: messageInfo.sendID, displayName: messageInfo.senderNickname ?? "",faceUrl: messageInfo.senderFaceUrl ?? "")
        }
        let messageId = messageInfo.clientMsgID
        
        switch messageInfo.contentType {
        case .text:
            
            let text = messageInfo.textElem?.content ?? ""
            let message = IMMessage.init(text: text, user: sender, messageId: messageId, date: date)
            message.sendStatus = messageInfo.status
            return message
            
        case .image:
            
            guard let url = messageInfo.pictureElem?.sourcePicture?.url?.url else { return nil }
            let imageSize = CGSize(width: messageInfo.pictureElem?.sourcePicture?.width ?? 180, height: messageInfo.pictureElem?.sourcePicture?.height ?? 180)
            let message = IMMessage.init(imageURL: url,imageSize:imageSize, user: sender, messageId: messageId, date: date)
            message.sendStatus = messageInfo.status
            return message
            
        case .video:
            
            guard let url = messageInfo.videoElem?.videoUrl?.url,let duration = messageInfo.videoElem?.duration.cgFloat.int else { return nil}
            let thumbnail = UIImage.init(color: R.color.backgroundColor()!, size: CGSize(width: 120, height: 160))
            let message = IMMessage.init(videoThumbnail: thumbnail, videoUrl: url, duration: duration, user: sender, messageId: messageId, date: date)
            message.sendStatus = messageInfo.status
            return message
            
        case .audio:
            
            guard let url = messageInfo.soundElem?.sourceUrl?.url,let duration = messageInfo.soundElem?.duration.float else { return nil }
            let message = IMMessage.init(audioURL: url,duration: duration, user: sender, messageId: messageId, date: date)
            message.sendStatus = messageInfo.status
            return message
            
        case .file:
            
            guard let url = messageInfo.fileElem?.sourceUrl?.url,let title = messageInfo.fileElem?.fileName,let size = messageInfo.fileElem?.fileSize else { return  nil }
            let item = FileItem(title: title, url: url,image: UIImage(nameInBundle: "msg_file"),size: size)
            let message = IMMessage(fileItem: item, user: sender, messageId: messageId, date: date)
            message.sendStatus = messageInfo.status
            return message
            
        case .card:
            
            guard let name = messageInfo.cardElem?.nickname,
                  let faceUrl = messageInfo.cardElem?.faceURL,
                  let id = messageInfo.cardElem?.userID.int,
                  let wid = messageInfo.cardElem?.ex
            else { return nil }
            let item = IMContactItem(displayName: name, faceUrl: faceUrl, id: id, wid: wid)
            let message = IMMessage(contact: item, user: sender, messageId: messageId, date: date)
            message.sendStatus = messageInfo.status
            return message
            
        case .revoke:
            
            let text:String
            if messageInfo.sendID == currendUser.senderId {
                text = "你撤回了一条消息".innerLocalized()
            } else {
                sender = IMUser(senderId: messageInfo.sendID, displayName: messageInfo.senderNickname ?? "",faceUrl: nil)
                text = (messageInfo.senderNickname ?? "")  + "撤回了一条消息".innerLocalized()
            }
            let item = RevokeItem(title: text)
            let message = IMMessage(revokeItem: item, user: sender, messageId: messageId, date: date)
            message.sendStatus = messageInfo.status
            return message
        case .location:
            guard let latitude = messageInfo.locationElem?.latitude,
                  let longitude = messageInfo.locationElem?.longitude,
                  let desc = messageInfo.locationElem?.desc
            else { return nil }
            let message = IMMessage(location: CLLocation(latitude: latitude, longitude: longitude), 
                                    desc: desc,
                                    user: sender,
                                    messageId: messageId,
                                    date: date)
            message.sendStatus = messageInfo.status
            return message
        case .friendAppApproved:
            return IMMessage(text: "我通过了您的好友验证请求，现在我们可以开始聊天了".innerLocalized(), user: sender, messageId: messageId, date: date)
            
        case .oaNotification:
            return nil
            
        case .custom:
            guard let data = messageInfo.customElem?.data?.int else { return nil }
            if data == 1 { // post
                let content = messageInfo.customElem?.ext ?? ""
                let item = PostItem(content: content)
                let message = IMMessage(postItem: item, user: sender, messageId: messageId, date: date)
                message.sendStatus = messageInfo.status
                return message
            }
            return nil
        default:
            return IMMessage(text: "\(messageInfo.contentType)", user: sender, messageId: messageId, date: date)
        }
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
    
    convenience init(videoThumbnail: UIImage,videoUrl:URL,duration:Int, user: IMUser, messageId: String, date: Date) {
        let mediaItem = VideoMediaItem(image: videoThumbnail, url: videoUrl)
        mediaItem.duration = duration
        self.init(kind: .video(mediaItem), user: user, messageId: messageId, date: date)
    }
    
    convenience init(location: CLLocation,desc:String, user: IMUser, messageId: String, date: Date) {
        let locationItem = CoordinateItem(location: location,desc: desc)
        self.init(kind: .location(locationItem), user: user, messageId: messageId, date: date)
    }
    
    convenience init(emoji: String, user: IMUser, messageId: String, date: Date) {
        self.init(kind: .emoji(emoji), user: user, messageId: messageId, date: date)
    }
    
    convenience init(audioURL: URL,duration:Float, user: IMUser, messageId: String, date: Date) {
        let audioItem = IMAudioItem(url: audioURL,duration: duration)
        self.init(kind: .audio(audioItem), user: user, messageId: messageId, date: date)
    }
    
    convenience init(contact: IMContactItem, user: IMUser, messageId: String, date: Date) {
        self.init(custom: contact, user: user, messageId: messageId, date: date)
    }
    
    convenience init(linkItem: LinkMediaItem, user: IMUser, messageId: String, date: Date) {
        self.init(kind: .linkPreview(linkItem), user: user, messageId: messageId, date: date)
    }
    
    convenience init(fileItem: FileItem, user: IMUser, messageId: String, date: Date) {
        self.init(custom: fileItem, user: user, messageId: messageId, date: date)
    }
    
    convenience init(revokeItem:RevokeItem, user: IMUser, messageId: String, date: Date) {
        self.init(custom: revokeItem, user: user, messageId: messageId, date: date)
    }
    
    convenience init(postItem:PostItem, user: IMUser, messageId: String, date: Date) {
        self.init(custom: postItem, user: user, messageId: messageId, date: date)
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
    var faceUrl: String?
}


// MARK: - CoordinateItem

struct CoordinateItem: LocationItem {
    var location: CLLocation
    var desc: String
    var size: CGSize
    
    init(location: CLLocation,desc:String) {
        self.location = location
        self.desc = desc
        size = CGSize(width: MessageMaxHeight, height: MessageMaxHeight)
    }
}

// MARK: - ImageMediaItem

struct ImageMediaItem: MediaItem {
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

struct LinkMediaItem: LinkItem {
    var text: String?
    
    var attributedText: NSAttributedString?
    
    var url: URL
    
    var title: String?
    
    var teaser: String
    
    var thumbnailImage: UIImage
    
    init(text: String? = nil, attributedText: NSAttributedString? = nil, url: URL, title: String? = nil, teaser: String, thumbnailImage: UIImage) {
        self.text = text
        self.attributedText = attributedText
        self.url = url
        self.title = title
        self.teaser = teaser
        self.thumbnailImage = thumbnailImage
    }
}

class VideoMediaItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var duration: Int?
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

struct FileItem {
    var title: String?
    var url: URL?
    var image:UIImage?
    var size:Int?
    init(title: String? = nil, url: URL? = nil, image: UIImage? = nil, size: Int? = nil) {
        self.title = title
        self.url = url
        self.image = image
        self.size = size
    }
}

struct RevokeItem {
    var title: String?
    init(title: String? = nil) {
        self.title = title
    }
}

struct PostItem {
    var content: String?
    init(content: String? = nil) {
        self.content = content
    }
}


// MARK: - MockAudioItem

struct IMAudioItem: AudioItem {
    var url: URL
    var size: CGSize
    var duration: Float
    
    init(url: URL,duration: Float) {
        self.url = url
        size = CGSize(width: 160, height: 35)
        self.duration = duration
    }
}

// MARK: - MockContactItem

struct IMContactItem {
    var displayName: String
    var faceUrl: String?
    var id: Int
    var wid: String
    init(displayName: String, faceUrl: String?, id: Int, wid: String) {
        self.displayName = displayName
        self.faceUrl = faceUrl
        self.id = id
        self.wid = wid
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
    var ext: String?
    var name: String?
    var id: Int?
    var wid: String?
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
