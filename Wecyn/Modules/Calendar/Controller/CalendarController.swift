//
//  CalendarController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/15.
//

import UIKit

class CalendarController: BaseTableController {
    
    let headerView = CalendarHeaderView()
    var keyword:String? = nil
    var startDate = Date().string(withFormat: "yyyy-MM-dd")
    var endDate:String? = Date().string(withFormat: "yyyy-MM-dd")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel().text("My Calendar").color(R.color.textColor162C46()!).font(UIFont.sk.pingFangSemibold(20))
        self.navigation.item.leftBarButtonItem = UIBarButtonItem(customView: label)
        
        addRightBarItems()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshData()
    }
    
    override func refreshData() {
        ScheduleService.eventList(keyword: keyword,
                                  startDate: startDate,
                                  endDate: endDate).subscribe(onNext:{ models in
            self.dataArray.append(contentsOf: models)
            self.endRefresh(models.count)
        },onError: { e in
            self.endRefresh(e.asAPIError.emptyDatatype)
        }).disposed(by: rx.disposeBag)
    }
    
    override func createListView() {
        super.createListView()
        
        registRefreshHeader()
        
        headerView.size = CGSize(width: kScreenWidth, height: 280)
        tableView?.tableHeaderView = headerView
        headerView.calendarView.dateSelected = { [weak self] date in
            guard let `self` = self else { return }
            self.startDate = date.string(withFormat: "yyyy-MM-dd")
            self.endDate = date.string(withFormat: "yyyy-MM-dd")
            self.loadNewData()
        }
        
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kBottomsafeAreaMargin + kTabBarHeight, right: 0)
        
        tableView?.register(nibWithCellClass: CaledarItemCell.self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: CaledarItemCell.self)
        if self.dataArray.count > 0 {
            let model = dataArray[indexPath.row] as? EventListModel
            cell.model = model
        }
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let view = CalendarSectionView.loadViewFromNib()
            return view
        } else {
            let view = UIView().backgroundColor(.white)
            let label = UILabel().text("22 May 2023").color(R.color.textColor52()!).font(UIFont.sk.pingFangSemibold(15))
            view.addSubview(label)
            label.frame = CGRect(x: 28, y: 0, width: 100, height: 30)
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 162 : 30
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataArray[indexPath.row] as? EventListModel
        let vc = EventDetailController(eventId: model?.id ?? 0,status: model?.status ?? 0)
        self.present(vc, animated: true)
    }
    
}
