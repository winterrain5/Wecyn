//
//  PostUserPostedController.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/13.
//

import UIKit

class PostUserPostedController: BasePagingTableController {

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

        // Do any additional setup after loading the view.
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
        PostService.postList(userId:userId, lastId: lastId).subscribe(onNext:{ models in
            self.dataArray.append(contentsOf: models)
            self.endRefresh(models.count,emptyString: "No Post")
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
        if self.dataArray.count > 0 {
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
        cell.selectionStyle = .none
        return cell
    }

}
