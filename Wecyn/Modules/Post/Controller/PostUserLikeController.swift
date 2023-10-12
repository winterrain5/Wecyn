//
//  PostUserLikeController.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/13.
//

import UIKit

class PostUserLikeController: BasePagingTableController {
    var lastId:Int = 0
    var userId:Int = 0
    required init(userId:Int) {
        super.init(nibName: nil, bundle: nil)
        self.userId = userId
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isSkeletonable = true
        refreshData()
        
    }
    

    override func createListView() {
        super.createListView()
        cellIdentifier = HomePostItemCell.className
        tableView?.isSkeletonable = true
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kBottomsafeAreaMargin, right: 0)
        
        tableView?.register(cellWithClass: HomePostItemCell.self)
        
        tableView?.separatorColor = R.color.backgroundColor()
        tableView?.separatorInset = .zero
        tableView?.separatorStyle = .singleLine
        
        registRefreshFooter()
    }
    
    
    override func refreshData() {
        self.showSkeleton()
        PostService.likedList(userId:userId, lastId: lastId).subscribe(onNext:{ models in
            self.dataArray.append(contentsOf: models)
            self.endRefresh(models.count,emptyString: "No Liked Post")
            self.hideSkeleton()
            self.lastId = (self.dataArray.last as? PostListModel)?.id ?? 0
            self.updateDataComplete?()
        }, onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype)
            self.hideSkeleton()
            self.updateDataComplete?()
        }).disposed(by: rx.disposeBag)
    }
    
    

    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - PagingSegmentHeight.cgFloat - kNavBarHeight)
    }
    
    override func loadNewData() {
        lastId = 0
        self.dataArray.removeAll()
        refreshData()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.dataArray.count > 0 && indexPath.row < dataArray.count {
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
            let model = dataArray[indexPath.row] as? PostListModel
            cell.model = model
        }
        
        cell.userInfoView.deleteHandler = { [weak self] model in
            guard let `self` = self else { return }
            self.deleteRow(model)
        }
        cell.footerView.repostHandler = {[weak self] in
            self?.dataArray.insert($0, at: 0)
            self?.tableView?.insertRows(at: [IndexPath(item: 0, section: 0)], with: .automatic)
            
        }
        cell.footerView.likeHandler = { [weak self] in
            self?.deleteRow($0)
        }
        cell.footerView.commentHandler = { [weak self] in
            guard let `self` = self else { return }
            let vc = PostDetailViewController(postModel: $0,isBeginEdit: true)
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
        cell.selectionStyle = .none
        return cell
    }
    
    func deleteRow(_ model:PostListModel) {
        let item = (self.dataArray as! [PostListModel]).firstIndex(of: model) ?? 0
        self.dataArray.remove(at: item)
        self.tableView?.deleteRows(at: [IndexPath(item: item, section: 0)], with: .automatic)
    }
    func updateRow(_ model:PostListModel) {
        let item = (self.dataArray as! [PostListModel]).firstIndex(of: model) ?? 0
        self.tableView?.reloadRows(at: [IndexPath(item: item, section: 0)], with: .none)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dataArray.count > 0 {
            let model = dataArray[indexPath.row] as! PostListModel
            let vc = PostDetailViewController(postModel: model)
            self.navigationController?.pushViewController(vc)
        }
        
    }
}
