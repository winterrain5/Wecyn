//
//  ConnectionFriendController.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/7.
//

import UIKit
import JXPagingView
import JXSegmentedView
let ConnectFriendHeaderInSectionHeight: Int = 50
class ConnectionController: BaseViewController {

    var controllers = [ConnectionOfMyController(),ConnectionGroupController()]
   
    lazy var paggingView:JXPagingView = {
      let view = JXPagingView(delegate: self)
      return view
    }()
    
    lazy var headerVc = ConnectAuditController()
    
    var tableHeaderViewHeight: Int = 0
    
    var titleDataSource: JXSegmentedTitleDataSource = {
      let dataSource = JXSegmentedTitleDataSource()
      dataSource.titles = ["Connections","Groups"]
      dataSource.isTitleColorGradientEnabled = true
      dataSource.isTitleZoomEnabled = false
      dataSource.isTitleStrokeWidthEnabled = false
      dataSource.isSelectedAnimable = true
      dataSource.titleSelectedColor = R.color.theamColor()!
      dataSource.titleNormalColor = .black
        dataSource.titleSelectedFont = UIFont.boldSystemFont(ofSize: 14)
        dataSource.titleNormalFont = UIFont.systemFont(ofSize: 14)
      dataSource.isItemSpacingAverageEnabled = false
      return dataSource
    }()
    
    var indicator:JXSegmentedIndicatorLineView = {
      let indicator = JXSegmentedIndicatorLineView()
      indicator.indicatorWidth = 80
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
    
    lazy var rightButton = UIButton().then { btn in
        btn.imageForNormal = R.image.connection_search()
    }
    
    let searchView = NavbarSearchView(placeholder: "Search User",isSearchable: false).frame(CGRect(x: 0, y: 0, width: kScreenWidth * 0.75, height: 36))
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.ConnectionAuditUser, object: nil, queue: .main) { noti in
            self.getDatas()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addRightBarItems()
        
        
       
        self.navigation.item.titleView = searchView
        searchView.rx.tapGesture().when(.recognized).subscribe(onNext:{ _ in
            self.navigationController?.pushViewController(ConnectionUsersController(),animated: false)
        }).disposed(by: rx.disposeBag)
        
        self.addChild(headerVc)
        
        
        segmentedView.dataSource = titleDataSource
        segmentedView.listContainer = paggingView.listContainerView
       
        
        let bottomLayer = CALayer()
        bottomLayer.backgroundColor = R.color.backgroundColor()?.cgColor
        segmentedView.layer.addSublayer(bottomLayer)
        bottomLayer.frame = CGRect(x: 0, y: ConnectFriendHeaderInSectionHeight.cgFloat, width: kScreenWidth, height: 1)
        
        segmentedView.addSubview(rightButton)
        rightButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
            make.centerY.equalToSuperview()
        }
        rightButton.rx.tap.subscribe(onNext:{ [weak self] in
            if self?.segmentedView.selectedIndex == 0  {
                let vc = FriendSearchController()
                self?.navigationController?.pushViewController(vc)
            } else {
                let vc = CreateGroupController()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
           
        }).disposed(by: rx.disposeBag)
        
        paggingView.mainTableView.gestureDelegate = self
        self.view.addSubview(paggingView)
        paggingView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
        
        let header = RefreshAnimationHeader{ [weak self] in
            self?.getDatas()
        }
        header.colorStyle = .gray
        paggingView.mainTableView.mj_header = header

        getDatas()
        getNotificationCount()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchView.frame = CGRect(x: 0, y: 0, width: kScreenWidth * 0.75, height: 36)
        
    }
    
    func getNotificationCount() {
        NotificationService.getNotificationCount().subscribe(onNext:{
            print("Count:\($0)")
            self.updateNotificationBadge($0)
        }).disposed(by: rx.disposeBag)
    }
    
    
    func getDatas() {
        
        let recieveList = NetworkService.friendRecieveList()
        let friendList = NetworkService.friendList()
        Observable.zip(recieveList,friendList).subscribe(onNext:{ recieves,friends in
            if recieves.count > 0 {
                self.tableHeaderViewHeight = Int(recieves.count.cgFloat * ConnectionAuditCellHeight + ConnectionAuditSectionHeight)
            } else {
                self.tableHeaderViewHeight = 0
            }
            
            self.headerVc.models = recieves
            (
                self.controllers[0] as! ConnectionOfMyController
            ).models = friends
            
            self.paggingView.reloadData()
            self.paggingView.mainTableView.mj_header?.endRefreshing()
            NotificationCenter.default.post(name: Notification.Name.ConnectionRefreshing, object: self.tableHeaderViewHeight)
        }) { e in
            self.paggingView.mainTableView.mj_header?.endRefreshing()
            self.tableHeaderViewHeight = 0
            NotificationCenter.default.post(name: Notification.Name.ConnectionRefreshing, object: self.tableHeaderViewHeight)
            (
                self.controllers[0] as! ConnectionOfMyController
            ).models = []
        }.disposed(by: rx.disposeBag)
        
       
    }

}

extension ConnectionController:JXPagingMainTableViewGestureDelegate {
  func mainTableViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    //禁止segmentedView左右滑动的时候，上下和左右都可以滚动
    if otherGestureRecognizer == segmentedView.collectionView.panGestureRecognizer {
      return false
    }
    return gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
  }
}

extension ConnectionController:JXSegmentedViewDelegate {
  func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = (index == 0)
      rightButton.imageForNormal = index == 0 ? R.image.magnifyingglass()! : R.image.calendar_add()!
  }
}

extension ConnectionController:JXPagingViewDelegate {
  func tableHeaderViewHeight(in pagingView: JXPagingView) -> Int {
    return tableHeaderViewHeight
  }
  
  func tableHeaderView(in pagingView: JXPagingView) -> UIView {
    return headerVc.view
  }
  
  func heightForPinSectionHeader(in pagingView: JXPagingView) -> Int {
    return ConnectFriendHeaderInSectionHeight
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

