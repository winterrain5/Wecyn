//
//  EventSearchViewController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/29.
//

import UIKit
import IQKeyboardManagerSwift
class EventSearchViewController: BaseTableController {
    var keword:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchView = NavbarSearchView(placeholder: "Search Event Title",isSearchable: true).frame(CGRect(x: 0, y: 0, width: kScreenWidth * 0.75, height: 36))
        self.navigation.item.titleView = searchView
        searchView.searching = { [weak self] keyword in
            guard let `self` = self else { return }
            self.keword = keyword.trimmed
            self.loadNewData()
        }
        
        
        self.addLeftBarButtonItem(image: R.image.navigation_back_default()!.withTintColor(.black))
        self.leftButtonDidClick = {
            self.navigationController?.popViewController(animated: false)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar  = true
    }
    
    override func refreshData() {
        let eventList = ScheduleService.eventList(keyword: keword,
                                                    startDate: nil,
                                                    endDate: nil)
        let friendList = FriendService.friendList()
        
        Observable.zip(eventList,friendList).subscribe(onNext:{ [weak self]  events,friends in
            guard let `self` = self else { return }
            events.forEach({ event in
                
                let friend = friends.first(where: { $0.id == event.creator_id })
                event.creator_name = friend?.full_name ?? ""
                event.creator_avatar = friend?.avatar ?? ""

            })
            
            self.dataArray = events
            
            self.endRefresh(events.count)
            
        },onError: { e in
            self.endRefresh(.NoData, emptyString: "No Events")
        }).disposed(by: rx.disposeBag)
        
     
    }
    override func createListView() {
        super.createListView()
        registRefreshHeader()
        tableView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: kBottomsafeAreaMargin + 10, right: 0)
        tableView?.register(nibWithCellClass: CaledarItemCell.self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 113
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: CaledarItemCell.self)
        cell.searchingText = keword ?? ""
        if self.dataArray.count > 0 {
            cell.model = (self.dataArray as! [EventListModel])[indexPath.row]
        }
        cell.selectionStyle = .none
        
        return cell
    }
    
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var model:EventListModel!
        model = dataArray[indexPath.row] as? EventListModel
        let vc = EventDetailController(eventModel:model)
        let nav = BaseNavigationController(rootViewController: vc)
        vc.container.operateCompleteHandler = { [weak self] in
            guard let `self` = self else { return }
            self.loadNewData()
        }
        self.present(nav, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
class NavbarSearchView: UIView,UITextFieldDelegate {
    var leftImgView = UIImageView()
    var rightTf = UITextField()
    var searching:((String)->())?
    var beginSearch:(()->())?
    var isSearchable = false
    var placeholder:String = ""
    var isBecomeFirstResponder = true
    init(placeholder:String,isSearchable:Bool = false,isBecomeFirstResponder:Bool = true) {
       
        super.init(frame: .zero)
        
        self.placeholder = placeholder
        self.isSearchable = isSearchable
        
        backgroundColor = R.color.backgroundColor()
        
        addSubview(leftImgView)
        leftImgView.image = R.image.search_icon()
        leftImgView.contentMode = .scaleAspectFit
        
        addSubview(rightTf)
        rightTf.returnKeyType = .search
        rightTf.enablesReturnKeyAutomatically = true
        rightTf.placeholder = self.placeholder
        rightTf.font = UIFont.sk.pingFangRegular(12)
        rightTf.textColor = R.color.textColor52()
        rightTf.delegate = self
        rightTf.clearsOnBeginEditing = true
        rightTf.clearButtonMode = .whileEditing
        
        rightTf.isUserInteractionEnabled = isSearchable
        if isBecomeFirstResponder && isSearchable { rightTf.becomeFirstResponder() }
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       
     
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        cornerRadius = frame.size.height * 0.5

        leftImgView.frame = CGRect(x: 20, y: 0, width: 15, height: 15)
        leftImgView.center.y = frame.center.y
        rightTf.frame = CGRect(x: 43, y: 0, width: frame.width - 51, height: frame.height)
        rightTf.center.y = frame.center.y
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let test = self.rightTf.text ?? ""
        if test.isEmpty { return true }
        self.searching?(test)
        self.endEditing(true)
        Logger.debug("search text:\(test)")
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        beginSearch?()
    }
}
