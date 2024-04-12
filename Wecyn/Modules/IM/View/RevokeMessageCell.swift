//
//  RevokeMessageCell.swift
//  Wecyn
//
//  Created by Derrick on 2024/4/11.
//

import Foundation
import MessageKit

class RevokeMessageCell:MessageCollectionViewCell {
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
    
    var cellLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    
    func setupSubviews() {
        contentView.addSubview(cellLabel)
    }
    
    func configure(
        with message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView,
        dataSource: MessagesDataSource,
        and sizeCalculator: RevokeMessageLayoutSizeCalculator)
    {
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            return
        }
        
        let fromCurrentSender = dataSource
            .isFromCurrentSender(message: message)
        cellLabel.frame = contentView.bounds
        
        
        let message = dataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        if case MessageKind.custom(let custom) = message.kind,let revoke = custom as? RevokeItem {
            cellLabel.text = revoke.title
        }
        

    }
    
    /// Handle `ContentView`'s tap gesture, return false when `ContentView` doesn't needs to handle gesture
    func cellContentView(canHandle _: CGPoint) -> Bool {
        false
    }
}
class RevokeMessageLayoutSizeCalculator: CellSizeCalculator {
    // MARK: Lifecycle
    
    init(layout: MessagesCollectionViewFlowLayout? = nil) {
        super.init()
        
        self.layout = layout
    }
    var messagesLayout: MessagesCollectionViewFlowLayout {
        layout as! MessagesCollectionViewFlowLayout
    }
    
    var messagesDataSource: MessagesDataSource {
        self.messagesLayout.messagesDataSource
    }
    override func sizeForItem(at indexPath: IndexPath) -> CGSize {
        let dataSource = messagesDataSource
       
       
        return CGSize(
            width: messagesLayout.itemWidth,
            height: 40)
    }
    
    
}
