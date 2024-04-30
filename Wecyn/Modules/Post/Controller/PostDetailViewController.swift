//
//  PostDetailViewController.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/15.
//

import UIKit
import IQKeyboardManagerSwift
import RxKeyboard
class PostDetailViewController: BaseTableController {

    var postModel:PostListModel?
    var postId:Int?
    var postBar = PostCommentToolBarView()
    let postBarH = 48.cgFloat
    let commentFooterView = PostDetailCommentFooterView.loadViewFromNib()
    var commentList:[PostCommentModel] = []
    var lastCommentId:Int = 0
    var isBeginEdit = false
    var deletePostFromDetailComplete:((PostListModel)->())?
    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
   
    required init(postId:Int,isBeginEdit:Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.postId = postId
        self.isBeginEdit = isBeginEdit
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigation.item.title = "Post"
        
        self.view.addSubview(postBar)
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
        postBar.expendButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self,let model = self.postModel else { return }
            let vc = PostCommentFullScreenController(name: model.user.full_name, id: model.id, type: 1)
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
            vc.addCommentComplete = {
                self.updateData(model: $0)
            }
            
        }).disposed(by: rx.disposeBag)
        
        postBar.sendButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self,let model = self.postModel else { return }
            PostService.addComment(postId: model.id, content: self.postBar.tv.text).subscribe(onNext:{ model in
                self.updateData(model: model)
            }).disposed(by: self.rx.disposeBag)
        }).disposed(by: rx.disposeBag)
        
        if isBeginEdit {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.postBar.tv.becomeFirstResponder()
            }
        }
        
        commentFooterView.addCommentButton.rx.tap.subscribe(onNext:{ [weak self] in
            self?.postBar.tv.becomeFirstResponder()
        }).disposed(by: rx.disposeBag)
        
        commentFooterView.postCountLabel.text = self.postModel?.comment_count.string
        
        
        self.getPostInfo()
        self.refreshData()
        
    }
    
    func updateData(model:PostCommentModel) {
        self.commentList.insert(model, at: 0)
        self.tableView?.reloadData()
        self.tableView?.scrollToTop(animated: false)
        self.view.endEditing(true)
    }
    
    override func refreshData() {
      
        PostService.commentList(postId: self.postModel?.id ?? 0,lastCommentId: lastCommentId).subscribe(onNext:{
            self.commentList.append(contentsOf: $0)
            self.endRefresh()
            self.lastCommentId = $0.last?.id ?? 0
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype)
        }).disposed(by: rx.disposeBag)
        
    }
    
    func getPostInfo() {
        guard let id = postId else { return }
        PostService.postInfo(id: id).subscribe(onNext:{
            self.postModel = $0
            self.endRefresh()
        }).disposed(by: rx.disposeBag)
    }
    
    override func loadNewData() {
        lastCommentId = 0
        self.commentList.removeAll()
        refreshData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = false
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = true
    }
    
    
    override func createListView() {
        super.createListView()
        
        tableView?.contentInset = .zero
        
        tableView?.register(cellWithClass: HomePostItemCell.self)
        tableView?.register(nibWithCellClass: PostCommentCell.self)
        
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorInset = .zero
        tableView?.separatorStyle = .singleLine
        
        tableView?.estimatedRowHeight = 100
        
        registRefreshHeader(colorStyle: .gray)
        registRefreshFooter()
    }
    
 
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return self.postModel?.cellHeight ?? 0
        }
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : commentList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withClass: HomePostItemCell.self)
            if let model = self.postModel {
                cell.model = model
            }
            
            cell.selectionStyle = .none
            cell.footerView.commentHandler = { [weak self] _ in
                self?.postBar.tv.becomeFirstResponder()
            }
            cell.footerView.likeHandler = { [weak self] _ in
                guard let `self` = self else { return }
                self.tableView?.reloadRows(at: [IndexPath(item: 0, section: 0)], with: .none)
            }
            cell.userInfoView.updatePostType = { [weak self] _ in
                guard let `self` = self else { return }
                self.tableView?.reloadRows(at: [IndexPath(item: 0, section: 0)], with: .none)
            }
            cell.userInfoView.followHandler = { [weak self] _ in
                guard let `self` = self else { return }
                self.tableView?.reloadRows(at: [IndexPath(item: 0, section: 0)], with: .none)
            }
            cell.userInfoView.deleteHandler = { [weak self]  in
                guard let `self` = self else { return }
                self.deletePostFromDetailComplete?($0)
                self.navigationController?.popViewController()
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withClass: PostCommentCell.self)
            if commentList.count > 0 {
                cell.commentModel = commentList[indexPath.row]
            }
            cell.commentLikeHandler = { [weak self] model in
                guard let `self` = self else { return }
                if model.liked {
                    PostService.cancelLike(sourceId: model.id,type: 2).subscribe(onNext:{ _ in
                        model.like_count -= 1
                        model.liked = false
                        let item = self.commentList.firstIndex(of: model) ?? 0
                        self.tableView?.reloadRows(at: [IndexPath(item: item, section: 1)], with: .none)
                    }).disposed(by: self.rx.disposeBag)
                } else {
                    PostService.setLike(sourceId: model.id,type: 2).subscribe(onNext:{ _ in
                        model.like_count += 1
                        model.liked = true
                        let item = self.commentList.firstIndex(of: model) ?? 0
                        self.tableView?.reloadRows(at: [IndexPath(item: item, section: 1)], with: .none)
                    }).disposed(by: self.rx.disposeBag)
                }
                
            }
            cell.commentHandler = { [weak self] model in
                guard let `self` = self else { return }
                let vc = PostCommentReplyController(commentModel: model,isBeginEdit: true)
                let nav = BaseNavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            return
        }
        if commentList.count == 0 {
            return
        }
        let model = commentList[indexPath.row]
        let vc = PostCommentReplyController(commentModel: model,isBeginEdit: false)
        let nav = BaseNavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return section == 0 ?  nil : commentFooterView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ?  0 : 102
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
