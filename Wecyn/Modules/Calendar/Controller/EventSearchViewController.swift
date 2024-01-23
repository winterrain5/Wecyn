//
//  EventSearchViewController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/29.
//

import UIKit
import IQKeyboardManagerSwift
class EventSearchViewController: BaseTableController {
    let requestModel = EventListRequestModel()
    var searchView:NavbarSearchView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchView = NavbarSearchView(placeholder: "Search Event Title",isSearchable: true,isBecomeFirstResponder: true).frame(CGRect(x: 0, y: 0, width: kScreenWidth * 0.75, height: 36))
        self.navigation.item.titleView = searchView
        searchView.searching = { [weak self] keyword in
            guard let `self` = self else { return }
            self.requestModel.keyword = keyword.trimmed
            self.loadNewData()
        }
        
        
        self.addLeftBarButtonItem()
        self.leftButtonDidClick = { [weak self] in
            self?.returnBack()
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
        let eventList = ScheduleService.eventList(model: requestModel)
        
        eventList.subscribe(onNext:{ [weak self]  events in
            guard let `self` = self else { return }
            events.forEach({ $0.isBySearch = true })
            self.dataArray = events
            
            self.endRefresh(events.count)
            
            self.searchView.endSearching()
            
        },onError: { e in
            self.searchView.endSearching()
            self.endRefresh(.NoData, emptyString: "No Events")
        }).disposed(by: rx.disposeBag)
        
     
    }
    override func createListView() {
        super.createListView()
        registRefreshHeader()
        tableView?.separatorStyle = .singleLine
        tableView?.separatorColor = R.color.seperatorColor()!
        tableView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: kBottomsafeAreaMargin + 10, right: 0)
        tableView?.register(nibWithCellClass: CaledarItemCell.self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: CaledarItemCell.self)
        cell.searchingText = self.requestModel.keyword ?? ""
        if self.dataArray.count > 0 {
            cell.model = (self.dataArray as! [EventListModel])[indexPath.row]
        }
        cell.selectionStyle = .none
        
        return cell
    }
    
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let model = dataArray[indexPath.row] as! EventListModel
        let vc = CalendarEventDetailController(eventModel:model)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
