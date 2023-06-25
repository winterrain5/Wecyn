//
//  JobSavedController.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/13.
//

import UIKit

class JobSavedController: BaseTableController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        
    }
    
    func setupNavigationBar() {
        self.navigation.bar.prefersLargeTitles = true
        self.navigation.item.largeTitleDisplayMode = .automatic
        self.navigation.item.title = "My Saved Jobs"
    }

    override func createListView() {
        super.createListView()
        
        tableView?.contentInset = UIEdgeInsets(top: 62, left: 0, bottom: 0, right: 0)
        tableView?.register(nibWithCellClass: JobItemCell.self)
        tableView?.rowHeight = 200
    
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 189
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: JobItemCell.self)
        return cell
    }

}
