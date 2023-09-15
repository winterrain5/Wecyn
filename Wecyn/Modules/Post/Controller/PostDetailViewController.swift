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

    var postModel:PostListModel!
    var postBar = PostCommentToolBarView()
    let postBarH = 48.cgFloat  + UIDevice.bottomSafeAreaMargin
    required init(postModel:PostListModel) {
        super.init(nibName: nil, bundle: nil)
        self.postModel = postModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigation.item.title = "Post"
        
        self.view.addSubview(postBar)
        postBar.frame = CGRect(x: 0, y: kScreenHeight - postBarH, width: kScreenWidth, height: postBarH)
        RxKeyboard.instance.visibleHeight.drive(onNext:{ [weak self] keyboardVisibleHeight in
            guard let `self` = self else { return }
            print(keyboardVisibleHeight)
            self.postBar.frame.origin.y = kScreenHeight - keyboardVisibleHeight - self.postBarH + UIDevice.bottomSafeAreaMargin
        }).disposed(by: rx.disposeBag)
        
        self.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = true
    }
    
    
    override func createListView() {
        super.createListView()
        
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kTabBarHeight + 10, right: 0)
        
        tableView?.register(nibWithCellClass: HomeItemCell.self)
        
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorInset = .zero
        tableView?.separatorStyle = .singleLine
        
        registRefreshHeader(colorStyle: .gray)
        registRefreshFooter()
    }
 
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.postModel.cellHeight
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: HomeItemCell.self)
        cell.model = self.postModel
        cell.selectionStyle = .none
        return cell
    }
   

}
