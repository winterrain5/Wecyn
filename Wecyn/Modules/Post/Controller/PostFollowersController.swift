//
//  PostFollowersController.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/26.
//

import UIKit

class PostFollowersController: BasePagingTableController {
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
        
    }
    

   
    override func createListView() {
        super.createListView()
        cellIdentifier = PostFollowUserCell.className
        tableView?.isSkeletonable = true
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kBottomsafeAreaMargin, right: 0)
        
        tableView?.register(cellWithClass: PostFollowUserCell.self)
        
        tableView?.separatorColor = R.color.seperatorColor()
        tableView?.separatorInset = .zero
        tableView?.separatorStyle = .singleLine
        
        registRefreshFooter()
    }
    
    override func refreshData() {
        
        self.showSkeleton()
        NetworkService.followedList(type: 2,userId: userId,page: page).subscribe(onNext:{ models in
            self.dataArray.append(contentsOf: models)
            self.endRefresh(models.count,emptyString: "No Follower")
            self.hideSkeleton()
            self.updateDataComplete?()
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype)
            self.hideSkeleton()
            self.updateDataComplete?()
        }).disposed(by: rx.disposeBag)
      
    }
    
    

    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - PagingSegmentHeight.cgFloat - kNavBarHeight)
    }
    
 
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 72
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: PostFollowUserCell.self)
        if self.dataArray.count > 0 {
            cell.model = self.dataArray[indexPath.row] as? FriendFollowModel
        }
        cell.selectionStyle = .none
        return cell
    }



}
