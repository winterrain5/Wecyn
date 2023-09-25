//
//  HomePostFootToolView.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/22.
//

import UIKit
class HomePostFootToolView: UIView {

    var shareButton = UIButton()
    var repostButton = UIButton()
    var commentButton = UIButton()
    var likeButton = UIButton()
    var stackView:UIStackView!
    var likeHandler:((PostListModel)->())?
    var commentHandler:((PostListModel)->())?
    var repostHandler:((PostListModel)->())?
    
    var postModel:PostListModel? {
        didSet {
            guard let model = postModel else { return }
            likeButton.titleForNormal = model.like_count >= 1 ? model.like_count.string : ""
            commentButton.titleForNormal = model.comment_count >= 1 ? model.comment_count.string : ""
            repostButton.titleForNormal = model.repost_count >= 1 ? model.repost_count.string : ""
            likeButton.imageForNormal = model.liked ? R.image.heartFill()! : R.image.heart()!
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stackView = UIStackView(arrangedSubviews: [likeButton,commentButton,repostButton,shareButton], axis: .horizontal,alignment: .center, distribution: .fillEqually)
        addSubview(stackView)
        
        configButton(likeButton, R.image.heart())
        configButton(commentButton, R.image.post_comment())
        configButton(repostButton, R.image.post_repost())
        configButton(shareButton, R.image.post_share())
        
        likeButton.rx.tap.subscribe(onNext:{ [weak self] in
            self?.likeAction()
        }).disposed(by: rx.disposeBag)
        
        commentButton.rx.tap.subscribe(onNext:{ [weak self] in
            self?.commentAction()
        }).disposed(by: rx.disposeBag)
        
        repostButton.rx.tap.subscribe(onNext:{ [weak self] in
            self?.repostAction()
        }).disposed(by: rx.disposeBag)
        
        shareButton.rx.tap.subscribe(onNext:{ [weak self] in
            self?.shareAction()
        }).disposed(by: rx.disposeBag)
        
        self.isSkeletonable = true
        stackView.isSkeletonable = true
        stackView.subviews.forEach({ $0.isSkeletonable = true  })
    }
    
    func configButton(_ btn:UIButton,_ image:UIImage?) {
        btn.titleLabel?.font = UIFont.sk.pingFangRegular(12)
        btn.titleColorForNormal = UIColor(hexString: "7d7d7d")
        btn.sk.setImageTitleLayout(.imgLeft,spacing: 6)
        btn.imageForNormal = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

    }
    func likeAction() {
        guard let model = self.postModel else { return }
        Haptico.selection()
        if model.liked {
           
            PostService.cancelLike(sourceId: model.id,type: 1).subscribe(onNext:{
                if $0.success == 1 {
                    model.like_count -= 1
                    model.liked = false
                    self.likeHandler?(model)
                }
            }).disposed(by: rx.disposeBag)
            
        } else {
            PostService.setLike(sourceId: model.id,type: 1).subscribe(onNext:{
                if $0.success == 1 {
                    model.like_count += 1
                    model.liked = true
                    self.likeHandler?(model)
                }
            }).disposed(by: rx.disposeBag)
           
        }
        
    }
    
    func commentAction() {
        
        guard let model = self.postModel else { return }
        Haptico.selection()
        commentHandler?(model)
    }
    
    func repostAction() {
        Haptico.selection()
        guard let model = self.postModel else { return }
        PostRepostTypeSheetView.display(isRepost: model.posted) {
            PostService.repost(id: model.id, content: "You reposted").subscribe(onNext:{ _ in
                Toast.showSuccess(withStatus: "You have reposted")
            }).disposed(by: self.rx.disposeBag)
        } quoteAction: {
            let vc = CreatePostViewController(postModel: model)
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            UIViewController.sk.getTopVC()?.present(nav, animated: true)
           
        }

    }
    
    
   func shareAction() {
       Haptico.selection()
       guard let url = "http://10.1.3.144/home".url else { return }
       let vc = VisualActivityViewController(url: url)
       vc.previewLinkColor = .magenta
       UIViewController.sk.getTopVC()?.present(vc, animated: true)
    }
    
}
