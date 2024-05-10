//
//  ViewController.swift
//  CCTStaff
//
//  Created by Derrick on 2022/3/21.
//

import UIKit
import SwiftyJSON
class HomeController: BaseTableController {
    var lastId:Int = 0
    var createPostButton = UIButton()
    var isFilterOANotification = false
    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
    var cellHeightCache:[Int:CGFloat] = [:]
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UpdateNotificationCount, object: nil, queue: .main) { noti in
            if let objc = noti.object as? String,objc == "filterOANotificationCount" {
                self.isFilterOANotification = true
            } else {
                self.isFilterOANotification = false
            }
            self.getNotificationCount()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isSkeletonable = true
        
        addRightBarItems()
        addCreatePostButton()
        addTitleLabel()
        
        
        let status = IMController.shared.getLoginStatus()
        if status == .logout {
            IMController.shared.login()
        }
        
        refreshData()
        
        getNotificationCount()
        getIMNotification()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        
     
    }
    
    override func createListView() {
        super.createListView()
        pageSize = 10
        numberOfSkeletonCell = 5
        tableView?.isSkeletonable = true
        cellIdentifier = HomePostItemCell.className
        
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kTabBarHeight + 10, right: 0)
        
        tableView?.register(cellWithClass: HomePostItemCell.self)
        
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorInset = .zero
        tableView?.separatorStyle = .singleLine
        
        registRefreshHeader(colorStyle: .gray)
        registRefreshFooter()
    }

    func addTitleLabel() {
        let wecynLabel = UILabel()
        wecynLabel.text = "Wecyn"
        wecynLabel.textColor = R.color.textColor22()!
        wecynLabel.font = UIFont(name: "Zapfino", size: 16)
        let leftItem = UIBarButtonItem(customView: wecynLabel)
        self.navigation.item.leftBarButtonItem = leftItem
        
    }
    
    func addCreatePostButton() {
        self.view.addSubview(createPostButton)
        createPostButton.backgroundColor = R.color.theamColor()
        createPostButton.titleForNormal = "+"
        createPostButton.titleLabel?.font = UIFont.sk.pingFangMedium(30)
        createPostButton.titleColorForNormal = .white
        createPostButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-(kTabBarHeight + 16))
            make.width.height.equalTo(60)
        }
        createPostButton.addShadow(cornerRadius: 30)
        createPostButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            Haptico.selection()
           
            
            let vc = CreatePostViewController()
            let nav = BaseNavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            UIViewController.sk.getTopVC()?.present(nav, animated: true)
            vc.addCompleteHandler = { [weak self] in
                guard let `self` = self else { return }
                self.dataArray.insert($0, at: 0)
                self.tableView?.reloadData()
                self.tableView?.scrollToTop(animated: false)
            }
           
        }).disposed(by: rx.disposeBag)
    }
    
    override func listViewFrame() -> CGRect {
        return .init(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    }
    
    override func refreshData() {
        self.showSkeleton()
        
        PostService.postFeedList(lastId: lastId).subscribe(onNext:{ models in
            self.dataArray.append(contentsOf: models)
            self.endRefresh(models.count,emptyString: "No Post")
            self.hideSkeleton()
            self.lastId = models.last?.id ?? 0
        }, onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype,emptyString: e.asAPIError.errorInfo().message)
            self.hideSkeleton()
        }).disposed(by: rx.disposeBag)
    }
    
    func getNotificationCount() {
        NotificationService.getNotificationCount().subscribe(onNext:{
            print("Count:\($0)")
            self.updateNotificationBadge($0)
        }).disposed(by: rx.disposeBag)
    }
    
    func getIMNotification() {
       
        IMController.shared.getTotalUnreadMsgCount { [weak self] count in
            
            guard let `self` = self else { return }
            if self.isFilterOANotification {
                return
            }
            self.updateMessageBadge(count)
            
        }
        IMController.shared.totalUnreadSubject.subscribe(onNext:{ [weak self] count in
            guard let `self` = self else { return }
            if self.isFilterOANotification {
                return
            }
            self.updateMessageBadge(count)
        }).disposed(by: self.rx.disposeBag)
       
    }
    
    override func loadNewData() {
        lastId = 0
        self.dataArray.removeAll()
        refreshData()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.dataArray.count > 0,indexPath.row < self.dataArray.count {
            let model = dataArray[indexPath.row] as! PostListModel
            if let cacheHeight = cellHeightCache[model.id] {
                return cacheHeight
            }
            let cellHeight = model.cellHeight
            cellHeightCache[model.id] = cellHeight
            return cellHeight
        }
        return 184
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: HomePostItemCell.self)
        if dataArray.count > 0 {
            cell.model = dataArray[indexPath.row] as? PostListModel
        }
        cell.footerView.repostHandler = {[weak self] in
            self?.dataArray.insert($0, at: 0)
            self?.tableView?.insertRows(at: [IndexPath(item: 0, section: 0)], with: .automatic)
            
        }
        cell.footerView.likeHandler = { [weak self] in
            self?.updateRow($0)
        }
        cell.footerView.commentHandler = { [weak self] in
            guard let `self` = self else { return }
            let vc = PostDetailViewController(postId: $0.id,isBeginEdit: true)
            self.navigationController?.pushViewController(vc)
        }
       
        cell.userInfoView.followHandler = { [weak self] model in
            guard let `self` = self else { return }
            if model.user.is_following {
                self.updateRow(model)
            } else {
                var dataArray = (self.dataArray as! [PostListModel])
                let _ = dataArray.removeAll(where: { $0.id == model.id })
                self.dataArray = dataArray
                self.tableView?.reloadData()
            }
            
        }
        cell.userInfoView.updatePostType = { [weak self] in
            self?.updateRow($0)
        }
        cell.userInfoView.deleteHandler = { [weak self] model in
            guard let `self` = self else { return }
            self.deleteRow(model)
        }
       
        cell.selectionStyle = .none
        return cell
    }
    
    func updateRow(_ model:PostListModel) {
        let item = (self.dataArray as! [PostListModel]).firstIndex(of: model) ?? 0
        self.tableView?.reloadRows(at: [IndexPath(item: item, section: 0)], with: .none)
    }
    func deleteRow(_ model:PostListModel) {
        let item = (self.dataArray as! [PostListModel]).firstIndex(of: model) ?? 0
        self.dataArray.remove(at: item)
        self.tableView?.deleteRows(at: [IndexPath(item: item, section: 0)], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dataArray.count > 0 {
            let model = dataArray[indexPath.row] as! PostListModel
            let vc = PostDetailViewController(postId: model.id)
            self.navigationController?.pushViewController(vc)
            vc.deletePostFromDetailComplete = { [weak self] in
                self?.deleteRow($0)
            }
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.2, delay: 0) {
            self.createPostButton.alpha = 0.4
        }
    }
  
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.2, delay: 0) {
            self.createPostButton.alpha = 1
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if decelerate == false {
            scrollViewDidEndDecelerating(scrollView)
        }
    }
   
}

