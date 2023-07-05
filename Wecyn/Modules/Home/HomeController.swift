//
//  ViewController.swift
//  CCTStaff
//
//  Created by Derrick on 2022/3/21.
//

import UIKit

class HomeController: BaseTableController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addRightBarItems()
    }
    
    override func createListView() {
        super.createListView()
        
        tableView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: kTabBarHeight + 10, right: 0)
        tableView?.estimatedRowHeight = 300
        tableView?.rowHeight = UITableView.automaticDimension
        
        let headView = HomeHeaderView.loadViewFromNib()
        headView.size = CGSize(width: kScreenWidth, height: 305)
        tableView?.tableHeaderView = headView
        
        tableView?.register(nibWithCellClass: HomeItemCell.self)
        
        tableView?.separatorColor = R.color.backgroundColor()
        tableView?.separatorInset = .zero
        tableView?.separatorStyle = .singleLine
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: HomeItemCell.self)
        return cell
    }
}

