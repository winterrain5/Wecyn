//
//  CalendarController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/15.
//

import UIKit

class CalendarController: BaseTableController {
    
    let headerView = CalendarHeaderView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel().text("My Calendar").color(R.color.textColor162C46()!).font(UIFont.sk.pingFangSemibold(20))
        self.navigation.item.leftBarButtonItem = UIBarButtonItem(customView: label)
        
        addRightBarItems()
        
    }
    
    override func createListView() {
        super.createListView()
        
        headerView.size = CGSize(width: kScreenWidth, height: 290)
        tableView?.tableHeaderView = headerView
        
        tableView?.register(nibWithCellClass: CaledarItemCell.self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 78
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: CaledarItemCell.self)
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
        return section == 0 ? 180 : 30
    }

    
}
