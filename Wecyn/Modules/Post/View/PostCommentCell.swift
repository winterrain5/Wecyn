//
//  PostCommentCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/18.
//

import UIKit
import Kingfisher
class PostCommentCell: UITableViewCell {
    @IBOutlet weak var avatarImgView:UIImageView!
    @IBOutlet weak var userNameLabel:UILabel!
    @IBOutlet weak var reportButton:UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var contentLabel:UILabel!
    @IBOutlet weak var likeButton: UIButton!
    var commentLikeHandler:((PostCommentModel)->())?
    var replyLikeHandler:((PostCommentReplyModel)->())?
    var commentHandler:((PostCommentModel)->())?
    var commentModel:PostCommentModel? {
        didSet {
            guard let model = commentModel else { return }
            avatarImgView.kf.setImage(with: model.user.avatar.url)
            userNameLabel.text = model.user.full_name + " · " + model.post_time
            
            contentLabel.text = model.content
            
            likeButton.imageForNormal = model.liked ? R.image.post_comment_like()! : R.image.post_comment_unlike()!
            likeButton.titleForNormal = model.like_count == 0 ? "" : model.like_count.string
            
            commentButton.imageForNormal = R.image.post_comment_comment()!
            
            commentButton.titleForNormal = model.reply_list.count == 0 ? "" : "\(model.reply_list.count.string)"
            
        }
    }
    var replyModel:PostCommentReplyModel? {
        didSet {
            guard let model = replyModel else { return }
            avatarImgView.kf.setImage(with: model.user.avatar.url)
            userNameLabel.text = model.user.full_name + " · " + model.post_time
            
            contentLabel.text = model.content
            
            likeButton.imageForNormal = model.liked ? R.image.post_comment_like()! : R.image.post_comment_unlike()!
            likeButton.titleForNormal = model.like_count == 0 ? "" : model.like_count.string
            
            commentButton.imageForNormal = nil
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        reportButton.imageForNormal = UIImage.ellipsis?.withTintColor(.lightGray,renderingMode: .alwaysOriginal)
        reportButton.showsMenuAsPrimaryAction  = true
        
        let action = UIAction(title:"Report",image: UIImage.flag) { _ in
            let vc = PostReportController(type: 2)
            let nav = BaseNavigationController(rootViewController: vc)
            if let sheet = nav.sheetPresentationController{
                sheet.detents = [.medium(), .large()]
            }
            
            UIViewController.sk.getTopVC()?.present(nav, animated: true)
        }
        reportButton.menu = UIMenu(children: [action])
        
        likeButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            if let comment = self.commentModel {
                self.commentLikeHandler?(comment)
            }
            
            if let reply = self.replyModel {
                self.replyLikeHandler?(reply)
            }
           
            
        }).disposed(by: rx.disposeBag)
        
        commentButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self,let model = self.commentModel else { return }
            self.commentHandler?(model)
        }).disposed(by: rx.disposeBag)
        commentButton.titleColorForNormal = R.color.iconColor()!
        commentButton.sk.setImageTitleLayout(.imgLeft,spacing: 8)
        commentButton.titleLabel?.font = UIFont.sk.pingFangRegular(12)
        
        likeButton.titleColorForNormal = R.color.iconColor()!
        likeButton.sk.setImageTitleLayout(.imgLeft,spacing: 8)
        likeButton.titleLabel?.font = UIFont.sk.pingFangRegular(12)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
}
