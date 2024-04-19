//
//  ChatListCell.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/26.
//

import UIKit
import BadgeControl
import Localize_Swift
class ChatListCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lastMsgLabel: UILabel!
    @IBOutlet weak var avatarImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var avatarCoverView: UIView!
    var messageBadger:BadgeController!
    
    @IBOutlet weak var muteImageView: UIImageView!
    
    var model:ConversationInfo? {
        didSet {
            guard let model = model else { return }
            if model.userID == IMController.shared.currentSender.senderId {
                avatarImgView.image = R.image.file_trans()
                nameLabel.text = "文件传输助手".innerLocalized()
            } else {
                avatarImgView.kf.setImage(with: model.faceURL?.url,placeholder: UIImage(nameInBundle: "ic_avatar_01"))
                nameLabel.text = model.showName
            }
            
           
            
            if !(model.draftText?.isEmpty ?? false )  {
                lastMsgLabel.text = model.draftText
            } else {
                lastMsgLabel.attributedText = MessageHelper.getAbstructOf(conversation: model)
            }
            
            if model.latestMsgSendTime  == 0 {
                timeLabel.text = ""
            } else {
                timeLabel.text = MessageHelper.convertList(timestamp_ms: model.latestMsgSendTime)
            }
            
            contentView.backgroundColor = model.isPinned ? R.color.backgroundColor()! : .white
            
            if model.unreadCount == 0 || model.recvMsgOpt != .receive {
                messageBadger.remove(animated: false)
            } else {
                messageBadger.addOrReplaceCurrent(with: model.unreadCount.string, animated: false)
            }
            
            muteImageView.isHidden = model.recvMsgOpt == .receive
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageBadger = BadgeController(for: avatarCoverView,
                                        in: .upperRightCorner,
                                        badgeBackgroundColor: UIColor.red,
                                        badgeTextColor: UIColor.white,
                                        animation: nil,
                                        badgeHeight: 16)
        muteImageView.image = .init(nameInBundle: "chat_status_muted_icon.png")
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
