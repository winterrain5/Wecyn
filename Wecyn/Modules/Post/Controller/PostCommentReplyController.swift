//
//  PostCommentReplyController.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/20.
//

import UIKit
import RxKeyboard
import IQKeyboardManagerSwift
class PostCommentReplyController: BaseTableController {
    var commentModel:PostCommentModel = PostCommentModel()
    var isBeginEdit = false
    required init(commentModel:PostCommentModel,isBeginEdit:Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.commentModel = commentModel
        self.isBeginEdit = isBeginEdit
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    var postBar = PostCommentToolBarView()
    let postBarH = 48.cgFloat
    let commentView = PostCommentCell.loadViewFromNib()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigation.item.title = "Reply"
        
        self.view.addSubview(postBar)
        postBar.tv.placeholder = "Post your reply"
        postBar.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: postBarH)
        RxKeyboard.instance.willShowVisibleHeight.drive(onNext:{ [weak self] keyboardVisibleHeight in
            guard let `self` = self else { return }
            self.postBar.frame.origin.y = kScreenHeight - keyboardVisibleHeight - self.postBarH
            
        }).disposed(by: rx.disposeBag)
        RxKeyboard.instance.isHidden.drive(onNext:{ [weak self] in
            guard let `self` = self else { return }
            if $0 {
                self.postBar.frame.origin.y = kScreenHeight
            }
        }).disposed(by: rx.disposeBag)
        
        if isBeginEdit {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.postBar.tv.becomeFirstResponder()
            }
        }
        
        postBar.sendButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            PostService.addReply(commentId: self.commentModel.id, content: self.postBar.tv.text).subscribe(onNext:{ model in
                self.updateData(model: model)
            }).disposed(by: self.rx.disposeBag)
            
        }).disposed(by: rx.disposeBag)
        
        
        postBar.expendButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            
            let vc = PostCommentFullScreenController(name: self.commentModel.user.full_name, id: self.commentModel.id, type: 2)
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
            
            vc.addReplyComplete = {
                self.updateData(model: $0)
            }
            
        }).disposed(by: rx.disposeBag)
        
        commentView.commentModel = commentModel
        commentView.frame = CGRect(x: 0, y: kNavBarHeight + 12, width: kScreenWidth, height: commentModel.cellHeight)
        commentView.backgroundColor = R.color.backgroundColor()!
        self.view.addSubview(commentView)
        
        commentView.commentButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            self.postBar.tv.becomeFirstResponder()
            
        }).disposed(by: rx.disposeBag)
        
        commentView.commentLikeHandler = { [weak self] model in
            guard let `self` = self else { return }
            if model.liked {
                PostService.cancelLike(sourceId: model.id,type: 2).subscribe(onNext:{ _ in
                    model.like_count -= 1
                    model.liked = false
                    self.commentView.commentModel = model
                }).disposed(by: self.rx.disposeBag)
            } else {
                PostService.setLike(sourceId: model.id,type: 2).subscribe(onNext:{ _ in
                    model.like_count += 1
                    model.liked = true
                    self.commentView.commentModel = model
                }).disposed(by: self.rx.disposeBag)
            }
            
        }
        
        self.addLeftBarButtonItem(image: R.image.xmark()!)
        self.leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }
    }
 
    
    func updateData(model:PostCommentReplyModel) {
        self.commentModel.reply_list.insert(model, at: 0)
        self.tableView?.reloadData()
        self.tableView?.scrollToTop(animated: false)
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = true
    }
    
    override func listViewFrame() -> CGRect {
        CGRect(x: 40, y: kNavBarHeight + commentModel.cellHeight + 12, width: kScreenWidth - 28, height: kScreenHeight - kNavBarHeight - commentModel.cellHeight - 12)
    }
    
    
    override func createListView() {
        super.createListView()
       
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kTabBarHeight + 10, right: 0)
        
        tableView?.register(nibWithCellClass: PostCommentCell.self)
        
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        tableView?.separatorStyle = .singleLine
        
        tableView?.estimatedRowHeight = 100
        
        
    }
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentModel.reply_list.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: PostCommentCell.self)
        if commentModel.reply_list.count > 0 {
            cell.replyModel = commentModel.reply_list[indexPath.row]
        }
        cell.replyLikeHandler = { [weak self] model in
            guard let `self` = self else { return }
            if model.liked {
                PostService.cancelLike(sourceId: model.id,type: 3).subscribe(onNext:{ _ in
                    model.like_count -= 1
                    model.liked = false
                    let item = self.commentModel.reply_list.firstIndex(of: model) ?? 0
                    self.tableView?.reloadRows(at: [IndexPath(item: item, section: 0)], with: .none)
                }).disposed(by: self.rx.disposeBag)
            } else {
                PostService.setLike(sourceId: model.id,type: 3).subscribe(onNext:{ _ in
                    model.like_count += 1
                    model.liked = true
                    let item = self.commentModel.reply_list.firstIndex(of: model) ?? 0
                    self.tableView?.reloadRows(at: [IndexPath(item: item, section: 0)], with: .none)
                }).disposed(by: self.rx.disposeBag)
            }
            
        }
        return cell
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
  

}
