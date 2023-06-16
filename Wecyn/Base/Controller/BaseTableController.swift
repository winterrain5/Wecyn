//
//  BaseTableController.swift
//  OneOnline
//
//  Created by Derrick on 2020/2/28.
//  Copyright © 2020 OneOnline. All rights reserved.
//


import UIKit
import DZNEmptyDataSet
import SkeletonView

class BaseTableController: BaseViewController,DataLoadable {
    
    var dataArray: [Any] = []
    var refreshWhenLoad: Bool = false
    var isFirstLoad: Bool = true
    
    var page: Int = 1
    var pageSize: Int = kPageSize
    
    var shouldDisplayEmptyDataView: Bool = false
    var emptyDataType: EmptyDataType = .NoData
    var emptyNoDataString: String = ""
    var emptyNoDataImage: String = ""
    
    var cellIdentifier:String = ""
    
    public var tableView:UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createListView()
    }
    
    func createListView() {
        
        configTableview(.plain)
    }
    
    func configTableview(_ style:UITableView.Style) {
        
        tableView = UITableView.init(frame: listViewFrame(), style: style)
        
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.emptyDataSetSource = self
        tableView?.emptyDataSetDelegate = self
        
        tableView?.separatorStyle = .none
        tableView?.separatorColor = .clear
        tableView?.backgroundColor = .white
        tableView?.showsHorizontalScrollIndicator = false
        tableView?.showsVerticalScrollIndicator = false
        tableView?.tableFooterView = UIView.init()
        
        tableView?.estimatedRowHeight = 0
        tableView?.estimatedSectionFooterHeight = 0
        tableView?.estimatedSectionHeaderHeight = 0
        if #available(iOS 15.0, *) {
            tableView?.sectionHeaderTopPadding = 0
        }
        
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kBottomsafeAreaMargin + 10, right: 0)
        
        view.addSubview(tableView!)
        
        tableView?.contentInsetAdjustmentBehavior = .never
     
    }
    
    func listViewFrame() -> CGRect {
        return .init(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    }
    
    func registRefreshHeader(colorStyle:RefreshColorStyle = .gray) {
        let header = RefreshAnimationHeader{ [weak self] in
            self?.loadNewData()
        }
        header.colorStyle = colorStyle
        tableView?.mj_header = header
        if refreshWhenLoad {
            tableView?.mj_header?.beginRefreshing()
        }
    }
    
    func registRefreshFooter() {
        let footer = RefreshAnimationFooter{ [weak self] in
            self?.loadNextPage()
        }
        tableView?.mj_footer = footer
        tableView?.mj_footer?.isHidden = true
    }
    
    func reloadData() {
        tableView?.reloadData()
        if isFirstLoad {
            tableView?.reloadEmptyDataSet()
        }
        isFirstLoad = false
        hideSkeleton()
    }
    
    func loadNewData() {
        page = 1
        if self.dataArray.count > 0 {
            self.dataArray.removeAll()
        }
        refreshData()
    }
    
    func refreshData() {
        fatalError("子类重写该方法，这里加入网络请求")
    }
    
    func loadNextPage() {
        page+=1
        refreshData()
    }
    
    func endRefresh(_ type: EmptyDataType,
                    emptyString: String = EmptyStatus.Message.NoData.rawValue) {
        shouldDisplayEmptyDataView = type == .Success ? false : true
        self.emptyDataType = type
        self.emptyNoDataString = emptyString
        reloadData()
        endHeaderFooterRefresh(0)
    }
    
    func endRefresh(_ count: Int,
                    emptyString: String = EmptyStatus.Message.NoData.rawValue,
                    emptyImage:String = EmptyStatus.Image.NoData.rawValue) {
        shouldDisplayEmptyDataView = self.dataArray.count > 0 ? false : true
        self.emptyDataType = self.dataArray.count > 0 ? .Success : .NoData
        self.emptyNoDataImage = emptyImage
        self.emptyNoDataString = emptyString
        reloadData()
        endHeaderFooterRefresh(count)
    }
    
    func endRefresh() {
        shouldDisplayEmptyDataView =  false
        emptyDataType = .Success
        reloadData()
        endHeaderFooterRefresh(0)
    }
    
    func endHeaderFooterRefresh(_ count: Int) {
        endHeaderRefresh()
        endFooterRefresh(count)
    }
    
    func endHeaderRefresh() {
        if let header = tableView?.mj_header {
            if (header.isRefreshing) {
                tableView?.mj_header?.endRefreshing()
            }
        }
    }
    
    func endFooterRefresh(_ count:Int) {
        if let footer = tableView?.mj_footer {
            if (footer.isRefreshing) {
                tableView?.mj_footer?.endRefreshing()
            }
            
            let isNoMoreData = count < pageSize || count == 0
            tableView?.mj_footer?.isHidden = isNoMoreData
        }
    }
    
    func showSkeleton() {
        if isFirstLoad {
            self.view.showSkeleton()
        }
    }
    
    func hideSkeleton() {
        self.view.hideSkeleton()
    }
    
    func cellAnimation(_ cell:UITableViewCell) {
        if isFirstLoad { return }
        cell.transform = CGAffineTransform.init(translationX: 0, y: 20)
        UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction) {
            cell.transform = CGAffineTransform.identity
        } completion: { (flag) in
            
        }
    }
}


extension  BaseTableController : UITableViewDelegate,SkeletonTableViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return self.cellIdentifier
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init()
        cell.textLabel?.text = "需要重写父类方法"
        cell.textLabel?.textColor = .black
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


extension  BaseTableController : DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return EmptyDataType.emptyImage(for: self.emptyDataType, noDataImage: self.emptyNoDataImage)
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        return EmptyDataType.emptyString(for: self.emptyDataType, noDataString:self.emptyNoDataString)
    }
    
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 10
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return shouldDisplayEmptyDataView
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetShouldFade(in scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    
}
