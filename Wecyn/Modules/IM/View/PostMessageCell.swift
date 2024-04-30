//
//  PostMessageCell.swift
//  Wecyn
//
//  Created by Derrick on 2024/4/23.
//


import Foundation
import MessageKit
import UIKit
import SwiftyJSON
class PostMessageCell: MessageCollectionViewCell {
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupSubviews()
    }
    
    // MARK: Internal
    
    /// The `MessageCellDelegate` for the cell.
    weak var delegate: MessageCellDelegate?
    
    /// The container used for styling and holding the message's content view.
    var messageContainerView: MessageContainerView = {
        let containerView = MessageContainerView()
        containerView.clipsToBounds = true
        containerView.layer.masksToBounds = true
        return containerView
    }()
    
    /// The top label of the cell.
    var cellTopLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    var cellBottomLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    var cellContentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    var cellImageView:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()
    
    var cellAvatarView: AvatarView = {
        let view = AvatarView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    var cellDateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .lightGray
        return label
    }()
    
    var accessoryView: UIView = UIView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellTopLabel.text = nil
        cellTopLabel.attributedText = nil
        cellBottomLabel.text = nil
        cellBottomLabel.attributedText = nil
        cellContentLabel.attributedText = nil
        cellBottomLabel.text = nil
        cellImageView.image = nil
        cellAvatarView.image = nil
        cellDateLabel.text = nil
        accessoryView.removeSubviews()
    }
    
    /// Handle tap gesture on contentView and its subviews.
    override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: self)
        switch true {
        case messageContainerView.frame
          .contains(touchLocation) && !cellContentView(canHandle: convert(touchLocation, to: messageContainerView)):
          delegate?.didTapMessage(in: self)
        case cellAvatarView.frame.contains(touchLocation):
          delegate?.didTapAvatar(in: self)
        case accessoryView.frame.contains(touchLocation):
            delegate?.didTapAccessoryView(in: self)
        default:
          delegate?.didTapBackground(in: self)
        }
    }
    
    /// Handle long press gesture, return true when gestureRecognizer's touch point in `messageContainerView`'s frame
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let touchPoint = gestureRecognizer.location(in: self)
        guard gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) else { return false }
        return messageContainerView.frame.contains(touchPoint)
    }
    
    func setupSubviews() {
        messageContainerView.layer.cornerRadius = 5
        
        contentView.addSubview(messageContainerView)
        messageContainerView.addSubview(cellTopLabel)
        messageContainerView.addSubview(cellBottomLabel)
        messageContainerView.addSubview(cellImageView)
        messageContainerView.addSubview(cellContentLabel)
        contentView.addSubview(cellDateLabel)
        contentView.addSubview(cellAvatarView)
        contentView.addSubview(accessoryView)
        cellAvatarView.setCorner(radius: 15)
    }
    
    func configure(
        with message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView,
        dataSource: MessagesDataSource,
        and sizeCalculator: PostMessageLayoutSizeCalculator)
    {
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            return
        }
        
        let fromCurrentSender = dataSource
            .isFromCurrentSender(message: message)
        cellTopLabel.frame = sizeCalculator.cellTopLabelFrame(
            for: message,
            at: indexPath)
        cellBottomLabel.frame = sizeCalculator.cellMessageBottomLabelFrame(
            for: message,
            at: indexPath)
        cellImageView.frame = sizeCalculator.cellImageViewFrame(for: message, at: indexPath,fromCurrentSender: fromCurrentSender)
        messageContainerView.frame = sizeCalculator.messageContainerFrame(
            for: message,
            at: indexPath,
            fromCurrentSender: fromCurrentSender)
        cellContentLabel.frame = sizeCalculator.cellContetFrame(for: message, at: indexPath)
        cellDateLabel.frame = CGRect(x: 0, y: 0, width: sizeCalculator.messagesLayout.itemWidth, height: sizeCalculator.cellDateHeight)
        cellAvatarView.frame = sizeCalculator.cellAvatarFrame(for: message, at: indexPath, fromCurrentSender: fromCurrentSender)
        accessoryView.frame = sizeCalculator.accessoryViewFrame(for: message, at: indexPath, fromCurrentSender: fromCurrentSender)
        
        let message = dataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case MessageKind.custom(let custom) = message.kind,let content = (custom as? PostItem)?.content {
            guard let model = PostListModel.deserialize(from: JSON.init(parseJSON: content).dictionaryObject) else {
                return
            }
            let name = model.user.full_name
            let date = model.create_time
            let avatar = model.user.avatar
            let content = model.content
            if fromCurrentSender {
                let topLabelAttr = NSMutableAttributedString(string: name)
                topLabelAttr.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: name.count))
              
                let bottomLabelAttr = NSMutableAttributedString(string: date)
                bottomLabelAttr.addAttribute(.foregroundColor, value: UIColor.white.withAlphaComponent(0.8), range: NSRange(location: 0, length: date.count))
                
                let contentLabelAttr = NSMutableAttributedString(string: content)
                contentLabelAttr.addAttribute(.foregroundColor, value: UIColor.white.withAlphaComponent(0.8), range: NSRange(location: 0, length: content.count))
                
                
                cellTopLabel.attributedText = topLabelAttr
                cellBottomLabel.attributedText = bottomLabelAttr
                cellContentLabel.attributedText = contentLabelAttr
                
            } else {
                let topLabelAttr = NSMutableAttributedString(string: name)
                topLabelAttr.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: name.count))
                
                let bottomLabelAttr = NSMutableAttributedString(string: date)
                bottomLabelAttr.addAttribute(.foregroundColor, value: UIColor.lightGray, range: NSRange(location: 0, length: date.count))
                
                let contentLabelAttr = NSMutableAttributedString(string: content)
                contentLabelAttr.addAttribute(.foregroundColor, value: UIColor.lightGray, range: NSRange(location: 0, length: content.count))
                
                cellTopLabel.attributedText = topLabelAttr
                cellBottomLabel.attributedText = bottomLabelAttr
                cellContentLabel.attributedText = contentLabelAttr
                
            }
            cellImageView.kf.setImage(with: avatar.url,placeholder: R.image.proile_user())
            cellDateLabel.attributedText = dataSource.cellTopLabelAttributedText(for: message, at: indexPath)
        }
        
        displayDelegate.configureAvatarView(cellAvatarView, for: message, at: indexPath, in: messagesCollectionView)
        displayDelegate.configureAccessoryView(accessoryView, for: message, at: indexPath, in: messagesCollectionView)
        
        messageContainerView.backgroundColor = displayDelegate.backgroundColor(
            for: message,
            at: indexPath,
            in: messagesCollectionView)
        messageContainerView.style = displayDelegate.messageStyle(for: message, at: indexPath, in: messagesCollectionView)
    }
    
    /// Handle `ContentView`'s tap gesture, return false when `ContentView` doesn't needs to handle gesture
    func cellContentView(canHandle _: CGPoint) -> Bool {
        false
    }
    
}


class PostMessageLayoutSizeCalculator: CellSizeCalculator {
    // MARK: Lifecycle
    
    init(layout: MessagesCollectionViewFlowLayout? = nil) {
        super.init()
        
        self.layout = layout
    }
    
    // MARK: Internal
    var cellMessageContainerWidth: CGFloat {
        messagesLayout.itemWidth * 0.7
    }
    var cellTopLabelVerticalPadding: CGFloat = 32
    var cellTopLabelHorizontalPadding: CGFloat = 32

    var cellBottomLabelHorizontalPadding: CGFloat = 32
    var cellBottomLabelBottomPadding: CGFloat = 8
    var cellImageViewWidth: CGFloat = 50
    var cellImageViewHorizontalPadding:CGFloat = 16
    var cellAvatarViewWidth: CGFloat = 30
    var cellAvatarViewHorizontalPadding: CGFloat = 8
    var cellDateHeight:CGFloat = 20
    var messageBottomPadding: CGFloat = 8
    
    var messagesLayout: MessagesCollectionViewFlowLayout {
        layout as! MessagesCollectionViewFlowLayout
    }
    

    var messagesDataSource: MessagesDataSource {
        self.messagesLayout.messagesDataSource
    }
    
    override func sizeForItem(at indexPath: IndexPath) -> CGSize {
        let dataSource = messagesDataSource
        let message = dataSource.messageForItem(
            at: indexPath,
            in: messagesLayout.messagesCollectionView)
        let itemHeight = messageContainerSize(for: message, at: indexPath).height + cellDateHeight + messageBottomPadding
       
        return CGSize(
            width: messagesLayout.itemWidth,
            height: itemHeight)
    }
    
  
    // MARK: - Top cell Label
    
    func cellTopLabelSize(
        for message: MessageType,
        at indexPath: IndexPath)
    -> CGSize
    {
        if case MessageKind.custom(let custom) = message.kind {
            if let _ = custom as? PostItem {

                let maxWidth = cellMessageContainerWidth - cellTopLabelHorizontalPadding - cellImageViewHorizontalPadding - cellImageViewWidth
                
                return CGSize(
                    width: maxWidth,
                    height: 20)
            }
        }
        return .zero
        
    }
    
    func cellTopLabelFrame(
        for message: MessageType,
        at indexPath: IndexPath)
    -> CGRect
    {
        let size = cellTopLabelSize(
            for: message,
            at: indexPath)
        guard size != .zero else {
            return .zero
        }
        
        let origin = CGPoint(
            x: cellImageViewWidth + cellTopLabelHorizontalPadding / 2 + cellImageViewHorizontalPadding,
            y: cellTopLabelVerticalPadding / 2)
        
        return CGRect(
            origin: origin,
            size: size)
    }
    
    func cellMessageBottomLabelSize(
        for message: MessageType,
        at indexPath: IndexPath)
    -> CGSize
    {
     
        if case MessageKind.custom(let custom) = message.kind {
            if let _ = custom as? PostItem {
                let maxWidth = cellMessageContainerWidth - cellTopLabelHorizontalPadding - cellImageViewHorizontalPadding - cellImageViewWidth
                return CGSize(
                    width: maxWidth,
                    height: 20)
            }
        }
        return .zero

    }
    
    func cellMessageBottomLabelFrame(
        for message: MessageType,
        at indexPath: IndexPath)
    -> CGRect
    {
  
        let topLabelSize = cellTopLabelSize(
            for: message,
            at: indexPath)
        
        let bottomLabelSizze = cellMessageBottomLabelSize(for: message, at: indexPath)
        let x = cellImageViewWidth + cellTopLabelHorizontalPadding
        let y = topLabelSize.height + cellTopLabelVerticalPadding / 2 + cellBottomLabelBottomPadding
        let origin = CGPoint(
            x: x,
            y: y)
        
        return CGRect(
            origin: origin,
            size: bottomLabelSizze)
    }
    
    func cellImageViewFrame(for message: MessageType, at indexPath:IndexPath,fromCurrentSender: Bool) -> CGRect {
        
        let x = cellTopLabelHorizontalPadding / 2
        let y = cellImageViewHorizontalPadding
        let origin = CGPoint(
            x: x,
            y: y)
        
        return CGRect(
            origin: origin,
            size: CGSize(width: cellImageViewWidth, height: cellImageViewWidth))
    }
    
    func cellAvatarSize() -> CGSize {
        return CGSize(width: 30, height: 30)
    }
    
    func cellAvatarFrame(for message: MessageType,
                          at indexPath: IndexPath,
                         fromCurrentSender: Bool) -> CGRect {
        
        let frame = messageContainerFrame(for: message, at: indexPath, fromCurrentSender: fromCurrentSender)
        let avatarSize = cellAvatarSize()
        let origin: CGPoint
        if fromCurrentSender {
            let x = frame.maxX + cellAvatarViewHorizontalPadding / 2
            origin = CGPoint(x: x, y: cellDateHeight)
        } else {
            origin = CGPoint(x: 0, y: cellDateHeight)
        }
        
        return CGRect(origin: origin, size: avatarSize)
    }
    
    
    func cellContentSize(for message: MessageType,
                         at indexPath: IndexPath) -> CGSize {
        if case MessageKind.custom(let custom) = message.kind {
            let content = (custom as? PostItem)?.content ?? ""
            guard let model = PostListModel.deserialize(from: JSON.init(parseJSON: content).dictionaryObject) else {
                return .zero
            }
            let maxWidth = cellMessageContainerWidth - cellTopLabelHorizontalPadding
            let size = NSAttributedString(string: model.content).size(consideringWidth: maxWidth)
            let height = ceil(size.height) >= 28 ? 40 : size.height
            return CGSize(width: maxWidth, height: height)
        }
        return .zero
    }
    
    func cellContetFrame(for message: MessageType,
                         at indexPath: IndexPath) -> CGRect{
        let y = cellImageViewWidth + cellTopLabelVerticalPadding
        let origin = CGPoint(x: cellImageViewHorizontalPadding, y: y)
        let size = cellContentSize(for: message, at: indexPath)
        return CGRect(origin: origin, size: size)
    }
    
    // MARK: - MessageContainer
    
    func messageContainerSize(
        for message: MessageType,
        at indexPath: IndexPath)
    -> CGSize
    {
        let contentSize = cellContentSize(for: message, at: indexPath)
        
        let width = cellMessageContainerWidth
             
        let height = cellImageViewWidth + cellImageViewHorizontalPadding * 3 + contentSize.height
   
        return CGSize(
            width: width,
            height: height)
    }
    
    func messageContainerFrame(
        for message: MessageType,
        at indexPath: IndexPath,
        fromCurrentSender: Bool)
    -> CGRect
    {
        let y = cellDateHeight
        let size = messageContainerSize(
            for: message,
            at: indexPath)
        let origin: CGPoint
        if fromCurrentSender {
            let x = messagesLayout.itemWidth - cellAvatarViewWidth - cellAvatarViewHorizontalPadding - size.width + 4
            origin = CGPoint(x: x, y: y)
        } else {
            let x = cellAvatarViewWidth + cellAvatarViewHorizontalPadding / 2
            origin = CGPoint(x: x, y: y)
        }
        
        return CGRect(
            origin: origin,
            size: size)
    }
    
    func accessoryViewFrame(
        for message: MessageType,
        at indexPath: IndexPath,
        fromCurrentSender: Bool) -> CGRect {
            
            let messageFrame = messageContainerFrame(for: message, at: indexPath, fromCurrentSender: fromCurrentSender)
            let rect: CGRect
            if fromCurrentSender {
                let size = CGSize(width: 30, height: 30)
                let origin = CGPoint(x: messageFrame.minX - 38, y: messageFrame.center.y)
                rect = CGRect(origin: origin, size: size)
            } else {
                rect = .zero
            }
            return rect
        }
}

