//
//  PostUserInfoController.swift
//  Wecyn
//
//  Created by Derrick on 2023/9/13.
//

import UIKit


import JXPagingView
import JXSegmentedView
let PagingSegmentHeight: Int = 40
let PostUserHeaderViewHeight: Int = 340
class PostUserInfoController: BaseViewController {
    
    var controllers:[BasePagingTableController]  = []
    lazy var paggingView:JXPagingView = {
        let view = JXPagingView(delegate: self)
        return view
    }()
    
    var headerVc:PostUserHeaderController!
    
    
    
    var titleDataSource: JXSegmentedTitleDataSource = {
        let dataSource = JXSegmentedTitleDataSource()
        dataSource.titles = ["Post","Like"]
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
    
    var ratio:CGFloat = 0
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ratio == 0 ? .lightContent : .darkContent
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    private var userId:Int = 0
    private var userName:String = ""
    lazy var titleLabel = UILabel().then { label in
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18,weight: .medium)
        label.size = CGSize(width: 200, height: 30)
        label.textAlignment = .center
    }
    required init(userId:Int) {
        super.init(nibName: nil, bundle: nil)
        self.userId = userId
        headerVc = PostUserHeaderController(userId: userId)
        controllers = [PostUserPostedController(userId: userId),PostUserLikeController(userId: userId)]
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.addChild(headerVc)
        
        
        segmentedView.dataSource = titleDataSource
        segmentedView.listContainer = paggingView.listContainerView
        
        
        let bottomLayer = CALayer()
        bottomLayer.backgroundColor = R.color.backgroundColor()?.cgColor
        segmentedView.layer.addSublayer(bottomLayer)
        bottomLayer.frame = CGRect(x: 0, y: PagingSegmentHeight.cgFloat, width: kScreenWidth, height: 1)
        
        
        paggingView.mainTableView.gestureDelegate = self
        paggingView.pinSectionHeaderVerticalOffset = kNavBarHeight.int
        self.view.addSubview(paggingView)
        paggingView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        
        let header = RefreshAnimationHeader{ [weak self] in
            self?.loadData()
        }
        header.colorStyle = .gray
        paggingView.mainTableView.mj_header = header
        
        self.addLeftBarButtonItem(image: R.image.xmarkCircleFill()!)
        self.leftButtonDidClick = { [weak self] in
            self?.returnBack()
        }
        
        let search = UIButton()
        search.imageForNormal = R.image.magnifyingglassCircleFill()!
        self.navigation.item.rightBarButtonItem = UIBarButtonItem(customView: search)
        
        self.navigation.bar.alpha = 0
        self.navigation.item.titleView = titleLabel
        
        loadData()
    }
    
    func loadData() {
       
        headerVc.refreshData()
        headerVc.updateUserInfoComplete = { [weak self] in
            self?.userName = $0.full_name
        }
        
        let vc  = controllers[segmentedView.selectedIndex]
        vc.loadNewData()
        vc.updateDataComplete  = {[weak self] in
            self?.paggingView.mainTableView.mj_header?.endRefreshing()
        }
      
    }
    
    
}

extension PostUserInfoController:JXPagingMainTableViewGestureDelegate {
    func mainTableViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //禁止segmentedView左右滑动的时候，上下和左右都可以滚动
        if otherGestureRecognizer == segmentedView.collectionView.panGestureRecognizer {
            return false
        }
        return gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
    }
}

extension PostUserInfoController:JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = (index == 0)
        
    }
}

extension PostUserInfoController:JXPagingViewDelegate {
    func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
        return PostUserHeaderViewHeight
    }
    
    func tableHeaderView(in pagingView: JXPagingView) -> UIView {
        return headerVc.view
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
    
    func pagingView(_ pagingView: JXPagingView, mainTableViewDidScroll scrollView: UIScrollView) {
    
        ratio = scrollView.contentOffset.y /  kNavBarHeight
        self.titleLabel.text = ratio >= 1 ? self.userName : ""
        self.navigation.bar.alpha = ratio
        self.setNeedsStatusBarAppearanceUpdate()
    
    }
    
}

