//
//  PostFollowController.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/26.
//

import UIKit
import JXPagingView
import JXSegmentedView
class PostFollowController: BaseViewController {
    
    var controllers:[BasePagingTableController]  = []
    lazy var paggingView:JXPagingView = {
        let view = JXPagingView(delegate: self)
        return view
    }()
    
    var titleDataSource: JXSegmentedTitleDataSource = {
        let dataSource = JXSegmentedTitleDataSource()
        dataSource.titles = ["Following","Followers"]
        dataSource.isTitleColorGradientEnabled = true
        dataSource.isTitleZoomEnabled = false
        dataSource.isTitleStrokeWidthEnabled = false
        dataSource.isSelectedAnimable = true
        dataSource.titleSelectedColor = R.color.theamColor()!
        dataSource.titleNormalColor = .black
        dataSource.titleSelectedFont = UIFont.boldSystemFont(ofSize: 16)
        dataSource.titleNormalFont = UIFont.systemFont(ofSize: 15,weight: .medium)
        dataSource.isItemSpacingAverageEnabled = true
        return dataSource
    }()
    
    var indicator:JXSegmentedIndicatorLineView = {
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorHeight = 2
        indicator.indicatorColor = R.color.theamColor()!
        indicator.verticalOffset = 0
        indicator.lineStyle = .lengthen
        return indicator
    }()
    
    
    lazy var segmentedView = JXSegmentedView().then { (segment) in
        segment.dataSource = titleDataSource
        segment.delegate = self
        segment.indicators = [indicator]
        segment.backgroundColor = .clear
        segment.defaultSelectedIndex = 0
    }
  
    lazy var titleLabel = UILabel().then { label in
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18,weight: .medium)
        label.size = CGSize(width: 200, height: 30)
        label.textAlignment = .center
    }
 
    
    var user:FriendUserInfoModel?
    var defaultIndex:Int = 0
    
    required init(user:FriendUserInfoModel,defaultIndex:Int = 0) {
        super.init(nibName: nil, bundle: nil)
        
        self.user = user
        self.defaultIndex = defaultIndex
        controllers  = [PostFollowingController(userId: user.id),PostFollowersController(userId: user.id)]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigation.item.title = user?.full_name
   
        segmentedView.dataSource = titleDataSource
        segmentedView.listContainer = paggingView.listContainerView
        segmentedView.defaultSelectedIndex = defaultIndex
        
        let bottomLayer = CALayer()
        bottomLayer.backgroundColor = R.color.backgroundColor()?.cgColor
        segmentedView.layer.addSublayer(bottomLayer)
        bottomLayer.frame = CGRect(x: 0, y: PagingSegmentHeight.cgFloat, width: kScreenWidth, height: 1)
        
        
        paggingView.mainTableView.gestureDelegate = self
        self.view.addSubview(paggingView)
        paggingView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
        
        let header = RefreshAnimationHeader{ [weak self] in
            self?.loadData()
        }
        header.colorStyle = .gray
        paggingView.mainTableView.mj_header = header
        
     
        
        loadData()
    }
    
    func loadData() {
    
        let vc  = controllers[segmentedView.selectedIndex]
        vc.loadNewData()
        vc.updateDataComplete  = {[weak self] in
            self?.paggingView.mainTableView.mj_header?.endRefreshing()
        }
        
    }
    
    
}

extension PostFollowController:JXPagingMainTableViewGestureDelegate {
    func mainTableViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //禁止segmentedView左右滑动的时候，上下和左右都可以滚动
        if otherGestureRecognizer == segmentedView.collectionView.panGestureRecognizer {
            return false
        }
        return gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
    }
}

extension PostFollowController:JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = (index == 0)
        
    }
}

extension PostFollowController:JXPagingViewDelegate {
    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
        0
    }
    
    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        UIView()
    }
    
  
    
    func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
        return PagingSegmentHeight
    }
    
    func viewForPinSectionHeader(in pagingView: JXPagingView) -> UIView {
        segmentedView.width = kScreenWidth
        return segmentedView
    }
    
    func numberOfLists(in pagingView: JXPagingView) -> Int {
        return titleDataSource.dataSource.count
    }
    
    func pagingView(_ pagingView: JXPagingView, initListAtIndex index: Int) -> JXPagingViewListViewDelegate {
        return controllers[index]
    }
    

    
}

