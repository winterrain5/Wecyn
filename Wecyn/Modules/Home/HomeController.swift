//
//  ViewController.swift
//  CCTStaff
//
//  Created by Derrick on 2022/3/21.
//

import UIKit

class HomeController: BaseTableController {
    var lastId:Int = 0
    var createPostButton = UIButton()
    override var preferredStatusBarStyle: UIStatusBarStyle { .default }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isSkeletonable = true
        
        addRightBarItems()
        
        self.view.addSubview(createPostButton)
        createPostButton.backgroundColor = R.color.theamColor()
        createPostButton.titleForNormal = "+"
        createPostButton.titleLabel?.font = UIFont.sk.pingFangMedium(30)
        createPostButton.titleColorForNormal = .white
        createPostButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(kTabBarHeight + 16)
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
        
        let wecynLabel = UILabel()
        wecynLabel.text = "Wecyn"
        wecynLabel.textColor = R.color.textColor22()!
        wecynLabel.font = UIFont(name: "Zapfino", size: 16)
        let leftItem = UIBarButtonItem(customView: wecynLabel)
        self.navigation.item.leftBarButtonItem = leftItem
        
        refreshData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func createListView() {
        super.createListView()
        
        cellIdentifier = HomePostItemCell.className
        tableView?.isSkeletonable = true
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kTabBarHeight + 10, right: 0)
        
        tableView?.register(cellWithClass: HomePostItemCell.self)
        
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorInset = .zero
        tableView?.separatorStyle = .singleLine
        
        registRefreshHeader(colorStyle: .gray)
        registRefreshFooter()
    }
    
    override func refreshData() {
        self.showSkeleton()
        PostService.postFeedList(lastId: lastId).subscribe(onNext:{ models in
            self.dataArray.append(contentsOf: models)
            self.endRefresh(models.count,emptyString: "No Post")
            self.hideSkeleton()
            self.lastId = models.last?.id ?? 0
        }, onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype)
            self.hideSkeleton()
        }).disposed(by: rx.disposeBag)
    }
    
    override func loadNewData() {
        lastId = 0
        self.dataArray.removeAll()
        refreshData()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.dataArray.count > 0,indexPath.row < self.dataArray.count {
            return (dataArray[indexPath.row] as? PostListModel)?.cellHeight ?? 0
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: HomePostItemCell.self)
        if dataArray.count > 0 {
            cell.model = dataArray[indexPath.row] as? PostListModel
        }
        cell.footerView.likeHandler = { [weak self] in
            guard let `self` = self else { return }
            let item = (self.dataArray as! [PostListModel]).firstIndex(of: $0) ?? 0
            self.tableView?.reloadRows(at: [IndexPath(item: item, section: 0)], with: .none)
        }
        cell.footerView.commentHandler = { [weak self] in
            guard let `self` = self else { return }
            let vc = PostDetailViewController(postModel: $0,isBeginEdit: true)
            self.navigationController?.pushViewController(vc)
        }
        cell.userInfoView.updatePostType = { [weak self] in
            guard let `self` = self else { return }
            let item = (self.dataArray as! [PostListModel]).firstIndex(of: $0) ?? 0
            self.tableView?.reloadRows(at: [IndexPath(item: item, section: 0)], with: .none)
        }
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dataArray.count > 0 {
            let model = dataArray[indexPath.row] as! PostListModel
            let vc = PostDetailViewController(postModel: model)
            self.navigationController?.pushViewController(vc)
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

