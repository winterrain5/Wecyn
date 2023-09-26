//
//  PostFollowersController.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/26.
//

import UIKit

class PostFollowersController: BasePagingTableController {

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
        self.endRefresh()
        self.hideSkeleton()
        self.updateDataComplete?()
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
            cell.model = self.dataArray[indexPath.row] as? FriendUserInfoModel
        }
        cell.selectionStyle = .none
        return cell
    }



}
