//
//  BaseCollectionController.swift
//  OneOnline
//
//  Created by Derrick on 2020/2/28.
//  Copyright © 2020 OneOnline. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import SkeletonView
class BaseCollectionController: BaseViewController,DataLoadable {
    
    var dataArray: [Any] = []
    
    var refreshWhenLoad: Bool = false
    
    var isFirstLoad: Bool = true
    
    var page: Int = 1
    
    var pageSize: Int = 18
    
    var shouldDisplayEmptyDataView: Bool = false
    var emptyDataType: EmptyDataType = .NoData
    var emptyNoDataString: String = ""
    var emptyNoDataImage: String = ""
    
    public var collectionView:UICollectionView?
    public var cellIdentifier:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createListView()
    }

    func createListView() {
        collectionView = UICollectionView.init(frame: listViewFrame(), collectionViewLayout: listViewLayout())
        collectionView?.backgroundColor = UIColor.clear
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kBottomsafeAreaMargin + 20, right: 0)
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        
        collectionView?.emptyDataSetSource = self
        collectionView?.emptyDataSetDelegate = self
        
        view.addSubview(collectionView!)
        
        if #available(iOS 11.0, *) {
            collectionView?.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    func listViewFrame() -> CGRect {
        return CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
    }
    
    func listViewLayout() -> UICollectionViewLayout {
        return UICollectionViewFlowLayout()
    }

    func registRefreshHeader(colorStyle:RefreshColorStyle) {
        let header = RefreshAnimationHeader{ [weak self] in
            self?.loadNewData()
        }
        header.colorStyle = colorStyle
        collectionView?.mj_header = header
        if refreshWhenLoad {
            collectionView?.mj_header?.beginRefreshing()
        }
    }
    
    func registRefreshFooter() {
        let footer = RefreshAnimationFooter{ [weak self] in
            self?.loadNextPage()
        }
        collectionView?.mj_footer = footer
        collectionView?.mj_footer?.isHidden = true
    }
    
    func reloadData() {
        self.collectionView?.reloadData()
        if isFirstLoad {
            collectionView?.reloadEmptyDataSet()
        }
        isFirstLoad = false
        
    }
    
    func reloadEmptyDataSet(emptyString: String,
                            emptyImage:String) {
        shouldDisplayEmptyDataView = self.dataArray.count > 0 ? false : true
        self.emptyDataType = self.dataArray.count > 0 ? .Success : .NoData
        self.emptyNoDataImage = emptyImage
        self.emptyNoDataString = emptyString
        collectionView?.reloadEmptyDataSet()
    }
    
    func loadNewData() {
        page=1
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
    
    func endRefresh(_ type: EmptyDataType, emptyString: String = EmptyStatus.Message.NoData.rawValue) {
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
        shouldDisplayEmptyDataView = false
        reloadData()
        endHeaderFooterRefresh(0)
    }
    
    func endHeaderFooterRefresh(_ count: Int) {
        endHeaderRefresh()
        endFooterRefresh(count)
    }
    
    func endHeaderRefresh() {
        guard let header = collectionView?.mj_header else {
            return
        }
        if header.isRefreshing {
            collectionView?.mj_header?.endRefreshing()
        }
    }
    
    func endFooterRefresh(_ count:Int) {
        guard let footer = collectionView?.mj_footer else {
            return
        }
        if footer.isRefreshing {
            collectionView?.mj_footer?.endRefreshing()
        }
        
        let isNoMoreData = count < pageSize || count == 0
        collectionView?.mj_footer?.isHidden = isNoMoreData
    }
    
    func enableSkeleton(with cellIdentifier:String) {
        self.collectionView?.isSkeletonable = true
        self.cellIdentifier = cellIdentifier
    }
    
    func showSkeleton() {
        if isFirstLoad {
            self.view.showAnimatedSkeleton()
        }
    }
    
    func hideSkeleton() {
        self.view.hideSkeleton()
    }
   
}


extension  BaseCollectionController : SkeletonCollectionViewDataSource,UICollectionViewDelegate {

    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return self.cellIdentifier
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func cellAnimation(_ cell:UICollectionViewCell,_ index:Int) {
        if isFirstLoad { return }
        cell.transform = CGAffineTransform.init(translationX: 0, y: 20)
        UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction,.curveEaseIn]) {
            cell.transform = CGAffineTransform.identity
        } completion: { (flag) in
            
        }
    }
}

extension  BaseCollectionController : DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return EmptyDataType.emptyImage(for: self.emptyDataType,noDataImage: self.emptyNoDataImage)
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return EmptyDataType.emptyString(for: self.emptyDataType, noDataString:self.emptyNoDataString)
    }
    
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 24
    }
   
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        return shouldDisplayEmptyDataView
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
}


