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


struct IMMessage:MessageType {
   
    private init(kind: MessageKind, user: IMUser, messageId: String, date: Date) {
      self.kind = kind
      self.user = user
      self.messageId = messageId
      sentDate = date
    }

    init(custom: Any?, user: IMUser, messageId: String, date: Date) {
      self.init(kind: .custom(custom), user: user, messageId: messageId, date: date)
    }

    init(text: String, user: IMUser, messageId: String, date: Date) {
      self.init(kind: .text(text), user: user, messageId: messageId, date: date)
    }

    init(attributedText: NSAttributedString, user: IMUser, messageId: String, date: Date) {
      self.init(kind: .attributedText(attributedText), user: user, messageId: messageId, date: date)
    }

    init(image: UIImage, user: IMUser, messageId: String, date: Date) {
      let mediaItem = ImageMediaItem(image: image)
      self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date)
    }

    init(imageURL: URL, user: IMUser, messageId: String, date: Date) {
      let mediaItem = ImageMediaItem(imageURL: imageURL)
      self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date)
    }

    init(thumbnail: UIImage, user: IMUser, messageId: String, date: Date) {
      let mediaItem = ImageMediaItem(image: thumbnail)
      self.init(kind: .video(mediaItem), user: user, messageId: messageId, date: date)
    }

    init(location: CLLocation, user: IMUser, messageId: String, date: Date) {
      let locationItem = CoordinateItem(location: location)
      self.init(kind: .location(locationItem), user: user, messageId: messageId, date: date)
    }

    init(emoji: String, user: IMUser, messageId: String, date: Date) {
      self.init(kind: .emoji(emoji), user: user, messageId: messageId, date: date)
    }

    init(audioURL: URL, user: IMUser, messageId: String, date: Date) {
      let audioItem = IMAudioItem(url: audioURL)
      self.init(kind: .audio(audioItem), user: user, messageId: messageId, date: date)
    }

    init(contact: IMContactItem, user: IMUser, messageId: String, date: Date) {
      self.init(kind: .contact(contact), user: user, messageId: messageId, date: date)
    }

    init(linkItem: LinkItem, user: IMUser, messageId: String, date: Date) {
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
    
    
}



struct IMUser: SenderType, Equatable {
  var senderId: String
  var displayName: String
}


// MARK: - CoordinateItem

private struct CoordinateItem: LocationItem {
  var location: CLLocation
  var size: CGSize

  init(location: CLLocation) {
    self.location = location
    size = CGSize(width: 240, height: 240)
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
    size = CGSize(width: 240, height: 240)
    placeholderImage = UIImage()
  }

  init(imageURL: URL) {
    url = imageURL
    size = CGSize(width: 240, height: 240)
    placeholderImage = UIImage(imageLiteralResourceName: "image_message_placeholder")
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
