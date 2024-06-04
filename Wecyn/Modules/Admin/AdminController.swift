//
//  AdminController.swift
//  Wecyn
//
//  Created by Derrick on 2023/12/15.
//

import UIKit
import JXPagingView
import JXSegmentedView
var Admin_Org_ID:Int = 1


enum AdminPermission:String, CaseIterable {
    case Department
    case MeetingRoom
    case Staff
    case BusinessCard
    
    static func allPermission(code:[Int]) -> String {
        let allCases = allCases.map({ $0.rawValue })
        var permission:[String] = []
        code.enumerated().forEach({
            if $1 == 1 {
                permission.append(allCases[$0])
            }
        })
        
        return permission.map({ $0 + "<All>" }).joined(separator: ",")
    }
    
}

class AdminController: BaseViewController {

    var controllers:[BasePagingTableController]  = []
    lazy var paggingView:JXPagingView = {
        let view = JXPagingView(delegate: self)
        return view
    }()
    
    
    var titleDataSource: JXSegmentedTitleDataSource = {
        let dataSource = JXSegmentedTitleDataSource()
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
    
    let filterButton = UIButton()
    var orgList:[AdminOrgModel] = []
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UpdateAdminData, object: nil, queue: OperationQueue.main) { _ in
            self.loadData()
        }
        
//        let is_super = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)?.is_super ?? 0
//        if is_super == 1{
//            controllers = [AdminRoleController(),AdminDepartmentController(),AdminStaffController(),AdminRoomController(),AdminDomainController()]
//            titleDataSource.titles = ["Role","Department","Staff","Room","Domain"]
//        } else {
//            controllers = [AdminDepartmentController(),AdminStaffController(),AdminRoomController()]
//            titleDataSource.titles = ["Department","Staff","Room"]
//        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedView.listContainer = paggingView.listContainerView
        
        
        let bottomLayer = CALayer()
        bottomLayer.backgroundColor = R.color.backgroundColor()?.cgColor
        segmentedView.layer.addSublayer(bottomLayer)
        bottomLayer.frame = CGRect(x: 0, y: PagingSegmentHeight.cgFloat, width: kScreenWidth, height: 1)
        
        
        self.view.addSubview(paggingView)
        paggingView.frame = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
        
        let header = RefreshAnimationHeader{ [weak self] in
            self?.loadData()
        }
        header.colorStyle = .gray
        paggingView.mainTableView.mj_header = header
        
        self.view.isSkeletonable = true
        paggingView.isSkeletonable = true
 
        
        self.navigation.bar.alpha = 0
        self.navigation.item.title = "Organization"
        
       
        filterButton.imageForNormal = R.image.calendar_filter()
        filterButton.showsMenuAsPrimaryAction = true
        let filterItem = UIBarButtonItem(customView: filterButton)
        self.navigation.item.rightBarButtonItem = filterItem
        getOrgList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func loadData() {
        Toast.showLoading()
        let vc  = controllers[segmentedView.selectedIndex]
        vc.loadNewData()
        vc.updateDataComplete  = {[weak self] in
            Toast.dismiss()
            self?.paggingView.mainTableView.mj_header?.endRefreshing()
        }
    }
    
    func getOrgList() {
        AdminService.adminOrgList().subscribe(onNext:{
            self.orgList = $0
            if self.orgList.count > 0 {
                var menuData: [(String, [(String, UIImage?)])] {
                    return [
                        ("Organization", self.orgList.map({
                            (title: $0.name, image:nil);
                        }) )
                    ]
                }
                
                let menu = UIMenu.map(data: menuData, handler: { [weak self] action in
                    guard let `self` = self else { return }
                    action.handleStateChange(self.filterButton, section: 0, isSingleChoose: true) { [weak self] in
                        guard let `self` = self else { return }
                        let index = self.filterButton.checkRow(by: 0) ?? 0
                        Admin_Org_ID = self.orgList[index].id
                        self.navigation.item.title = self.orgList[index].name
                        self.configControlers(roleId: self.orgList[index].role_id, permissions: self.orgList[index].permission)
                        self.loadData()
                    }
                })
                self.filterButton.menu = menu
            }
            Admin_Org_ID = $0.first?.id ?? 0
            self.navigation.item.title = $0.first?.name
            self.configControlers(roleId: $0.first?.role_id ?? 0, permissions: $0.first?.permission ?? [])
            self.loadData()
        },onError: { e in
            Toast.showError(e.asAPIError.errorInfo().message)
        }).disposed(by: rx.disposeBag)
    }
    
    func configControlers(roleId:Int,permissions:[Int]) {
        //            若role id!=1，则根据permission列表判断权限(0 无权限，1有权限)Department, Meeting Room, Staff, Name Card
        //            若role id==1，则为Super Admin，拥有所有权限 (目前权限包括:Role, Domain, Department,Room, Staft; Name Cartd)
                    
        if roleId == 1{
            self.controllers = [AdminRoleController(),AdminDepartmentController(),AdminRoomController(),AdminStaffController(),AdminDomainController()]
            self.titleDataSource.titles = ["Role","Department","Room","Staff","Domain"]
        } else {
            self.titleDataSource.titles.removeAll()
            if permissions.count == 4  {
                
                if permissions[0] == 1 {
                    self.controllers.append(AdminDepartmentController())
                    self.titleDataSource.titles.append("Department")
                }
                if permissions[1] == 1 {
                    self.controllers.append(AdminRoomController())
                    self.titleDataSource.titles.append("Room")
                }
                if permissions[2] == 1 {
                    self.controllers.append(AdminStaffController())
                    self.titleDataSource.titles.append("Staff")
                }
//                if permissions[3] == 1 {
//                    self.controllers.append(BasePagingTableController())
//                    self.titleDataSource.titles.append("Business card")
//                }
                
            }
        }
        
        segmentedView.dataSource = titleDataSource
        paggingView.reloadData()
        segmentedView.reloadData()
        
    }
    
}



extension AdminController:JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = (index == 0)
        loadData()
    }
}

extension AdminController:JXPagingViewDelegate {
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

